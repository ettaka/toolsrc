local accepted_transitions = {
  depart = { at = true, arrive = true },
  at     = { depart = true },
  arrive = { at = true }, -- optional, example
}

local function parse_iso_datetime(dt)
  local y, m, d, hh, mm =
    dt:match("(%d+)%-(%d+)%-(%d+)T(%d+):(%d+)")
  return os.time({
    year  = tonumber(y),
    month = tonumber(m),
    day   = tonumber(d),
    hour  = tonumber(hh),
    min   = tonumber(mm),
    sec   = 0,
  })
end

local function format_duration(seconds)
  local h = math.floor(seconds / 3600)
  local m = math.floor((seconds % 3600) / 60)
  return string.format("%dh %02dm", h, m)
end

local function extract_events(lines)
  local events = {}

  for _, line in ipairs(lines) do
    for key, ts in line:gmatch("(%w+)::(%d%d%d%d%-%d%d%-%d%dT%d%d:%d%d)") do
      table.insert(events, {
        key  = key,
        time = parse_iso_datetime(ts),
      })
    end
  end

  table.sort(events, function(a, b)
    return a.time < b.time
  end)

  return events
end

local function compute_transitions(events)
  local results = {}

  for i = 1, #events - 1 do
    local a = events[i]
    local b = events[i + 1]

    if accepted_transitions[a.key]
       and accepted_transitions[a.key][b.key] then
      table.insert(results, {
        from     = a.key,
        to       = b.key,
        duration = format_duration(b.time - a.time),
      })
    end
  end

  return results
end

-- Lines of the current visual selection. While a visual-mode mapping runs, '< and '> still hold the
-- previous selection, so use the "v" position and the cursor; fall back to the marks otherwise.
local function get_visual_lines()
  local first, last
  if vim.fn.mode():match("^[vV\22]") then
    first, last = vim.fn.line("v"), vim.fn.line(".")
  else
    first, last = vim.fn.line("'<"), vim.fn.line("'>")
  end
  if first > last then first, last = last, first end
  return vim.api.nvim_buf_get_lines(0, first - 1, last, false)
end

-- Report the time between consecutive depart::/at::/arrive:: timestamps in the selection
-- (only the accepted transitions above, e.g. depart -> arrive).
local function report_visual_log_durations()
  local transitions = compute_transitions(extract_events(get_visual_lines()))
  if #transitions == 0 then
    vim.notify("No timed transitions (depart/at/arrive) in the selection", vim.log.levels.WARN)
    return
  end
  local output = {}
  for _, t in ipairs(transitions) do
    table.insert(output, string.format("%s → %s: %s", t.from, t.to, t.duration))
  end
  vim.notify(table.concat(output, "\n"), vim.log.levels.INFO)
end

vim.keymap.set(
  "v",
  "<leader>zl",
  report_visual_log_durations,
  { desc = "Report durations from time log" }
)

