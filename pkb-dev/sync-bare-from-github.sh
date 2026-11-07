#!/usr/bin/env bash
# Fast-forward the shared bare repos in /srv/git from GitHub (e.g. after pushing from the phone).
# Never forces: a branch that diverged from GitHub is reported and left alone.
set -uo pipefail
BARE=${PKB_BARE_DIR:-/srv/git}
for r in timestamps-nvim pkb-nvim calendar-nvim toolsrc; do
  b=$BARE/$r.git
  [ -d "$b" ] || { echo "$r: no bare repo at $b"; continue; }
  branch=$(git -C "$b" symbolic-ref --short HEAD)
  if git -C "$b" fetch -q origin "$branch:$branch" 2>/dev/null; then
    echo "$r: $branch at $(git -C "$b" rev-parse --short "$branch")"
  else
    echo "$r: $branch not fast-forwardable: bare is ahead of or diverged from GitHub (push to GitHub from your clone, or merge there)"
  fi
done
