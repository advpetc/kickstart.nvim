-- Editor plugins
return {
  -- Detect tabstop and shiftwidth automatically
  'NMAC427/guess-indent.nvim',

  -- Git integration with vim-fugitive
  'tpope/vim-fugitive',

  -- Session management (restore previous buffers)
  {
    'folke/persistence.nvim',
    event = 'BufReadPre',
    opts = {},
    keys = {
      { '<leader>qs', function() require('persistence').load() end, desc = 'Restore session' },
      { '<leader>ql', function() require('persistence').load({ last = true }) end, desc = 'Restore last session' },
      { '<leader>qd', function() require('persistence').stop() end, desc = "Don't save session" },
    },
    init = function()
      -- Auto-restore session on startup
      vim.api.nvim_create_autocmd('VimEnter', {
        group = vim.api.nvim_create_augroup('persistence-autoload', { clear = true }),
        callback = function()
          if vim.fn.argc() == 0 and not vim.g.started_with_stdin then
            require('persistence').load()
          end
        end,
        nested = true,
      })
    end,
  },

  -- Which-key for keybinding hints
  {
    'folke/which-key.nvim',
    event = 'VimEnter',
    opts = {
      delay = 0,
      icons = {
        mappings = vim.g.have_nerd_font,
        keys = vim.g.have_nerd_font and {} or {
          Up = '<Up> ', Down = '<Down> ', Left = '<Left> ', Right = '<Right> ',
          C = '<C-…> ', M = '<M-…> ', D = '<D-…> ', S = '<S-…> ',
          CR = '<CR> ', Esc = '<Esc> ', ScrollWheelDown = '<ScrollWheelDown> ',
          ScrollWheelUp = '<ScrollWheelUp> ', NL = '<NL> ', BS = '<BS> ',
          Space = '<Space> ', Tab = '<Tab> ',
          F1 = '<F1>', F2 = '<F2>', F3 = '<F3>', F4 = '<F4>',
          F5 = '<F5>', F6 = '<F6>', F7 = '<F7>', F8 = '<F8>',
          F9 = '<F9>', F10 = '<F10>', F11 = '<F11>', F12 = '<F12>',
        },
      },
      spec = {
        { '<leader>s', group = '[S]earch' },
        { '<leader>t', group = '[T]oggle' },
        { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
      },
    },
  },

  -- Highlight todo, notes, etc in comments
  {
    'folke/todo-comments.nvim',
    event = 'VimEnter',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = { signs = false },
  },

  -- Code context (shows current class/method in statusline)
  {
    'SmiteshP/nvim-navic',
    dependencies = { 'neovim/nvim-lspconfig' },
    opts = {
      lsp = { auto_attach = true },
      highlight = true,
      separator = ' > ',
      depth_limit = 3,
    },
  },

  -- Mini.nvim collection
  {
    'echasnovski/mini.nvim',
    dependencies = { 'SmiteshP/nvim-navic' },
    config = function()
      require('mini.ai').setup { n_lines = 500 }
      require('mini.surround').setup()

      local statusline = require 'mini.statusline'
      statusline.setup {
        use_icons = vim.g.have_nerd_font,
        content = {
          active = function()
            local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = 120 })
            local git = MiniStatusline.section_git({ trunc_width = 75 })
            local diagnostics = MiniStatusline.section_diagnostics({ trunc_width = 75 })
            local location = '%2l:%-2v'

            -- Just filename without path
            local filename = vim.fn.expand('%:t')
            if filename == '' then filename = '[No Name]' end

            -- Get navic context (current method/class)
            local navic = require('nvim-navic')
            local context = ''
            if navic.is_available() then
              context = navic.get_location()
            end

            -- File type and encoding (without path)
            local filetype = vim.bo.filetype
            local encoding = vim.bo.fileencoding or vim.o.encoding

            return MiniStatusline.combine_groups({
              { hl = mode_hl, strings = { mode } },
              { hl = 'MiniStatuslineDevinfo', strings = { git, diagnostics } },
              '%<',
              { hl = 'MiniStatuslineFilename', strings = { filename } },
              '%=',
              { hl = 'MiniStatuslineFileinfo', strings = { context } },
              { hl = 'MiniStatuslineFileinfo', strings = { filetype, encoding } },
              { hl = mode_hl, strings = { location } },
            })
          end,
        },
      }
    end,
  },

  -- Treesitter
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter').setup {
        ensure_installed = {
          'bash', 'c', 'diff', 'html', 'lua', 'luadoc',
          'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc',
          'java', 'groovy', 'kotlin',
        },
        auto_install = true,
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = { 'ruby' },
        },
        indent = { enable = true, disable = { 'ruby' } },
      }
    end,
  },

  -- File explorer
  require 'kickstart.plugins.neo-tree',
}
