local PKB_ROOT = vim.env.PKB_ROOT
if not vim.env.PKB_ROOT then
    print("pkb.lua:Warning! $PKB_ROOT environment variable is not found!")
end
local DEVICE_IS_PHONE = vim.env.DEVICE_IS_PHONE == "true"
if not vim.env.DEVICE_IS_PHONE then
    print("pkb.lua:Warning! $DEVICE_IS_PHONE environment variable is not found!")
end
require("pkb").setup({
  pkb_root = PKB_ROOT,
  device_is_phone = DEVICE_IS_PHONE,
  default_notify = "15min",
  poll_interval = 30000, -- 30 seconds
})
local pkb = require("pkb.notifier")

-- run once at startup
vim.defer_fn(function()
  pkb.notify()
end, 100)

local timer

vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "*.md",
  callback = function(args)
    local path = vim.api.nvim_buf_get_name(args.buf)
    if path == "" then return end

    local pkb_root = vim.fn.expand("~/pkb")

    if not path:find(pkb_root, 1, true) then
      return
    end

    if timer then
      timer:stop()
    end

    timer = vim.defer_fn(function()
      pkb.notify()
    end, 500)
  end,
})

