vim.keymap.set("n", "<leader>t", vim.cmd.Ex)
vim.keymap.set("n", "<leader>ev", function () vim.cmd("vsp ~/.config/nvim/init.lua") end)
vim.keymap.set("n", "<C-h>", "<C-w>h:res<CR>")
vim.keymap.set("n", "<C-j>", "<C-w>j:res<CR>")
vim.keymap.set("n", "<C-k>", "<C-w>k:res<CR>")
vim.keymap.set("n", "<C-l>", "<C-w>l:res<CR>")

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
