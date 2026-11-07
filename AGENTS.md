# toolsrc — agent guide

toolsrc holds the owner's personal dotfiles and tool setup (Neovim, bash/zsh, tmux, i3). It is used on desktop Linux
and on an Android phone running Termux. `setup.py` links the files into place.

**Working on the PKB (notes, tasks, calendar) plugins?** Read [`pkb-dev/AGENTS.md`](pkb-dev/AGENTS.md) first. It covers
the multi-repo PKB stack that this repo loads and configures.

## Layout

| Path | What | Installed as |
|---|---|---|
| `nvim-lua/` | **Active Neovim config** (Lua, nvim ≥ 0.12, plugins via `vim.pack`) | symlink `~/.config/nvim` |
| `nvim/`, `vim/` | Legacy vimscript configs (vim-plug). Not maintained. | `nvim/` only when `vimscript=True` in `setup.py` |
| `bash/`, `zsh/` | Every file is sourced by the block that `setup.py` appends to `~/.bashrc` / `~/.zshrc` | sourced |
| `tmux/tmux.conf`, `i3/config` | | symlinked to `~/.tmux.conf`, `~/.config/i3/config` |
| `setup.py` | One-shot installer: nvim nightly appimage, symlinks, shell rc blocks, oh-my-zsh | run once from the repo root |
| `install_nerd_font.sh` | JetBrainsMono Nerd Font (desktop and Termux) | |
| `pkb-dev/` | PKB development workspace tooling: `setup.sh`, smoke test, agent guide | |

### `nvim-lua/`
- `init.lua` requires `ettaka` (settings, mappings, packer, kqcircuits, clipboard) and a few top-level modules
  (`takepicture`, `sync_photos`).
- `lua/ettaka/packer.lua`: despite the name, it declares **all plugins with `vim.pack.add`** and configures the ones
  that need setup. Set `PKB_DEV_DIR` to load local PKB plugin clones.
- `after/plugin/*.lua`: one file per feature or plugin. Each file defines its keymaps and user commands next to the
  code that uses them.
- `lua/*.lua`: standalone modules for phone integration (`mount_phone`, `takepicture`, `sync_photos`).
- `bin/`: helpers that are added to `PATH`. For example, `e`/`sp`/`vsp` open a file in the surrounding nvim when run
  from `:terminal`.

### Environment the config expects
These variables are set outside this repo, in the machine-local shell rc:
- `PKB_ROOT`: the notes directory, normally `~/pkb`.
- `DEVICE_IS_PHONE`: `"true"` on Termux. It switches the leader key to `,` (otherwise `\`) and turns on Termux
  notifications.
- `PKB_DEV_DIR` (optional): see `pkb-dev/AGENTS.md`.

## Conventions
- Lua uses 2- or 4-space indentation; files vary, so match the file you edit. Show messages to the user with
  `vim.notify`. Give every keymap a `desc`. Keep functions `local` (no globals).
- Before adding a `<leader>` mapping, check it is free and that it is neither a prefix of an existing map nor has one
  as its prefix (otherwise the shorter one waits for `timeoutlen`):
  `grep -rhoE "<leader>[^\"']*" nvim-lua ../pkb-dev/*/plugin ../pkb-dev/*/lua | sort | uniq -c`.
- Paths: use an environment variable or option with a home-relative fallback (`$PKB_ROOT` -> `~/pkb`,
  `$KQC` -> `~/git/KQCircuits`); never hard-code `/home/<user>`.
- Phone-only code paths call `termux-*`, `adb`, `jmtpfs` or `rsync`. They cannot be tested here, so keep them guarded.

## Keymap layout (leader is `\` on desktop, `,` on the phone)
| Prefix | Use |
|---|---|
| `<leader>a…` | avante (`aa`, `ae`, `at`, `as`, …); `aS` arxiv PDF sync, `ap` arxiv download |
| `<leader>A` | Alpha dashboard in a split |
| `<leader>cc` | calendar (calendar-nvim `setup{keymap}`); `<leader>ca` is the LSP code action |
| `<leader>f…` | Telescope (`ff`, `fg`, `fb`, `fh`); `<leader>f` alone formats in LSP buffers |
| `<leader>k…` | KQCircuits: `kl` open element, `ks` simulate, `kqc` :Kqc |
| `<leader>t…` | tasks/time: `ts` timestamp, `td` duration, `tb` task backlinks |
| `<leader>w…` | wiki references (`wm`, `wi`, `wr`) |
| `<leader>z…` | notes: Telekasten (`zp` panel, `zf`, `zg`, `zd`, …), `zm` phone mount, `zl` time-log report (visual) |
| `<leader><space>` | floating terminal; `<leader><enter>` KQC run |

## Testing
No test suite covers the config as a whole. Use these checks:
- Before you finish a change, check that every edited Lua file parses:
  `nvim --headless --clean -u NONE -c 'lua for _,f in ipairs(vim.fn.glob("nvim-lua/**/*.lua",0,1)) do assert(loadfile(f)) end' -c qa`
  On the claudebot account, nvim is at `~/opt/nvim-linux-x86_64/bin/nvim`.
- Exercise a changed keymap headless: load the file with `dofile`, stub plugins that are not installed via
  `package.loaded[...]`, then call `vim.fn.maparg(lhs, mode, false, true).callback()`.
- `setup.py` only runs under `__main__`; import it (with a throwaway `HOME`) to test single functions.
- For anything in the PKB stack, run `pkb-dev/test/run.sh` and the plugins' `make test`.

## Git
`origin` is `/srv/git/toolsrc.git`, the shared bare repo. `github` is fetch-only for claudebot. Keep all unpublished
work on one branch, `fixes`, on top of `master`, and push it to `origin`; the owner reviews it and pushes to GitHub
(see `pkb-dev/AGENTS.md`). Commits carry only the owner's identity (`user.*` in `.git/config`); do not add
`Co-Authored-By` trailers or other AI attribution.

## Open points
- A few leader maps still wait for the timeout: `<leader>y`/`<leader>yy`, `<leader>p`/`<leader>pv`, and in LSP buffers
  `<leader>f`/`<leader>ff`.
