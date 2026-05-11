local is_mac = vim.fn.has 'macunix' == 1

if not is_mac then
  return
end

-- Terminal flow control often swallows <C-s> and <C-q> on macOS terminals.
-- Keep the existing mappings and add macOS-only fallbacks that always work.
vim.keymap.set('n', '<leader>w', '<cmd>w<CR>', { noremap = true, silent = false, desc = 'Save file' })
vim.keymap.set('n', '<leader>W', '<cmd>noautocmd w<CR>', { noremap = true, silent = false, desc = 'Save file without autocmds' })
vim.keymap.set('n', '<leader>Q', '<cmd>q<CR>', { noremap = true, silent = false, desc = 'Quit file' })
