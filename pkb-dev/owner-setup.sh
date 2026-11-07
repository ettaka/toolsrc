#!/usr/bin/env bash
# Owner-side setup: connect your own clones to the shared review repos in /srv/git.
#
#   bash owner-setup.sh [--ssh|--https] [BASE_DIR]     BASE_DIR for new clones (default: ~/git)
#
# New clones use SSH (git@github.com:) if your GitHub SSH key works, otherwise HTTPS; force with --ssh/--https.
#
# For each of toolsrc, pkb-nvim, calendar-nvim, timestamps-nvim it:
#   1. trusts /srv/git/<repo>.git (git safe.directory; the bare repos are owned by claudebot)
#   2. finds your existing clone, or clones it from GitHub into BASE_DIR
#   3. adds/updates a remote "local" -> /srv/git/<repo>.git and fetches it (and origin)
#   4. reports what is waiting in local/<default branch> to be pushed to GitHub
# It never pushes, merges, switches branches or modifies working-tree files.
set -euo pipefail

BARE=${PKB_BARE_DIR:-/srv/git}
PROTO=auto
case "${1:-}" in --ssh) PROTO=ssh; shift ;; --https) PROTO=https; shift ;; esac
BASE=${1:-$HOME/git}
if [ "$PROTO" = auto ]; then
  if ssh -o BatchMode=yes -o ConnectTimeout=5 -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
    PROTO=ssh
  else
    PROTO=https
  fi
fi
gh_url() { if [ "$PROTO" = ssh ]; then echo "git@github.com:ettaka/$1.git"; else echo "https://github.com/ettaka/$1"; fi; }
echo "GitHub access for new clones: $PROTO   new clones go to: $BASE"
REPOS=(toolsrc pkb-nvim calendar-nvim timestamps-nvim)

say()  { printf '%s\n' "$*"; }
warn() { printf 'WARNING: %s\n' "$*" >&2; }

is_clone_of() { # dir repo -> true if dir is a git work tree whose origin points at ettaka/<repo>
  [ -d "$1/.git" ] || return 1
  git -C "$1" remote get-url origin 2>/dev/null | grep -qiE "ettaka/$2(\.git)?/?$"
}

candidates() { # repo -> candidate clone dirs, best first
  local r=$1
  if [ "$r" = toolsrc ]; then
    [ -n "${TOOLSRC_DIR:-}" ] && echo "$TOOLSRC_DIR"
    if [ -L "$HOME/.config/nvim" ]; then dirname "$(readlink -f "$HOME/.config/nvim")"; fi
  fi
  echo "$BASE/$r"
  echo "$HOME/$r"
  echo "$HOME/git/$r"
  echo "$HOME/src/$r"
}

find_clone() {
  local d
  while read -r d; do
    if is_clone_of "$d" "$1"; then echo "$d"; return 0; fi
  done < <(candidates "$1")
  return 1
}

[ -d "$BARE" ] || { warn "$BARE not found"; exit 1; }
id -nG | tr ' ' '\n' | grep -qx fmsh || warn "you are not in group fmsh; reading $BARE may fail (log out/in after being added)"

for r in "${REPOS[@]}"; do
  b=$BARE/$r.git
  say ""
  say "=== $r"
  if [ ! -d "$b" ]; then warn "no bare repo at $b, skipping"; continue; fi

  # 1. trust the bare repo
  if ! git config --global --get-all safe.directory 2>/dev/null | grep -qxF "$b"; then
    git config --global --add safe.directory "$b"
    say "trusted $b (safe.directory)"
  fi

  # 2. find or create your clone
  if dir=$(find_clone "$r"); then
    say "clone:  $dir"
  else
    dir=$BASE/$r
    if [ -e "$dir" ]; then warn "$dir exists but is not a clone of ettaka/$r, skipping"; continue; fi
    mkdir -p "$BASE"
    git clone -q "$(gh_url "$r")" "$dir"
    say "clone:  $dir (new, from GitHub)"
  fi

  # 3. remote "local" + fetch
  if git -C "$dir" remote get-url local >/dev/null 2>&1; then
    git -C "$dir" remote set-url local "$b"
  else
    git -C "$dir" remote add local "$b"
    say "added remote 'local' -> $b"
  fi
  git -C "$dir" fetch -q local
  git -C "$dir" fetch -q origin || warn "could not fetch origin (GitHub) for $r"

  # 4. report
  def=$(git --git-dir="$b" symbolic-ref --short HEAD)
  cur=$(git -C "$dir" symbolic-ref --short -q HEAD || echo "(detached)")
  say "branch: $cur   (default: $def)$( [ -n "$(git -C "$dir" status --porcelain)" ] && echo '   [uncommitted changes]')"
  say "you:    $(git -C "$dir" config user.name || echo '?') <$(git -C "$dir" config user.email || echo '?')>"
  if git -C "$dir" rev-parse -q --verify "origin/$def" >/dev/null; then
    pending=$(git -C "$dir" log --format='        %h %s  [A:%an C:%cn]' "origin/$def..local/$def")
    if [ -n "$pending" ]; then
      say "ready to push (local/$def, not yet on GitHub):"
      say "$pending"
      if ! git -C "$dir" merge-base --is-ancestor "origin/$def" "local/$def"; then
        warn "local/$def and GitHub $def have diverged; ask for a rebase before pushing"
      fi
    else
      say "nothing new on local/$def"
    fi
  fi
  # review branches = branches in local that GitHub doesn't have, or has at a different commit
  others=""
  for ref in $(git -C "$dir" branch -r --format='%(refname:short)' --list 'local/*'); do
    br=${ref#local/}
    [ "$br" = "$def" ] || [ "$br" = HEAD ] || [ "$br" = local ] && continue
    [ "$(git -C "$dir" rev-parse -q --verify "origin/$br" || true)" = "$(git -C "$dir" rev-parse "$ref")" ] && continue
    others="$others $ref"
  done
  [ -n "$others" ] && say "review branches:$others"
  true
done

cat <<EOF

Done. Nothing was pushed.
Run nvim on these plugin clones (after merging toolsrc ai-setup):  PKB_DEV_DIR=$BASE nvim
To publish what is "ready to push" for a repo:
  cd <clone> && git checkout <default> && git pull --ff-only local <default> && git push origin <default>
To look at a review branch first:  git log -p <default>..local/<branch>
EOF
