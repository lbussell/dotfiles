# git.sh — Git helper functions

checkout() { gh pr checkout "$@"; }

register_command "Git" "checkout" "Shortcut for gh pr checkout"

wt() {
  local dir
  dir=$(tv git-worktrees) && pushd "$dir"
}

register_command "Git" "wt" "Pick a git worktree and pushd into it"
