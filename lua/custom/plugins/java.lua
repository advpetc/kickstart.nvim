-- Java LSP + Debug (DAP) configuration using nvim-jdtls
return {
  {
    'mfussenegger/nvim-jdtls',
    ft = 'java',
    dependencies = {
      'mfussenegger/nvim-dap',
      'rcarriga/nvim-dap-ui',
      'nvim-neotest/nvim-nio',
    },
    config = function()
      local java_home = '/Library/Java/JavaVirtualMachines/jdk21.0.6-msft.jdk/Contents/Home'
      local jdtls_path = vim.fn.stdpath 'data' .. '/mason/packages/jdtls'
      local mason_packages = vim.fn.stdpath 'data' .. '/mason/packages'

      -- ── Build debug bundles from Mason-installed packages ──────────
      local bundles = {}

      -- java-debug-adapter: single JAR
      local debug_jar = vim.fn.glob(mason_packages .. '/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar')
      if debug_jar ~= '' then
        table.insert(bundles, debug_jar)
      end

      -- java-test: multiple JARs (exclude the runner JAR which is loaded by jdtls itself)
      local test_jars = vim.fn.glob(mason_packages .. '/java-test/extension/server/*.jar', false, true)
      for _, jar in ipairs(test_jars) do
        if not vim.endswith(jar, 'com.microsoft.java.test.runner-jar-with-dependencies.jar') then
          table.insert(bundles, jar)
        end
      end

      -- ── Setup nvim-dap-ui (once) ──────────────────────────────────
      local dap = require 'dap'
      local dapui = require 'dapui'

      dapui.setup {
        icons = { expanded = '▾', collapsed = '▸', current_frame = '▸' },
      }

      -- Auto open/close the UI when a debug session starts/ends
      dap.listeners.after.event_initialized['dapui_config'] = function() dapui.open() end
      dap.listeners.before.event_terminated['dapui_config'] = function() dapui.close() end
      dap.listeners.before.event_exited['dapui_config'] = function() dapui.close() end

      -- ── Start jdtls per Java buffer ───────────────────────────────
      local function start_jdtls()
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

          root_dir = require('jdtls.setup').find_root { '.git', 'mvnw', 'gradlew', 'settings.gradle', 'settings.gradle.kts' },

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

          init_options = { bundles = bundles },

          on_attach = function(_, bufnr)
            local opts = { buffer = bufnr }

            -- ── Java-specific keymaps ─────────────────────────────
            vim.keymap.set('n', '<leader>jo', require('jdtls').organize_imports, vim.tbl_extend('force', opts, { desc = 'Organize imports' }))
            vim.keymap.set('n', '<leader>jv', require('jdtls').extract_variable, vim.tbl_extend('force', opts, { desc = 'Extract variable' }))
            vim.keymap.set('v', '<leader>jv', function() require('jdtls').extract_variable(true) end, vim.tbl_extend('force', opts, { desc = 'Extract variable' }))
            vim.keymap.set('v', '<leader>jm', function() require('jdtls').extract_method(true) end, vim.tbl_extend('force', opts, { desc = 'Extract method' }))
            vim.keymap.set('n', '<leader>jx', function()
              vim.fn.delete(workspace_dir, 'rf')
              vim.notify('jdtls cache cleared. Restart Neovim.', vim.log.levels.INFO)
            end, vim.tbl_extend('force', opts, { desc = 'Clear jdtls cache' }))

            -- ── Wire up DAP for this jdtls session ────────────────
            jdtls.setup_dap { hotcodereplace = 'auto' }

            -- ── Debug keymaps (buffer-local) ──────────────────────
            local map = function(keys, func, desc)
              vim.keymap.set('n', keys, func, { buffer = bufnr, desc = 'Debug: ' .. desc })
            end

            map('<leader>dc', dap.continue, 'Continue / Start')
            map('<leader>di', dap.step_into, 'Step into')
            map('<leader>do', dap.step_over, 'Step over')
            map('<leader>dO', dap.step_out, 'Step out')
            map('<leader>db', dap.toggle_breakpoint, 'Toggle breakpoint')
            map('<leader>dB', function() dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ') end, 'Conditional breakpoint')
            map('<leader>dl', function() dap.set_breakpoint(nil, nil, vim.fn.input 'Log point message: ') end, 'Log point')
            map('<leader>dr', dap.repl.open, 'Open REPL')
            map('<leader>du', dapui.toggle, 'Toggle debug UI')
            map('<leader>dt', jdtls.test_nearest_method, 'Test nearest method')
            map('<leader>dT', jdtls.test_class, 'Test class')
            map('<leader>dx', dap.terminate, 'Terminate')
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
