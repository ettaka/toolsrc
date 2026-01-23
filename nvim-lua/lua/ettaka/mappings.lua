vim.keymap.set("n", "<leader>ev", function () vim.cmd("vsp ~/.config/nvim/") end)
vim.keymap.set("n", "<leader>a", function () vim.cmd("vsp"); vim.cmd("Alpha") end)
vim.keymap.set("n", "<C-h>", "`A")
vim.keymap.set("n", "<C-j>", "`S")
vim.keymap.set("n", "<C-k>", "`D")
vim.keymap.set("n", "<C-l>", "`F")
vim.keymap.set("n", "<CR>", ":nohlsearch<CR><CR>")
vim.keymap.set("t", "<leader><Esc>", "<C-\\><C-n>")

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.env.PATH=vim.env.PATH..":"..vim.env.HOME.."/.config/nvim/bin/"

-- Define a kqc command
vim.cmd('command! -nargs=0 Kqc execute "!klayout -e -rm /home/eelis/git/KQCircuits/util/create_element_from_path.py -rd element_path=" . expand("%:p") | redraw!')
-- Create a mapping to run the kqc command
vim.cmd("nnoremap <leader>kqc :Kqc<CR>")

local function insert_timestamp()
  local timestamp = os.date("%Y-%m-%dT%H:%M")
  vim.api.nvim_put({ timestamp }, "c", true, true)
end

vim.keymap.set("n", "<leader>ts", insert_timestamp, { desc = "Insert timestamp" })
