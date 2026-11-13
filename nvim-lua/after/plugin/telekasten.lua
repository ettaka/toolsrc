local PKB_ROOT = vim.fn.expand(vim.env.PKB_ROOT or "~/pkb")

require('telekasten').setup({
  home = PKB_ROOT,
  template_new_note = PKB_ROOT .. "/templates/template.md",
  template_new_daily = PKB_ROOT .. "/templates/daily.md",
  template_new_weekly = PKB_ROOT .. "/templates/weekly.md",
  template_new_monthly = PKB_ROOT .. "/templates/monthly.md",
  auto_set_filetype = false, 
})

-- Telekasten panel (not plain <leader>z: that would wait for the timeout before every <leader>z... map)
vim.keymap.set("n", "<leader>zp", "<cmd>Telekasten panel<CR>", { desc = "Telekasten panel" })

-- Most used functions
vim.keymap.set("n", "<leader>zf", "<cmd>Telekasten find_notes<CR>")
vim.keymap.set("n", "<leader>zg", "<cmd>Telekasten search_notes<CR>")
vim.keymap.set("n", "<leader>zd", "<cmd>Telekasten goto_today<CR>")
-- Follow link: pkb-nvim opens [text](path) file links relative to the note and [[../path]] links (Telekasten would
-- hand a relative path to xdg-open from Neovim's working directory); everything else goes to Telekasten.
local function follow_link()
  local ok, links = pcall(require, "pkb.links")
  if ok and links.follow() then return end
  vim.cmd("Telekasten follow_link")
end
vim.keymap.set("n", "<leader>zz", follow_link, { desc = "Follow link (files relative to the note, else Telekasten)" })
vim.keymap.set("n", "<leader>zn", "<cmd>Telekasten new_note<CR>")
vim.keymap.set("n", "<leader>zc", "<cmd>Telekasten show_calendar<CR>")
vim.keymap.set("n", "<leader>zb", "<cmd>Telekasten show_backlinks<CR>")
vim.keymap.set("n", "<leader>zI", "<cmd>Telekasten insert_img_link<CR>")
vim.keymap.set("n", "<leader>zt", "<cmd>Telekasten search_notes<CR><esc>diwi- \\[ \\].*#task.*#work")

vim.api.nvim_create_autocmd("FileType", {
  pattern = "telekasten",
  command = "set syntax=markdown",
})
