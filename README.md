# toolsrc

Personal dotfiles and tool setup: Neovim (Lua, `nvim-lua/`), bash/zsh, tmux and i3. Used on desktop Linux and on an
Android phone (Termux).

## Install

```sh
git clone https://github.com/ettaka/toolsrc ~/toolsrc
cd ~/toolsrc && ./setup.py
```

`setup.py` links `~/.config/nvim` to `nvim-lua/`, downloads the latest stable Neovim appimage to `~/bin`, links the
tmux and i3 configs, and adds a block to `~/.bashrc` / `~/.zshrc` that sources every file in `bash/` / `zsh/`.
Running it again is safe. Neovim plugins are installed by `vim.pack` on first start (Neovim 0.12 or newer).

Environment, set in the machine's own shell rc:

| Variable | Meaning |
|---|---|
| `PKB_ROOT` | notes folder for the PKB plugins (default `~/pkb`) |
| `DEVICE_IS_PHONE` | `true` on Termux: leader `,` and phone notifications |
| `KQC` | KQCircuits checkout (default `~/git/KQCircuits`) |
| `PKB_DEV_DIR` | optional: load the PKB plugins from local clones (see `pkb-dev/`) |

## PKB plugins

Notes, tasks, reminders and the calendar come from
[pkb-nvim](https://github.com/ettaka/pkb-nvim), [calendar-nvim](https://github.com/ettaka/calendar-nvim) and
[timestamps-nvim](https://github.com/ettaka/timestamps-nvim). `pkb-dev/` has the development workspace setup,
a cross-repo smoke test and the developer guide (`pkb-dev/AGENTS.md`).
