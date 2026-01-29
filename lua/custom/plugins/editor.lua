-- Editor plugins and enhancements
return {
  -- Git integration
  { 'tpope/vim-fugitive' },

  -- Detect tabstop and shiftwidth automatically
  { 'NMAC427/guess-indent.nvim', opts = {} },

  -- Highlight todo, notes, etc in comments
  {
    'folke/todo-comments.nvim',
    event = 'VimEnter',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = { signs = false },
  },

  -- Better Around/Inside textobjects
  {
    'echasnovski/mini.ai',
    config = function()
      require('mini.ai').setup { n_lines = 500 }
    end,
  },

  -- Add/delete/replace surroundings
  {
    'echasnovski/mini.surround',
    config = function()
      require('mini.surround').setup()
    end,
  },

  -- File tree explorer (Neo-tree)
  {
    'nvim-neo-tree/neo-tree.nvim',
    version = '*',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons',
      'MunifTanjim/nui.nvim',
    },
    lazy = false,
    keys = {
      { '\\', ':Neotree reveal<CR>', desc = 'NeoTree reveal', silent = true },
    },
    opts = {
      filesystem = {
        window = {
          mappings = {
            ['\\'] = 'close_window',
          },
        },
      },
    },
  },
}
