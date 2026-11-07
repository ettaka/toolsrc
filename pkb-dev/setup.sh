#!/usr/bin/env bash
# Create (or refresh) a PKB development workspace with working clones of the PKB plugin stack.
#
#   pkb-dev/setup.sh [WORKSPACE]          default WORKSPACE: ~/pkb-dev
#
# Each clone gets two remotes:
#   origin  -> /srv/git/<repo>.git  (shared local bare repo, group fmsh)  [falls back to GitHub if absent]
#   github  -> https://github.com/ettaka/<repo>
# For the claudebot account, pushing to GitHub is disabled and user.name/user.email are set to the owner,
# so commits carry only the owner's identity and can be pushed to GitHub as-is.
set -euo pipefail

WS=${1:-$HOME/pkb-dev}
BARE=${PKB_BARE_DIR:-/srv/git}
REPOS=(timestamps-nvim pkb-nvim calendar-nvim)
TOOLSRC=$(cd "$(dirname "$0")/.." && pwd)
OWNER_NAME=${PKB_OWNER_NAME:-Eelis Takala}
OWNER_EMAIL=${PKB_OWNER_EMAIL:-eelis.takala@gmail.com}

mkdir -p "$WS"
for r in "${REPOS[@]}"; do
  src=$BARE/$r.git
  [ -d "$src" ] || src=https://github.com/ettaka/$r
  if [ ! -d "$WS/$r/.git" ]; then
    git clone -q "$src" "$WS/$r"
  fi
  git -C "$WS/$r" remote get-url github >/dev/null 2>&1 \
    || git -C "$WS/$r" remote add github "https://github.com/ettaka/$r"
  if [ "$(id -un)" = claudebot ]; then
    git -C "$WS/$r" remote set-url --push github DISABLED-claudebot-does-not-push-to-github
    git -C "$WS/$r" config user.name "$OWNER_NAME"
    git -C "$WS/$r" config user.email "$OWNER_EMAIL"
  fi
  git -C "$WS/$r" fetch -q --all
  echo "$r: $(git -C "$WS/$r" status -sb | head -1)"
done

ln -sfn "$TOOLSRC" "$WS/toolsrc"
ln -sfn "$TOOLSRC/pkb-dev/AGENTS.md" "$WS/AGENTS.md"
ln -sfn "$TOOLSRC/pkb-dev/CLAUDE.md" "$WS/CLAUDE.md"
echo "Workspace ready: $WS  (start nvim with PKB_DEV_DIR=$WS to use these clones)"
