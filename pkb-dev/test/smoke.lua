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

---------------------------------------------------------------- notifier scan / inbox day view / effort
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

notifier.open_day(2026, 11, 10)
local day = vim.api.nvim_buf_get_lines(0, 0, -1, false)
local row = vim.api.nvim_win_get_cursor(0)[1]
check("inbox day view: cursor on the day", day[row] and day[row]:match("^## 2026%-11%-10"), day)
check("inbox day view: time slot, no tags", day[row + 1] and day[row + 1]:find("08:00–08:30  Water plants", 1, true)
  and not day[row + 1]:find("due::", 1, true), day)
check("inbox day view: done tasks excluded", not table.concat(day, "\n"):find("Done thing", 1, true), day)

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
  open_day = notifier.open_day,
})
local ok, err = pcall(require("calendar").open)
check("calendar opens headless", ok, err)
-- `a` in the calendar: the pkb inbox opens on the selected day (today)
ok, err = pcall(vim.fn.maparg("a", "n", false, true).callback)
check("calendar a runs", ok, err)
check("calendar a opens the inbox on the selected day",
  vim.api.nvim_get_current_line() == "## " .. os.date("%Y-%m-%d")
    or vim.api.nvim_get_current_line():find("^## " .. os.date("%Y%%-%m%%-%d")), vim.api.nvim_get_current_line())

---------------------------------------------------------------- toolsrc <leader>zz (Telekasten stubbed)
local toolsrc = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h:h")
package.loaded.telekasten = { setup = function() end }
local telekasten_calls = {}
vim.api.nvim_create_user_command("Telekasten", function(a) table.insert(telekasten_calls, a.args) end, { nargs = "*" })
dofile(toolsrc .. "/nvim-lua/after/plugin/telekasten.lua")
vim.fn.mkdir(root .. "/papers", "p")
vim.fn.writefile({ "PDF" }, root .. "/papers/qc.pdf")
vim.fn.mkdir(root .. "/notes", "p")
vim.fn.writefile({ "see [qc](../papers/qc.pdf)", "and [[Water plants]]" }, root .. "/notes/links.md")
vim.cmd.edit(root .. "/notes/links.md")
local ui_opened
vim.ui.open = function(path) ui_opened = path; return {}, nil end
local zz = vim.fn.maparg("<leader>zz", "n", false, true).callback
vim.api.nvim_win_set_cursor(0, { 1, 6 })
zz()
eq("<leader>zz opens a relative file link from the note's folder", ui_opened, root .. "/papers/qc.pdf")
vim.api.nvim_win_set_cursor(0, { 2, 7 })
zz()
eq("<leader>zz leaves [[page]] links to Telekasten", telekasten_calls, { "follow_link" })

if notifier.timer then notifier.timer:stop(); notifier.timer:close() end

io.stdout:write(("pkb smoke: %d passed, %d failed\n"):format(passes, failures))
vim.cmd(failures == 0 and "qa!" or "cq!")
