-- Java LSP configuration using nvim-jdtls
return {
  {
    'mfussenegger/nvim-jdtls',
    ft = 'java',
    dependencies = {
      'mason-org/mason.nvim',
    },
    config = function()
      local jdtls = require 'jdtls'
      local mason_registry = require 'mason-registry'

      -- Find jdtls installation path from Mason
      local jdtls_pkg = mason_registry.get_package 'jdtls'
      local jdtls_path = jdtls_pkg:get_install_path()
      local launcher_jar = vim.fn.glob(jdtls_path .. '/plugins/org.eclipse.equinox.launcher_*.jar')
      local config_dir = jdtls_path .. '/config_mac_arm'

      -- JDK paths
      local java_home = '/Library/Java/JavaVirtualMachines/jdk21.0.6-msft.jdk/Contents/Home'

      -- Workspace directory (unique per project)
      local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
      local workspace_dir = vim.fn.expand '~/.local/share/nvim/jdtls-workspace/' .. project_name

      -- jdtls configuration
      local config = {
        cmd = {
          java_home .. '/bin/java',
          '-Declipse.application=org.eclipse.jdt.ls.core.id1',
          '-Dosgi.bundles.defaultStartLevel=4',
          '-Declipse.product=org.eclipse.jdt.ls.core.product',
          '-Dlog.protocol=true',
          '-Dlog.level=ALL',
          -- Performance optimizations
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
                'org.junit.jupiter.api.DynamicContainer.*',
                'org.junit.jupiter.api.DynamicTest.*',
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

        init_options = {
          bundles = {},
        },

        on_attach = function(client, bufnr)
          -- Enable jdtls-specific commands
          local opts = { buffer = bufnr, desc = '' }

          opts.desc = 'Organize imports'
          vim.keymap.set('n', '<leader>jo', jdtls.organize_imports, opts)

          opts.desc = 'Extract variable'
          vim.keymap.set('n', '<leader>jv', jdtls.extract_variable, opts)
          vim.keymap.set('v', '<leader>jv', function() jdtls.extract_variable(true) end, opts)

          opts.desc = 'Extract constant'
          vim.keymap.set('n', '<leader>jc', jdtls.extract_constant, opts)
          vim.keymap.set('v', '<leader>jc', function() jdtls.extract_constant(true) end, opts)

          opts.desc = 'Extract method'
          vim.keymap.set('v', '<leader>jm', function() jdtls.extract_method(true) end, opts)

          opts.desc = 'Clear jdtls cache'
          vim.keymap.set('n', '<leader>jx', function()
            vim.fn.delete(workspace_dir, 'rf')
            vim.notify('jdtls cache cleared. Restart Neovim.', vim.log.levels.INFO)
          end, opts)
        end,

        capabilities = require('blink.cmp').get_lsp_capabilities(),
      }

      -- Start jdtls
      local function start_jdtls()
        -- Check if jdtls is installed
        if not jdtls_pkg:is_installed() then
          vim.notify('jdtls not installed. Run :MasonInstall jdtls', vim.log.levels.WARN)
          return
        end
        jdtls.start_or_attach(config)
      end

      -- Auto-start for Java files
      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'java',
        callback = start_jdtls,
      })

      -- Start immediately if we're already in a Java file
      if vim.bo.filetype == 'java' then
        start_jdtls()
      end
    end,
  },
}
