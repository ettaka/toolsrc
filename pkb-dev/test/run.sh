#!/usr/bin/env bash
# Run the PKB stack smoke test headlessly against local clones.
#   PKB_DEV_DIR  workspace with pkb-nvim/ calendar-nvim/ timestamps-nvim/  (default ~/pkb-dev)
#   NVIM_BIN     nvim binary (>= 0.12)  (default: nvim on PATH; not $NVIM, which is the server socket in :terminal)
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)
export PKB_DEV_DIR=${PKB_DEV_DIR:-$HOME/pkb-dev}
NVIM_BIN=${NVIM_BIN:-nvim}
# Fixed TZ: HOME_TZ in timestamps-nvim is +02:00, so test in a zone where that is true in winter.
export TZ=Europe/Helsinki
export PKB_ROOT=$(mktemp -d)
trap 'rm -rf "$PKB_ROOT"' EXIT
# Isolate from the user's config/data so the test is reproducible.
export XDG_CONFIG_HOME=$PKB_ROOT/.xdg/config XDG_DATA_HOME=$PKB_ROOT/.xdg/data XDG_STATE_HOME=$PKB_ROOT/.xdg/state
# pcall wrapper: a Lua error must exit non-zero, not hang on a headless error prompt.
"$NVIM_BIN" --headless --clean -u NONE -c "lua local ok, e = pcall(dofile, '$here/smoke.lua')
  if not ok then io.stderr:write('ERROR ' .. tostring(e) .. '\\n'); vim.cmd('cq!') end"
