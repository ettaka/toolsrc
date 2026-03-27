-- need to install
-- sudo apt install zathura
-- sudo apt install texlive-xetex
vim.keymap.set("n", "<leader>pv", function()
  vim.cmd("write")

  local input = vim.fn.expand("%:p")        -- full path to current file
  local root = vim.fn.getcwd()              -- current working dir
  local filename = vim.fn.expand("%:t:r")   -- file name without extension
  local output = root .. "/output/" .. filename .. ".pdf"

  local cmd = "pandoc '" .. input .. "' -o '" .. output .. "' --pdf-engine=xelatex"

  vim.cmd("!" .. cmd)
  vim.cmd("redraw!")

  vim.fn.jobstart({ "zathura", output }, { detach = true })
end)
