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
vim.keymap.set("n", "<leader>zz", "<cmd>Telekasten follow_link<CR>")
vim.keymap.set("n", "<leader>zn", "<cmd>Telekasten new_note<CR>")
vim.keymap.set("n", "<leader>zc", "<cmd>Telekasten show_calendar<CR>")
vim.keymap.set("n", "<leader>zb", "<cmd>Telekasten show_backlinks<CR>")
vim.keymap.set("n", "<leader>zI", "<cmd>Telekasten insert_img_link<CR>")
vim.keymap.set("n", "<leader>zt", "<cmd>Telekasten search_notes<CR><esc>diwi- \\[ \\].*#task.*#work")

vim.api.nvim_create_autocmd("FileType", {
  pattern = "telekasten",
  command = "set syntax=markdown",
})
