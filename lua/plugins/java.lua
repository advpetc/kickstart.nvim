-- Java (jdtls) Configuration
return {
  'neovim/nvim-lspconfig',
  ft = { 'java' },
  dependencies = {
    'neovim/nvim-lspconfig',
    'saghen/blink.cmp',
  },
  config = function()
    local capabilities = require('blink.cmp').get_lsp_capabilities()

    vim.api.nvim_create_autocmd('FileType', {
      pattern = 'java',
      callback = function()
        local jdtls_path = vim.fn.stdpath 'data' .. '/mason/packages/jdtls'

        local root_dir = require('lspconfig.util').root_pattern(
          '.git', 'pom.xml', 'build.gradle', 'build.gradle.kts',
          'settings.gradle', 'settings.gradle.kts', 'mvnw', 'gradlew'
        )(vim.api.nvim_buf_get_name(0)) or vim.fn.getcwd()

        local project_name = vim.fn.fnamemodify(root_dir, ':t')
        local workspace_dir = vim.fn.stdpath 'data' .. '/jdtls-workspace/' .. project_name
        vim.fn.mkdir(workspace_dir, 'p')

        local launcher = vim.fn.glob(jdtls_path .. '/plugins/org.eclipse.equinox.launcher_*.jar')
        if launcher == '' then
          vim.notify('jdtls launcher not found. Run :Mason to install jdtls', vim.log.levels.ERROR)
          return
        end

        local config = {
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
  end,
}
