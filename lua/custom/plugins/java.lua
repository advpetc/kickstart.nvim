-- Java LSP configuration using nvim-jdtls
return {
  {
    'mfussenegger/nvim-jdtls',
    ft = 'java',
    config = function()
      local java_home = '/Library/Java/JavaVirtualMachines/jdk21.0.6-msft.jdk/Contents/Home'
      local jdtls_path = vim.fn.stdpath 'data' .. '/mason/packages/jdtls'

      local function start_jdtls()
        -- Check if jdtls directory exists
        if vim.fn.isdirectory(jdtls_path) == 0 then
          vim.notify('jdtls not installed. Run :MasonInstall jdtls', vim.log.levels.WARN)
          return
        end

        local jdtls = require 'jdtls'
        local launcher_jar = vim.fn.glob(jdtls_path .. '/plugins/org.eclipse.equinox.launcher_*.jar')
        local config_dir = jdtls_path .. '/config_mac_arm'

        local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
        local workspace_dir = vim.fn.expand '~/.local/share/nvim/jdtls-workspace/' .. project_name

        local config = {
          cmd = {
            java_home .. '/bin/java',
            '-Declipse.application=org.eclipse.jdt.ls.core.id1',
            '-Dosgi.bundles.defaultStartLevel=4',
            '-Declipse.product=org.eclipse.jdt.ls.core.product',
            '-Dlog.protocol=true',
            '-Dlog.level=ALL',
            '-XX:+UseG1GC',
            '-XX:+UseStringDeduplication',
            '-Xms512m',
            '-Xmx2g',
            '--add-modules=ALL-SYSTEM',
            '--add-opens', 'java.base/java.util=ALL-UNNAMED',
            '--add-opens', 'java.base/java.lang=ALL-UNNAMED',
            '-jar', launcher_jar,
            '-configuration', config_dir,
            '-data', workspace_dir,
          },

          root_dir = require('jdtls.setup').find_root { '.git', 'mvnw', 'gradlew', 'pom.xml', 'build.gradle' },

          settings = {
            java = {
              home = java_home,
              eclipse = { downloadSources = true },
              configuration = { updateBuildConfiguration = 'interactive' },
              maven = { downloadSources = true },
              implementationsCodeLens = { enabled = true },
              referencesCodeLens = { enabled = true },
              references = { includeDecompiledSources = true },
              signatureHelp = { enabled = true },
              format = { enabled = true },
              completion = {
                favoriteStaticMembers = {
                  'org.junit.Assert.*',
                  'org.junit.Assume.*',
                  'org.junit.jupiter.api.Assertions.*',
                  'org.junit.jupiter.api.Assumptions.*',
                  'org.mockito.Mockito.*',
                  'org.mockito.ArgumentMatchers.*',
                },
                importOrder = { 'java', 'javax', 'com', 'org' },
              },
              sources = {
                organizeImports = {
                  starThreshold = 9999,
                  staticStarThreshold = 9999,
                },
              },
              import = {
                gradle = { enabled = true },
                maven = { enabled = true },
              },
            },
          },

          init_options = { bundles = {} },

          on_attach = function(_, bufnr)
            local opts = { buffer = bufnr }
            vim.keymap.set('n', '<leader>jo', require('jdtls').organize_imports, vim.tbl_extend('force', opts, { desc = 'Organize imports' }))
            vim.keymap.set('n', '<leader>jv', require('jdtls').extract_variable, vim.tbl_extend('force', opts, { desc = 'Extract variable' }))
            vim.keymap.set('v', '<leader>jv', function() require('jdtls').extract_variable(true) end, vim.tbl_extend('force', opts, { desc = 'Extract variable' }))
            vim.keymap.set('v', '<leader>jm', function() require('jdtls').extract_method(true) end, vim.tbl_extend('force', opts, { desc = 'Extract method' }))
            vim.keymap.set('n', '<leader>jx', function()
              vim.fn.delete(workspace_dir, 'rf')
              vim.notify('jdtls cache cleared. Restart Neovim.', vim.log.levels.INFO)
            end, vim.tbl_extend('force', opts, { desc = 'Clear jdtls cache' }))
          end,

          capabilities = require('blink.cmp').get_lsp_capabilities(),
        }

        jdtls.start_or_attach(config)
      end

      -- Register autocommand for future Java files
      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'java',
        callback = start_jdtls,
      })

      -- Start immediately for current buffer
      start_jdtls()
    end,
  },
}
