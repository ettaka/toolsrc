local interval_pairs = {
  { "start", "end" },
  { "arrive", "depart" },
  { "begin", "finish" },
}

local function parse_iso_datetime(dt)
  local y, m, d, hh, mm =
    dt:match("(%d+)%-(%d+)%-(%d+)T(%d+):(%d+)")
  return os.time({
    year = tonumber(y),
    month = tonumber(m),
    day = tonumber(d),
    hour = tonumber(hh),
    min = tonumber(mm),
    sec = 0,
  })
end

local function format_duration(seconds)
  local hours = math.floor(seconds / 3600)
  local minutes = math.floor((seconds % 3600) / 60)
  return string.format("%dh %02dm", hours, minutes)
end

local function extract_timestamp(line, key)
  local pattern = key .. "::(%d%d%d%d%-%d%d%-%d%dT%d%d:%d%d)"
  return line:match(pattern)
end

local function compute_interval_duration()
  local line = vim.api.nvim_get_current_line()

  for _, pair in ipairs(interval_pairs) do
    local k1, k2 = pair[1], pair[2]

    local v1 = extract_timestamp(line, k1)
    local v2 = extract_timestamp(line, k2)

    if v1 and v2 then
      local t1 = parse_iso_datetime(v1)
      local t2 = parse_iso_datetime(v2)

      local delta = math.abs(t2 - t1)
      local duration = format_duration(delta)

      local direction
      if t2 < t1 then
        direction = string.format("%s → %s", k2, k1)
      else
        direction = string.format("%s → %s", k1, k2)
      end

      vim.notify(
        string.format(
          "Duration (%s): %s",
          direction,
          duration
        ),
        vim.log.levels.INFO
      )
      return
    end
  end

  vim.notify("No valid interval pair found on line", vim.log.levels.WARN)
end

vim.keymap.set(
  "n",
  "<leader>td",
  compute_interval_duration,
  { desc = "Compute duration from interval pairs" }
)

