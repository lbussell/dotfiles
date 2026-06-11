# Directory and session navigation helpers

s() {
  local choice
  choice=$(ls -1 ~/src/ | gum filter --height 10 --header "Pick a directory:" --no-show-help) || return 1
  pushd ~/src/"$choice"
}

alias b=popd
alias up=cd ../

# git-worktree-gum.sh — composable worktree helpers using charmbracelet/gum
# Source from your .bashrc / .zshrc:  source ~/git-worktree-gum.sh
#
# Worktree dirs are named  <parent>/<repoName>.<slug>
#
# Layout:
#   _wt_*      low-level pickers/helpers — each does ONE thing, prints to stdout
#   wt*        user-facing commands that compose the pickers
#
# Flow control: pickers/inputs exit non-zero on cancel (Esc/Ctrl-C), so a
# trailing `|| return` is all that's needed to abort. git reports its own errors.

# ---------- primitives ----------

_wt_root()     { git rev-parse --show-toplevel 2>/dev/null; }
_wt_repo()     { basename "$(_wt_root)"; }
_wt_parent()   { dirname "$(_wt_root)"; }
_wt_path_for() { echo "$(_wt_parent)/$(_wt_repo).$1"; }

# Pick an existing local branch.
_wt_pick_branch() {
  git branch --format='%(refname:short)' \
    | gum filter --height 10 --placeholder "${1:-pick a branch}"
}

# Pick any commit-ish (branches + tags + HEAD), or type one in.
_wt_pick_ref() {
  { git branch --format='%(refname:short)'; git tag; echo HEAD; } \
    | gum filter --height 10 --placeholder "${1:-pick a commit/branch/tag}"
}

# Pick an existing worktree path. Pass --exclude-root to omit the main worktree.
_wt_pick_worktree() {
  local root=""
  [ "$1" = "--exclude-root" ] && root=$(_wt_root)
  git worktree list --porcelain \
    | awk '/^worktree /{print $2}' \
    | { [ -n "$root" ] && grep -v "^$root$" || cat; } \
    | gum filter --height 10 --placeholder "pick a worktree"
}

# Prompt for a path, prefilled with an editable default.
_wt_input_path() { gum input --value "$1" --placeholder "worktree path"; }

# Prompt for a non-empty name. Fails if empty.
_wt_input_name() {
  local n; n=$(gum input --placeholder "${1:-name}") || return
  [ -n "$n" ] && echo "$n"
}

_wt_ok() { gum style --foreground 2 "$*"; }

w() {
  local worktree_path
  if ! _wt_root >/dev/null; then
    gum style --foreground 1 "Not in a git repository."
    return 1
  fi
  worktree_path=$(_wt_pick_worktree) || return
  cd "$worktree_path"
}

wn() {
  local mode branch ref slug worktree_path

  mode=$(gum choose --height 10 "existing branch" "new branch" "detached") || return
  case "$mode" in
    "existing branch") branch=$(_wt_pick_branch) || return; slug=$branch ;;
    "new branch")      branch=$(_wt_input_name "new-branch-name") || return; slug=$branch ;;
    "detached")        ref=$(_wt_pick_ref) || return
                       slug=$(_wt_input_name "worktree name") || return ;;
  esac

  worktree_path=$(_wt_input_path "$(_wt_path_for "$slug")") || return

  case "$mode" in
    "existing branch") gum spin --title "Creating worktree…" -- git worktree add "$worktree_path" "$branch" || return ;;
    "new branch")      gum spin --title "Creating worktree…" -- git worktree add -b "$branch" "$worktree_path" || return ;;
    "detached")        gum spin --title "Creating detached worktree…" -- git worktree add --detach "$worktree_path" "$ref" || return ;;
  esac

  _wt_ok "Created $worktree_path"
  cd "$worktree_path"
}

wrm() {
  local worktree_path; worktree_path=$(_wt_pick_worktree --exclude-root) || return
  gum confirm "Remove $worktree_path?" || return
  git worktree remove "$worktree_path" 2>/dev/null \
    || { gum confirm "Has changes. Force remove?" && git worktree remove --force "$worktree_path"; }
  git worktree prune
  _wt_ok "Done."
}

# wtls — pretty list of worktrees.
wtls() { git worktree list | gum format -t code; }
