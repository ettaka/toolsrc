vim.keymap.set(
  "n",
  "<leader>zs",
  function() require("pkb_sync").smart_sync() end,
  {desc="Smart PKB Sync"}
)
