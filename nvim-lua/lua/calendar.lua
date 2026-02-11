local M = {}

-- State
local state = {
  year = nil,
  month = nil,
  day = nil,
}

local buf, win
local origin_buf, origin_win

-- ---------- helpers ----------

local function days_in_month(year, month)
  return tonumber(os.date("%d", os.time { year = year, month = month + 1, day = 0 }))
end

local function first_weekday(year, month)
  return tonumber(os.date("%w", os.time { year = year, month = month, day = 1 }))
end

local function clamp_day()
  local max_day = days_in_month(state.year, state.month)
  if state.day > max_day then state.day = max_day end
  if state.day < 1 then state.day = 1 end
end

local function date_str()
  return string.format("%04d-%02d-%02d", state.year, state.month, state.day)
end

-- ---------- rendering ----------

local function render()
  local lines = {}
  table.insert(lines, os.date(" %B %Y", os.time {
    year = state.year,
    month = state.month,
    day = 1,
  }))
  table.insert(lines, " Su  Mo  Tu  We  Th  Fr  Sa")

  local start_wday = first_weekday(state.year, state.month)
  local week = {}

  local today = os.date("*t")
  local total_days = days_in_month(state.year, state.month)

  for _ = 1, start_wday do
    table.insert(week, "    ")
  end

  for day = 1, total_days do
    local label = string.format("%2d", day)

    if day == state.day then
      label = "[" .. string.format("%2d", day) .. "]"
    else
      if day == today.day
        and state.month == today.month
        and state.year == today.year then
        label = "•" .. string.format("%2d", day) .. " "
      else
        label = " " .. string.format("%2d", day) .. " "
      end
    end

    table.insert(week, label)

    if #week == 7 then
      table.insert(lines, table.concat(week, ""))
      week = {}
    end
  end

  if #week > 0 then
    table.insert(lines, table.concat(week, ""))
  end

  vim.api.nvim_buf_set_option(buf, "modifiable", true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(buf, "modifiable", false)
end

-- ---------- actions ----------

local function close()
  if win and vim.api.nvim_win_is_valid(win) then
    vim.api.nvim_win_close(win, true)
  end
end

local function return_to_origin()
  if vim.api.nvim_win_is_valid(origin_win) then
    vim.api.nvim_set_current_win(origin_win)
  else
    vim.api.nvim_set_current_buf(origin_buf)
  end
end

local function paste_timestamp()
  return_to_origin()
  local ts = date_str() .. "T" .. os.date("%H:%M")
  vim.api.nvim_put({ ts }, "c", true, true)
  close()
end

local function open_daily_note()
  return_to_origin()
  local path = vim.fn.expand("~/pkb/" .. date_str() .. ".md")
  vim.cmd.edit(path)
  close()
end

-- ---------- open ----------

function M.open()
  local now = os.date("*t")
  state.year, state.month, state.day = now.year, now.month, now.day

  origin_buf = vim.api.nvim_get_current_buf()
  origin_win = vim.api.nvim_get_current_win()

  buf = vim.api.nvim_create_buf(false, true)

  local width, height = 28, 8
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    row = row,
    col = col,
    width = width,
    height = height,
    style = "minimal",
    border = "rounded",
  })

  local opts = { buffer = buf, silent = true }

  -- day focus
  vim.keymap.set("n", "h", function() state.day = state.day - 1 clamp_day() render() end, opts)
  vim.keymap.set("n", "l", function() state.day = state.day + 1 clamp_day() render() end, opts)
  vim.keymap.set("n", "k", function() state.day = state.day - 7 clamp_day() render() end, opts)
  vim.keymap.set("n", "j", function() state.day = state.day + 7 clamp_day() render() end, opts)

  -- view navigation
  vim.keymap.set("n", "H", function() state.year = state.year - 1 clamp_day() render() end, opts)
  vim.keymap.set("n", "L", function() state.year = state.year + 1 clamp_day() render() end, opts)
  vim.keymap.set("n", "K", function()
    state.month = state.month - 1
    if state.month < 1 then state.month = 12 state.year = state.year - 1 end
    clamp_day()
    render()
  end, opts)
  vim.keymap.set("n", "J", function()
    state.month = state.month + 1
    if state.month > 12 then state.month = 1 state.year = state.year + 1 end
    clamp_day()
    render()
  end, opts)

  -- today
  vim.keymap.set("n", "t", function()
    local n = os.date("*t")
    state.year, state.month, state.day = n.year, n.month, n.day
    render()
  end, opts)

  -- actions
  vim.keymap.set("n", "<CR>", open_daily_note, opts)
  vim.keymap.set("n", "ts", paste_timestamp, opts)

  -- quit
  vim.keymap.set("n", "q", close, opts)
  vim.keymap.set("n", "<Esc>", close, opts)

  render()
end

return M
