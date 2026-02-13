vim.keymap.set({"n"}, "<leader>c", function()
  require("calendar").open()
end, { desc = "Open calendar" })

vim.keymap.set({"i"}, "<leader>c", function()
  require("calendar").open()
  vim.api.nvim_input("<esc>")
end, { desc = "Open calendar in insert mode" })
