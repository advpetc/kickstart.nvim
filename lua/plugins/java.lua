-- Java (jdtls) Configuration
-- Standalone setup without nvim-lspconfig's jdtls module
return {
  'saghen/blink.cmp',  -- Just need this for capabilities
  ft = { 'java' },
  config = function()
    local capabilities = require('blink.cmp').get_lsp_capabilities()

    vim.api.nvim_create_autocmd('FileType', {
      pattern = 'java',
      callback = function()
        local jdtls_path = vim.fn.stdpath 'data' .. '/mason/packages/jdtls'

        -- Find project root
        local root_markers = { '.git', 'pom.xml', 'build.gradle', 'build.gradle.kts', 'settings.gradle', 'settings.gradle.kts', 'mvnw', 'gradlew' }
        local root_dir = vim.fs.dirname(vim.fs.find(root_markers, { upward = true })[1]) or vim.fn.getcwd()

        local project_name = vim.fn.fnamemodify(root_dir, ':t')
        local workspace_dir = vim.fn.stdpath 'data' .. '/jdtls-workspace/' .. project_name
        vim.fn.mkdir(workspace_dir, 'p')

        local launcher = vim.fn.glob(jdtls_path .. '/plugins/org.eclipse.equinox.launcher_*.jar')
        if launcher == '' then
          vim.notify('jdtls launcher not found. Run :Mason to install jdtls', vim.log.levels.ERROR)
          return
        end

        local config = {
          name = 'jdtls',
          cmd = {
            'java',
            '-Declipse.application=org.eclipse.jdt.ls.core.id1',
            '-Dosgi.bundles.defaultStartLevel=4',
            '-Declipse.product=org.eclipse.jdt.ls.core.product',
            '-Dlog.protocol=true',
            '-Dlog.level=ALL',
            '-Xmx4g',
            '--add-modules=ALL-SYSTEM',
            '--add-opens', 'java.base/java.util=ALL-UNNAMED',
            '--add-opens', 'java.base/java.lang=ALL-UNNAMED',
            '-jar', launcher,
            '-configuration', jdtls_path .. '/config_mac_arm',
            '-data', workspace_dir,
          },
          root_dir = root_dir,
          settings = {
            java = {
              signatureHelp = { enabled = true },
              contentProvider = { preferred = 'fernflower' },
              completion = {
                favoriteStaticMembers = {
                  'org.junit.jupiter.api.Assertions.*',
                  'org.junit.Assert.*',
                  'org.mockito.Mockito.*',
                },
              },
              sources = {
                organizeImports = {
                  starThreshold = 9999,
                  staticStarThreshold = 9999,
                },
              },
              import = {
                gradle = { enabled = false },
                maven = { enabled = true },
              },
              autobuild = { enabled = false },
            },
          },
          capabilities = capabilities,
          init_options = {
            bundles = {},
          },
        }

        vim.lsp.start(config)
      end,
    })

    -- Command and keymap to clear jdtls cache and re-index
    vim.api.nvim_create_user_command('JdtlsClearCache', function()
      local root_markers = { '.git', 'pom.xml', 'build.gradle', 'build.gradle.kts', 'settings.gradle', 'settings.gradle.kts', 'mvnw', 'gradlew' }
      local root_dir = vim.fs.dirname(vim.fs.find(root_markers, { upward = true })[1]) or vim.fn.getcwd()
      local project_name = vim.fn.fnamemodify(root_dir, ':t')
      local workspace_dir = vim.fn.stdpath 'data' .. '/jdtls-workspace/' .. project_name

      vim.lsp.stop_client(vim.lsp.get_clients({ name = 'jdtls' }))
      vim.fn.delete(workspace_dir, 'rf')
      vim.notify('Cleared jdtls cache: ' .. workspace_dir, vim.log.levels.INFO)
      vim.cmd('edit')
    end, {})

    vim.keymap.set('n', '<leader>jc', '<cmd>JdtlsClearCache<CR>', { desc = '[J]dtls [C]lear cache and re-index' })
  end,
}
