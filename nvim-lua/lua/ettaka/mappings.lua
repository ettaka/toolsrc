vim.keymap.set("n", "<leader>ev", function () vim.cmd("vsp ~/.config/nvim/") end)
vim.keymap.set("n", "<leader>A", function () vim.cmd("vsp"); vim.cmd("Alpha") end, { desc = "Alpha dashboard in a split" })
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
local KQC = vim.env.KQC or vim.fn.expand("~/git/KQCircuits") -- $KQC is set in zsh/set_kqcircuits.sh
vim.api.nvim_create_user_command("Kqc", function()
  vim.cmd("!klayout -e -rm " .. vim.fn.shellescape(KQC .. "/util/create_element_from_path.py")
    .. " -rd element_path=" .. vim.fn.shellescape(vim.fn.expand("%:p")))
  vim.cmd("redraw!")
end, { nargs = 0 })
-- Create a mapping to run the kqc command
vim.cmd("nnoremap <leader>kqc :Kqc<CR>")

-- dd removes an entry from quickfix list
vim.api.nvim_create_autocmd("FileType", {
  pattern = "qf",
  callback = function()
    vim.keymap.set("n", "dd", function()
      local qf = vim.fn.getqflist()
      table.remove(qf, vim.fn.line("."))
      vim.fn.setqflist(qf, "r")
      vim.cmd("copen")
    end, { buffer = true })
  end,
})

