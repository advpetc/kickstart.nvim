-- OSC 52 clipboard support for remote SSH sessions
-- Works without X11 forwarding in modern terminals (iTerm2, WezTerm, Alacritty, Windows Terminal)
return {
  {
    'ojroques/nvim-osc52',
    config = function()
      require('osc52').setup {
        max_length = 0, -- Maximum length of selection (0 for no limit)
        silent = false, -- Disable message on successful copy
        trim = false, -- Trim text before copy
      }

      -- Auto-copy ALL yanks to system clipboard via OSC 52
      local function copy()
        if vim.v.event.operator == 'y' then
          -- Copy from the register that was yanked to
          local register = vim.v.event.regname
          if register == '' then
            -- Default register, use unnamed register
            require('osc52').copy_register '"'
          else
            require('osc52').copy_register(register)
          end
        end
      end

      vim.api.nvim_create_autocmd('TextYankPost', { callback = copy })

      -- Manual copy keymap (copies visual selection to system clipboard)
      vim.keymap.set('v', '<leader>y', require('osc52').copy_visual, { desc = 'Copy to system clipboard (OSC52)' })
    end,
  },
}
