-- need to install
-- sudo apt install zathura
-- sudo apt install texlive-xetex
vim.keymap.set("n", "<leader>pv", function()
  vim.cmd("write")

  local input = vim.fn.expand("%:p")
  local root = vim.fn.getcwd()
  local filename = vim.fn.expand("%:t:r")
  local output_dir = root .. "/output"
  local output = output_dir .. "/" .. filename .. ".pdf"

  vim.fn.mkdir(output_dir, "p")

  local cmd = "pandoc '" .. input .. "' -o '" .. output .. "' --pdf-engine=xelatex"

  -- run and SHOW output
  vim.cmd("!" .. cmd)

  -- only open if file exists
  if vim.fn.filereadable(output) == 1 then
    vim.fn.jobstart({ "zathura", output }, { detach = true })
  else
    print("PDF not generated — check errors above")
  end
end)
