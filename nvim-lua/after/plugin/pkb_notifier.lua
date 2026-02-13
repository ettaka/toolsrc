local pkb = require("pkb_notifier")

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

