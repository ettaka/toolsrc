-- Headless smoke test for the PKB plugin stack (timestamps-nvim, pkb-nvim, calendar-nvim).
-- Run via ./run.sh; it sets PKB_DEV_DIR, TZ and a throwaway PKB_ROOT.
local dev = assert(vim.env.PKB_DEV_DIR, "PKB_DEV_DIR not set")
local root = assert(vim.env.PKB_ROOT, "PKB_ROOT not set")
for _, name in ipairs({ "timestamps-nvim", "pkb-nvim", "calendar-nvim" }) do
  vim.opt.runtimepath:prepend(dev .. "/" .. name)
end
vim.cmd.runtime({ "plugin/*.lua", bang = true })

local failures, passes = 0, 0
local function check(name, cond, detail)
  if cond then
    passes = passes + 1
  else
    failures = failures + 1
    io.stderr:write(("FAIL %s%s\n"):format(name, detail and (": " .. vim.inspect(detail)) or ""))
  end
end
local function eq(name, got, want)
  check(name, vim.deep_equal(got, want), { got = got, want = want })
end

-- Quiet the plugins' print()/notify chatter so test output stays readable.
_G.print = function() end
vim.notify = function() end

---------------------------------------------------------------- timestamps
local ts = require("timestamps.parser")
eq("parse_iso Z", ts.parse_iso("2026-01-15T10:00Z"), 1768471200)
eq("parse_iso H (= HOME_TZ +02:00)", ts.parse_iso("2026-01-15T10:00H"), 1768464000)
eq("parse_iso numeric offset", ts.parse_iso("2026-07-15T10:00+03:00"), 1784098800)
eq("parse_iso trailing punctuation", ts.parse_iso("2026-01-15T10:00Z)."), 1768471200)
eq("parse_iso rejects Feb 30", ts.parse_iso("2026-02-30T10:00Z"), nil)
eq("parse_iso rejects missing suffix", ts.parse_iso("2026-01-15T10:00"), nil)

---------------------------------------------------------------- pkb.parser
local p = require("pkb.parser")
local base = os.time({ year = 2026, month = 11, day = 7, hour = 9, min = 0 })
local function ymd(t) return os.date("%Y-%m-%d %H:%M", t) end
eq("recur daily", ymd(p.calculate_next_due(base, "daily")), "2026-11-08 09:00")
eq("recur 2w", ymd(p.calculate_next_due(base, "2w")), "2026-11-21 09:00")
eq("recur monthly", ymd(p.calculate_next_due(base, "monthly")), "2026-12-07 09:00")
eq("recur 1st_tue", ymd(p.calculate_next_due_advanced(base, "1st_tue")), "2026-12-01 09:00")
eq("recur last_fri", ymd(p.calculate_next_due_advanced(base, "last_fri")), "2026-11-27 09:00")
eq("parse_notify", { p.parse_notify("15min"), p.parse_notify("2h"), p.parse_notify("1day") }, { 900, 7200, 86400 })

---------------------------------------------------------------- notifier scan / agenda / effort
local tasks = root .. "/tasks.md"
vim.fn.writefile({
  "# tasks",
  "- [ ] Water plants due::2026-11-10T08:00H recur::daily effort::30min",
  "- [ ] Write report due::2026-11-10T13:00H effort::3h",
  "- [x] Done thing due::2026-11-10T09:00H effort::5h",
  "```",
  "- [ ] in code block due::2026-11-10T10:00H",
  "```",
}, tasks)

local notifier = require("pkb.notifier")
notifier.setup({ pkb_root = root, device_is_phone = false, poll_interval = 3600000 })
notifier.notify()
local n = 0
for _ in pairs(notifier.notifications) do n = n + 1 end
eq("notifier finds tasks outside code blocks", n, 3)

local agenda = require("pkb.agenda_provider").get_pkb_day_agenda(2026, 11, 10)
eq("agenda excludes done tasks", #agenda, 2)
check("agenda strips tags", agenda[1] and not agenda[1]:find("due::", 1, true), agenda)

local hours = require("pkb.effort_calculation").get_tasks_duration(2026, 11, 10)
eq("effort sums open tasks", hours, 3.5)

---------------------------------------------------------------- complete a recurring task
local entry
for _, e in pairs(notifier.notifications) do
  if e.line:find("Water plants", 1, true) then entry = e end
end
notifier.complete_task(entry)
local after = vim.fn.readfile(tasks)
check("completed line gets old:: and done::", after[2]:find("old::2026-11-10T08:00H", 1, true)
  and after[2]:find("done::", 1, true) and not after[2]:find("recur::", 1, true), after[2])
check("next recurrence inserted", after[3]:find("due::2026-11-11T08:00", 1, true)
  and after[3]:find("recur::daily", 1, true), after[3])
check("daily note logged", vim.fn.filereadable(root .. "/2026-11-10.md") == 1)

---------------------------------------------------------------- calendar
require("calendar").setup({
  get_tasks_duration = require("pkb.effort_calculation").get_tasks_duration,
  get_day_agenda = require("pkb.agenda_provider").get_pkb_day_agenda,
})
local ok, err = pcall(require("calendar").open)
check("calendar opens headless", ok, err)

if notifier.timer then notifier.timer:stop(); notifier.timer:close() end

io.stdout:write(("pkb smoke: %d passed, %d failed\n"):format(passes, failures))
vim.cmd(failures == 0 and "qa!" or "cq!")
