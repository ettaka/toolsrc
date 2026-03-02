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

local function get_visual_lines()
  local start_line = vim.fn.line("'<")
  local end_line   = vim.fn.line("'>")
  return vim.api.nvim_buf_get_lines(
    0,
    start_line - 1,
    end_line,
    false
  )
end

local function report_visual_log_durations()
  print ("hello!")

  --vim.notify(table.concat(output, "\n"), vim.log.levels.INFO)
end

vim.keymap.set(
  "v",
  "<leader>zl",
  report_visual_log_durations,
  { desc = "Report durations from time log" }
)

