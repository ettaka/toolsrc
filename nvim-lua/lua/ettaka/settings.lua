local DEVICE_IS_PHONE = false
if DEVICE_IS_PHONE then
  vim.g.mapleader = ","
else
  vim.g.mapleader = "\\"
end

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.nu = true

vim.opt.smartindent = true

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.nvim/undodir"
vim.opt.undofile = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 10
vim.opt.colorcolumn = "120"
