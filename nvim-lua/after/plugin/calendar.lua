vim.keymap.set("n", "<leader>c", function()
  require("calendar").open()
end, { desc = "Open calendar" })
