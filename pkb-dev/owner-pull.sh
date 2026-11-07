#!/usr/bin/env bash
# Pull everything from the shared review repos in /srv/git into your clones.
#
#   bash owner-pull.sh [BASE_DIR]      BASE_DIR = where owner-setup.sh put new clones (default: ~/git)
#
# For each of toolsrc, pkb-nvim, calendar-nvim, timestamps-nvim:
#   - fetches remote "local" (/srv/git/<repo>.git) and origin (GitHub)
#   - fast-forwards your default branch to local/<default>, whether or not it is checked out
#   - lists review branches and what is ready to push to GitHub
# Fast-forward only: never merges, rebases, pushes, or overwrites uncommitted changes.
# Run owner-setup.sh first if a repo is missing or has no "local" remote.
set -uo pipefail

BARE=${PKB_BARE_DIR:-/srv/git}
BASE=${1:-$HOME/git}
REPOS=(toolsrc pkb-nvim calendar-nvim timestamps-nvim)
status=0

say()  { printf '%s\n' "$*"; }
warn() { printf 'WARNING: %s\n' "$*" >&2; status=1; }

is_clone_of() {
  [ -d "$1/.git" ] || return 1
  git -C "$1" remote get-url origin 2>/dev/null | grep -qiE "ettaka/$2(\.git)?/?$"
}
candidates() {
  if [ "$1" = toolsrc ]; then
    [ -n "${TOOLSRC_DIR:-}" ] && echo "$TOOLSRC_DIR"
    if [ -L "$HOME/.config/nvim" ]; then dirname "$(readlink -f "$HOME/.config/nvim")"; fi
  fi
  printf '%s\n' "$BASE/$1" "$HOME/$1" "$HOME/git/$1" "$HOME/src/$1"
}
find_clone() {
  local d
  while read -r d; do is_clone_of "$d" "$1" && { echo "$d"; return 0; }; done < <(candidates "$1")
  return 1
}

for r in "${REPOS[@]}"; do
  say ""
  say "=== $r"
  dir=$(find_clone "$r") || { warn "$r: no clone found (run owner-setup.sh)"; continue; }
  git -C "$dir" remote get-url local >/dev/null 2>&1 || { warn "$r: $dir has no 'local' remote (run owner-setup.sh)"; continue; }
  say "clone:  $dir"

  git -C "$dir" fetch -q --prune local || { warn "$r: fetch from $BARE failed"; continue; }
  git -C "$dir" fetch -q origin || warn "$r: could not fetch GitHub (continuing)"

  def=$(git --git-dir="$BARE/$r.git" symbolic-ref --short HEAD)
  cur=$(git -C "$dir" symbolic-ref --short -q HEAD || echo "")
  before=$(git -C "$dir" rev-parse -q --verify "refs/heads/$def" || echo "")
  target=$(git -C "$dir" rev-parse "local/$def")

  if [ -z "$before" ]; then
    git -C "$dir" branch -q "$def" "local/$def" && say "$def: created from local/$def"
  elif [ "$before" = "$target" ]; then
    say "$def: already up to date"
  elif ! git -C "$dir" merge-base --is-ancestor "$before" "$target"; then
    if git -C "$dir" merge-base --is-ancestor "$target" "$before"; then
      say "$def: you are ahead of local/$def (nothing to pull)"
    else
      warn "$r: your $def and local/$def have diverged; not touching it (ask for a rebase, or merge by hand)"
    fi
  elif [ "$cur" = "$def" ]; then
    if git -C "$dir" merge -q --ff-only "local/$def"; then
      say "$def: fast-forwarded $(git -C "$dir" rev-parse --short "$before")..$(git -C "$dir" rev-parse --short HEAD) (checked out)"
    else
      warn "$r: fast-forward of checked-out $def failed (uncommitted changes in the way?)"
    fi
  else
    git -C "$dir" update-ref "refs/heads/$def" "$target" "$before" \
      && say "$def: fast-forwarded $(git -C "$dir" rev-parse --short "$before")..$(git -C "$dir" rev-parse --short "$target") (you are on ${cur:-detached HEAD})"
  fi

  if git -C "$dir" rev-parse -q --verify "origin/$def" >/dev/null; then
    pending=$(git -C "$dir" log --format='        %h %s  [A:%an C:%cn]' "origin/$def..$def")
    [ -n "$pending" ] && { say "ready to push ($def, not yet on GitHub):"; say "$pending"; }
  fi

  others=""
  for ref in $(git -C "$dir" branch -r --format='%(refname:short)' --list 'local/*'); do
    br=${ref#local/}
    { [ "$br" = "$def" ] || [ "$br" = HEAD ] || [ "$br" = local ]; } && continue
    [ "$(git -C "$dir" rev-parse -q --verify "origin/$br" || true)" = "$(git -C "$dir" rev-parse "$ref")" ] && continue
    others="$others $ref"
  done
  [ -n "$others" ] && say "review branches:$others"
done

say ""
say "Done. Nothing was pushed. To publish a repo: cd <clone> && git push origin <default>"
exit $status
