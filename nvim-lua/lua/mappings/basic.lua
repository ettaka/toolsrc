map = vim.api.nvim_set_keymap

-- Moving between windows
map('n', '<C-j>', '<C-w><C-j>:res<cr>', {})
map('n', '<C-k>', '<C-w><C-k>:res<cr>', {})
map('n', '<C-h>', '<C-w><C-h>:res<cr>', {})
map('n', '<C-l>', '<C-w><C-l>:res<cr>', {})

-- Exit terminal
map('t', '<leader><esc>', '<C-\\><C-N>', {})
