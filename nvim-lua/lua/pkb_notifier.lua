-- PKB Notifier — queued, focus-safe, Neovim-native

local M = {}

-- CONFIG
M.PKB_ROOT = "/home/eelis/pkb"  -- <<< change this
M.DEFAULT_NOTIFY = "15min"

-- STATE
M.notifications = {}
M.popup_queue = {}
M.popup_active = false

-- HELPERS
local function parse_iso(ts)
  local y, m, d, H, M_ = ts:match("(%d+)%-(%d+)%-(%d+)T(%d+):(%d+)")
  if not y then return nil end
  return os.time({
    year  = tonumber(y),
    month = tonumber(m),
    day   = tonumber(d),
    hour  = tonumber(H),
    min   = tonumber(M_),
  })
end

local function parse_notify(str)
  local n = tonumber(str:match("(%d+)"))
  if not n then return 0 end
  if str:match("min") then return n * 60 end
  if str:match("h")   then return n * 3600 end
  if str:match("day") then return n * 86400 end
  return 0
end

-- POPUP QUEUE LOGIC
local function show_next_popup()
  if M.popup_active then return end

  local entry = table.remove(M.popup_queue, 1)
  if not entry then return end

  M.popup_active = true

  vim.schedule(function()
    if vim.fn.mode() ~= "n" then
      vim.cmd("stopinsert")
    end

    local buf = vim.api.nvim_create_buf(false, true)

    local lines = {
      "🔔 PKB Task Notification",
      "",
      entry.line,
      "",
      "File: " .. entry.file,
      "Due:  " .. os.date("%Y-%m-%d %H:%M", entry.due_ts),
      "",
      "[Enter] open  |  [d] dismiss  |  [q] close",
    }

    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.bo[buf].modifiable = false
    vim.bo[buf].bufhidden = "wipe"

    local width  = math.min(90, vim.o.columns - 4)
    local height = #lines + 2
    local row    = math.floor((vim.o.lines - height) / 2)
    local col    = math.floor((vim.o.columns - width) / 2)

    local win = vim.api.nvim_open_win(buf, true, {
      relative = "editor",
      width = width,
      height = height,
      row = row,
      col = col,
      border = "rounded",
      style = "minimal",
    })

    vim.api.nvim_set_current_win(win)

    local function close_popup()
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
      end
      M.popup_active = false
      show_next_popup()
    end

    vim.keymap.set("n", "<CR>", function()
      close_popup()
      vim.cmd("edit " .. vim.fn.fnameescape(entry.file))
      vim.fn.search(vim.fn.escape(entry.line, "\\/.*$^~[]"), "W")
    end, { buffer = buf })

    vim.keymap.set("n", "d", function()
      entry.dismissed = true
      close_popup()
    end, { buffer = buf })

    vim.keymap.set("n", "q", close_popup, { buffer = buf })
  end)
end

-- SCHEDULING
local function schedule_notification(entry)
  local delay = entry.notify_ts - os.time()
  if delay < 0 then delay = 0 end

  vim.defer_fn(function()
    if entry.dismissed then return end
    entry.triggered = true
    table.insert(M.popup_queue, entry)
    show_next_popup()
  end, delay * 1000)
end

-- PARSE LINE
local function parse_line(line, file)
  local due_str = line:match("due::([%dT:%-]+)")
  if not due_str then return end

  local notify_str = line:match("notify::([%w]+)") or M.DEFAULT_NOTIFY

  local due_ts = parse_iso(due_str)
  if not due_ts then return end

  local notify_ts = due_ts - parse_notify(notify_str)

  local entry = {
    line = line,
    file = file,
    due_ts = due_ts,
    notify_ts = notify_ts,
    triggered = false,
    dismissed = false,
  }

  table.insert(M.notifications, entry)
  schedule_notification(entry)
end

-- SCAN FILES
local function scan_file(file)
  local ok, lines = pcall(vim.fn.readfile, file)
  if not ok then return end
  for _, line in ipairs(lines) do
    parse_line(line, file)
  end
end

local function scan_dir(path)
  local handle = vim.loop.fs_scandir(path)
  if not handle then return end

  while true do
    local name, typ = vim.loop.fs_scandir_next(handle)
    if not name then break end
    local full = path .. "/" .. name

    if typ == "file" and name:match("%.md$") then
      scan_file(full)
    elseif typ == "directory" then
      scan_dir(full)
    end
  end
end

-- COMMANDS
function M.notify()
  M.notifications = {}
  M.popup_queue = {}
  M.popup_active = false
  scan_dir(M.PKB_ROOT)
  print("PKB notifications scheduled: " .. #M.notifications)
end

function M.inbox()
  if #M.notifications == 0 then
    vim.notify("No PKB notifications", vim.log.levels.INFO)
    return
  end

  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = "wipe"

  local function render()
    local items = {}

    -- collect + filter
    for _, n in ipairs(M.notifications) do
      -- skip done tasks
      if not n.line:match("^%s*%- %[[xX]%]") then
        -- default: hide dismissed
        if M.inbox_show_all or not n.dismissed then
          table.insert(items, n)
        end
      end
    end

    -- sort by urgency (earlier due first)
    table.sort(items, function(a, b)
      return a.due_ts < b.due_ts
    end)

    local lines = {}
    for _, n in ipairs(items) do
      local status =
        n.dismissed and "[x]" or
        n.triggered and "[!]" or
        "[ ]"

      table.insert(lines,
        string.format(
          "%s %s | %s | due %s",
          status,
          n.line,
          n.file,
          os.date("%Y-%m-%d %H:%M", n.due_ts)
        )
      )
    end

    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  end

  render()
  vim.api.nvim_set_current_buf(buf)

  -- d - dismiss
  vim.keymap.set("n", "d", function()
    local idx = vim.fn.line(".")
    local visible = {}

    for _, n in ipairs(M.notifications) do
      if not n.line:match("^%s*%- %[[xX]%]") then
        if M.inbox_show_all or not n.dismissed then
          table.insert(visible, n)
        end
      end
    end

    table.sort(visible, function(a, b)
      return a.due_ts < b.due_ts
    end)

    local n = visible[idx]
    if n then
      n.dismissed = true
      render()
    end
  end, { buffer = buf })

  -- <CR> - open task
  vim.keymap.set("n", "<CR>", function()
    local idx = vim.fn.line(".")
    local visible = {}

    for _, n in ipairs(M.notifications) do
      if not n.line:match("^%s*%- %[[xX]%]") then
        if M.inbox_show_all or not n.dismissed then
          table.insert(visible, n)
        end
      end
    end

    table.sort(visible, function(a, b)
      return a.due_ts < b.due_ts
    end)

    local n = visible[idx]
    if not n then return end

    vim.cmd("edit " .. vim.fn.fnameescape(n.file))
    vim.fn.search(vim.fn.escape(n.line, "\\/.*$^~[]"), "W")
  end, { buffer = buf })

  -- t - toggle view (this is the important one)
  vim.keymap.set("n", "t", function()
    M.inbox_show_all = not M.inbox_show_all
    render()
  end, { buffer = buf })

  -- q - close
  vim.keymap.set("n", "q", function()
    vim.api.nvim_buf_delete(buf, { force = true })
  end, { buffer = buf })
end

-- SETUP
vim.api.nvim_create_user_command("PKBNotify", M.notify, {})
vim.api.nvim_create_user_command("PKBInbox",  M.inbox,  {})

return M
