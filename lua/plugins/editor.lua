-- Editor plugins
return {
  -- Detect tabstop and shiftwidth automatically
  'NMAC427/guess-indent.nvim',

  -- Git integration with vim-fugitive
  'tpope/vim-fugitive',

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
            local fileinfo = MiniStatusline.section_fileinfo({ trunc_width = 120 })
            local location = '%2l:%-2v'

            -- Abbreviated filename
            local path = vim.fn.expand('%:~:.')
            local filename = '[No Name]'
            if path ~= '' then
              local name = vim.fn.fnamemodify(path, ':t')
              local dir = vim.fn.fnamemodify(path, ':h')
              if dir == '.' then
                filename = name
              else
                filename = dir:gsub('([^/])[^/]*/', '%1/') .. '/' .. name
              end
            end

            -- Get navic context (current method/class)
            local navic = require('nvim-navic')
            local context = ''
            if navic.is_available() then
              context = navic.get_location()
            end

            return MiniStatusline.combine_groups({
              { hl = mode_hl, strings = { mode } },
              { hl = 'MiniStatuslineDevinfo', strings = { git, diagnostics } },
              '%<',
              { hl = 'MiniStatuslineFilename', strings = { filename } },
              '%=',
              { hl = 'MiniStatuslineFileinfo', strings = { context } },
              { hl = 'MiniStatuslineFileinfo', strings = { fileinfo } },
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
