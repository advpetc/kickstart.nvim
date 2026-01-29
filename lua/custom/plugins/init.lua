-- Custom plugins entry point
-- This file imports all custom plugin modules

return {
  { import = 'custom.plugins.appearance' },
  { import = 'custom.plugins.keymappings' },
  { import = 'custom.plugins.lsp' },
  { import = 'custom.plugins.completion' },
  { import = 'custom.plugins.treesitter' },
  { import = 'custom.plugins.formatting' },
  { import = 'custom.plugins.java' },
  { import = 'custom.plugins.editor' },
}
