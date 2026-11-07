# PKB development workspace — agent guide

This guide covers the whole **PKB (personal knowledge base) stack**: a set of Neovim plugins that turn a folder of
Markdown notes (`$PKB_ROOT`, normally `~/pkb`) into a task, notification and calendar system. It runs on desktop
Linux and on an Android phone (Termux). The workspace (`~/pkb-dev`, created by `toolsrc/pkb-dev/setup.sh`) holds one
working clone per repo:

| Dir | Repo | Role |
|---|---|---|
| `timestamps-nvim/` | github.com/ettaka/timestamps-nvim | ISO timestamp parsing and insertion. No dependencies. |
| `pkb-nvim/` | github.com/ettaka/pkb-nvim | Scans the PKB, notifications, inbox, task complete/skip, recurrence, the inbox (time slots, day view) and the effort provider. Requires `timestamps`. |
| `calendar-nvim/` | github.com/ettaka/calendar-nvim | Floating month calendar with effort heat marks; `a` opens the selected day in the pkb inbox, `<CR>` the daily note. Gets its data from pkb via `setup()` callbacks. Requires `timestamps`. |
| `toolsrc/` (symlink) | github.com/ettaka/toolsrc | The user's dotfiles. `nvim-lua/` loads and configures the plugins and holds PKB glue that is not in a plugin yet. |

The dependency direction is `timestamps` ← `pkb` ← `calendar`, and `toolsrc` wires them together. Keep it that way:
calendar must not `require("pkb...")`: it gets its data only through the `setup()` callbacks (`helpers.providers`).

## The note format (the real API)

Everything is plain Markdown lines with `key::value` inline tags. Treat this format as a public API: the user's
notes on the desktop and the phone depend on it, so a change must stay backward compatible or come with a migration.

| Tag | Meaning | Parsed in |
|---|---|---|
| `due::2026-11-10T08:00H` | Due time. Suffix is required, always a fixed offset: `Z` (UTC), `H` (`+02:00`, home standard time), `S` (`+03:00`, home summer time) or `±hh:mm`. New timestamps get the suffix of the offset at that moment. | `timestamps/parser.lua` `parse_iso` |
| `notify::15min` / `2h` / `1day` | Notify this long before `due`. Default: `default_notify`. | `pkb/parser.lua` `parse_notify` |
| `recur::daily` / `3d` / `2w` / `monthly` / `yearly` / `1st_tue` / `last_fri` | Recurrence. On complete or skip the next instance is written as a new line below. | `pkb/parser.lua` |
| `effort::30min` / `2h` / `1day` | Planned effort, summed per day for the calendar marks. | `pkb/effort_calculation.lua`, `pkb/render.lua` |
| `task::t-2026-11-07T09:15` | Stable task ID; the toolsrc `<leader>jt` / `<leader>tb` keymaps navigate by it. | `toolsrc/nvim-lua/after/plugin/task_navigation.lua`, `pkb/notifier.lua` |
| `old::<ts>` + `done::<ts>` / `skipped::<ts>` | Written when a task is completed or skipped (`due::` is renamed to `old::`). | `pkb/notifier.lua` |
| `- [x]` | A checked checkbox means done. Lines inside fenced code blocks and template lines (`YYYY-MM-DD`, `[Z/H`) are ignored. | `pkb/parser.lua` |

Daily notes are `$PKB_ROOT/YYYY-MM-DD.md` with `# morning` / `# afternoon` / `# evening` sections. Completed tasks
are logged there.

## Module map

- `pkb/notifier.lua`: the central module. It holds the state in `M.notifications`, keyed by `file:line`;
  across rescans, state follows the task by text or `task::` id, not by line number. It contains
  `setup`, `notify()` (full rescan and timer start), `inbox()`, `complete_task` and `skip_task`.
- `pkb/parser.lua`: line and directory scanning, recurrence math, and the daily-note insertion point.
- `pkb/ui.lua`: the digest popup and auto-snooze. `pkb/render.lua` renders the inbox (effort and conflict detection).
- `pkb/task_id.lua`: the task id format (`t-YYYY-MM-DDTHH:MM`, tagged `task::<id>`), generation and lookup.
- `pkb/termux_notification.lua`: Android notifications through `termux-notification`, used when `device_is_phone`.
- `pkb/render.lua` also formats inbox lines (`time_slot`, `display_text`). `notifier.open_day` and
  `effort_calculation.get_tasks_duration` are the callbacks handed to `calendar.setup()`.
- `calendar/{init,actions,helpers,render}.lua`: the calendar window, its keymaps and the rendering.
- `timestamps/{parser,actions}.lua`: `parse_iso` and `local_tz_suffix`, plus timestamp insertion.

The PKB pieces in toolsrc are listed here. They are candidates to move into `pkb-nvim`.
- `nvim-lua/lua/ettaka/packer.lua`: loads the plugins and calls `calendar.setup` with the pkb providers.
- `nvim-lua/after/plugin/pkb.lua`: `notifier.setup{...}`, the startup scan, and `queue_rescan` of each saved note.
- `nvim-lua/after/plugin/task_navigation.lua`: task ID jump, backlinks and insert (`<leader>jt`, `<leader>tb`, `<C-t>`).
- `nvim-lua/lua/mount_phone.lua`: the phone MTP mount (`<leader>zm`), used by `sync_photos`.
- `nvim-lua/after/plugin/{wiki_ref,duration_calculator,timelog,arxiv,telekasten}.lua`: helpers for writing notes.

Syncing: the PKB itself is a git repo, synced between laptop and phone with `git push` over ssh (adb port
forwarding for the phone). There is no sync code in nvim.

Environment: `PKB_ROOT` (the notes dir), `DEVICE_IS_PHONE` (`"true"` on Termux; it also switches the leader key to
`,`), `PKB_DEV_DIR` (load these clones instead of the GitHub copies).

## Running and testing

- **Unit tests (per repo):** `make test` in `pkb-nvim`, `timestamps-nvim` and `calendar-nvim` (`FILTER=...`,
  `PKB_TEST_VERBOSE=1`, `NVIM_BIN=...`). The runner is `tests/run.lua` (identical copy in each repo). Write the test
  first. A known bug you are not fixing yet is a `t.xfail(...)` case; when it is fixed the run reports XPASS until
  the case becomes a `t.test`.
- **Use local clones in the real editor:** `PKB_DEV_DIR=~/pkb-dev nvim`. `packer.lua` puts each clone that exists
  first on the runtimepath and skips `vim.pack.add` for it.
- **Smoke test (headless, sandboxed):** `toolsrc/pkb-dev/test/run.sh`. It needs nvim 0.12 or newer. On the claudebot
  account use `NVIM_BIN=~/opt/nvim-linux-x86_64/bin/nvim toolsrc/pkb-dev/test/run.sh`. It uses a temporary `PKB_ROOT`,
  `TZ=Europe/Helsinki` and isolated XDG dirs, and never touches `~/pkb`. Run it after every change and add a case for
  every behaviour you change. Tests check observable behaviour (file contents, inbox lines, epochs).
- **Never run anything against the real `~/pkb`.** `complete_task` and `skip_task` rewrite
  files.
- None of the repos has a linter or formatter set up yet. Match the surrounding style: 2-space indent in the plugins,
  `local M = {} … return M` modules, `vim.notify` for user messages.

## Git workflow

```
claudebot clones (~/pkb-dev/*) --push--> /srv/git/<repo>.git <--pull-- owner's clones --push--> GitHub
```

- `origin` is the shared bare repo in `/srv/git`. The bare repo uses the group `fmsh` with `core.sharedRepository=group`
  and `receive.denyNonFastforwards`.
- `github` is fetch-only for claudebot. Only the owner pushes to GitHub.
- Commits must show **only the owner**: `user.name`/`user.email` in each clone are set to the owner. Do not add
  `Co-Authored-By` trailers or any other AI attribution to commit messages.
- **One review branch per repo, named `fixes`.** Put all unpublished work on it as a linear series of commits on top
  of the default branch (`main` for pkb-nvim and timestamps-nvim, `master` for calendar-nvim and toolsrc) and push it
  to `origin`. Do not create per-issue branches, and do not push to `main`/`master` of the bare repos unless asked.
  The owner reviews `local/fixes`, fast-forwards the default branch and pushes to GitHub; after that, continue on a
  `fixes` that starts from the new default branch.
- When a change spans repos, say in each commit message which other repos it needs. Publish in dependency order:
  timestamps-nvim, then pkb-nvim and calendar-nvim, then toolsrc.
- Owner side: `pkb-dev/owner-setup.sh` (copy at `/srv/git/pkb-owner-setup.sh`) clones and connects the owner's
  repos; `pkb-dev/owner-pull.sh` (`/srv/git/pkb-owner-pull.sh`) fast-forwards them from `/srv/git`. Neither pushes.
- `toolsrc/pkb-dev/sync-bare-from-github.sh` fast-forwards the bare repos after the owner pushes to GitHub from
  somewhere else.

## Rules learned from fixed issues

All issues found in the first review (2026-11-07) are fixed on the `fixes` branches; the tests pin each of them.
Keep to these rules so they stay fixed:

- **Change notes only through `update_note()`** (`pkb/notifier.lua`): if the note is open, the buffer is changed so
  unsaved edits survive; never `writefile` + `:edit!`.
- **State follows tasks, not line numbers:** after a scan, `carry_state` (`pkb/parser.lua`) matches tasks by line
  text, else by `task::` id + due time. Do not key anything new on `file:line`.
- **Rescan only what changed:** `notifier.rescan_files(paths)` / `queue_rescan(path)` after editing notes; `notify()`
  (full scan) is for startup and `:PKBNotify`.
- **Time:** format a timestamp with the offset *at that timestamp* (`get_timestamp(ts)`, `local_tz_suffix(ts)`), and
  clear `isdst` before `os.time()` on a modified date table. `H`/`S` are fixed offsets, configurable with
  `require("timestamps").setup{ home_tz, home_summer_tz }`.
- **Task ids:** use `pkb.task_id` (format, parsing) and `notifier.new_task_id(lines)` for new ids (unique, same format).
- **Paths:** use `$PKB_ROOT` (or a setup option), falling back to `~/pkb`; never hard-code a home directory.
- **Plugins:** define commands and keymaps only in `plugin/` files or an `apply_keymaps()` called from there and from
  `setup()`; Lua modules have no side effects and create no globals (pkb-nvim `globals_spec` checks this).
- **calendar-nvim** stays independent of pkb-nvim (providers via `setup()`).

## Open points

- Monthly/yearly recurrence clamps to the end of a short month, but the chain then stays on the clamped day
  (Jan 31 -> Feb 28 -> Mar 28; pinned by a test). Fixing it needs the intended day stored in the note, e.g. a new
  rule such as `recur::monthly_last`.
- toolsrc still has a few leader maps that wait for the timeout because longer maps start with them:
  `<leader>y`/`<leader>yy` (clipboard), `<leader>p`/`<leader>pv` (clipboard paste / markdown PDF) and, in LSP buffers,
  `<leader>f`/`<leader>ff` (format / Telescope). They were left as they are.
