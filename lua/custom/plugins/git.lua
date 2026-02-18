-- Git diff viewer
return {
  {
    'sindrets/diffview.nvim',
    cmd = { 'DiffviewOpen', 'DiffviewFileHistory' },
    keys = {
      { '<leader>gd', '<cmd>DiffviewOpen<cr>', desc = 'Git diff view' },
      { '<leader>gh', '<cmd>DiffviewFileHistory %<cr>', desc = 'Git file history' },
      { '<leader>gH', '<cmd>DiffviewFileHistory<cr>', desc = 'Git branch history' },
      { '<leader>gc', '<cmd>DiffviewClose<cr>', desc = 'Close diff view' },
      { '<leader>gR', '<cmd>!git reset --hard<cr>', desc = 'Git reset --hard (entire repo)' },
      { '<leader>gr', '<cmd>!git reset<cr>', desc = 'Git reset (unstage all, keep changes)' },
    },
    opts = {
      enhanced_diff_hl = true,
      view = {
        default = { layout = 'diff2_horizontal' },
        merge_tool = { layout = 'diff3_horizontal' },
      },
    },
  },
}
