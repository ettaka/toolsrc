local PKB_ROOT = vim.env.PKB_ROOT
if not vim.env.PKB_ROOT then
    print("pkb.lua:Warning! $PKB_ROOT environment variable is not found!")
end
local DEVICE_IS_PHONE = vim.env.DEVICE_IS_PHONE == "true"
if not vim.env.DEVICE_IS_PHONE then
    print("pkb.lua:Warning! $DEVICE_IS_PHONE environment variable is not found!")
end
local notifier = require("pkb.notifier")
notifier.setup({
  pkb_root = PKB_ROOT,
  device_is_phone = DEVICE_IS_PHONE,
  default_notify = "15min",
  poll_interval = 30000, -- 30 seconds
  default_horizon = 180
})

-- run once at startup
vim.defer_fn(function()
  notifier.notify()
end, 100)

-- Rescan just the saved note. pkb-nvim batches saves within 500 ms and ignores files outside PKB_ROOT.
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "*.md",
  callback = function(args)
    local path = vim.api.nvim_buf_get_name(args.buf)
    if path ~= "" then
      notifier.queue_rescan(path)
    end
  end,
})
