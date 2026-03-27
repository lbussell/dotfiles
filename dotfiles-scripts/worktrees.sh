# worktrees.sh — Worktree helpers

w() {
  local dir
  dir=$(WorktreeManager) && pushd "$dir"
}

register_command "Worktrunk" "w" "Interactively pick a git worktree and jump to it"

wl() {
  local worktrees
  worktrees=$(git worktree list 2>/dev/null) || { echo "Not in a git repo."; return 1; }
  [[ -z "$worktrees" ]] && { echo "No worktrees found."; return 1; }

  local selection
  selection=$(echo "$worktrees" | gum filter --height 10 --header "Pick a worktree:") || return 0
  local dir="${selection%% *}"
  pushd "$dir"
}

register_command "Worktrunk" "wl" "Pick a local worktree and switch to it"

new() {
  # Step 1: Pick a repo (pre-fill with current repo if inside ~/src/)
  local current_repo=""
  if [[ "$PWD" == "$HOME/src/"* ]]; then
    current_repo="${PWD#$HOME/src/}"
    current_repo="${current_repo%%/*}"
  fi

  local repo
  repo=$(ls -1 ~/src/ | gum filter --height 10 --header "Pick a repo:" --value "$current_repo") || return 1
  echo "Repo: $repo"
  local repo_dir=~/src/"$repo"

  # Step 2: cd into the repo
  pushd "$repo_dir" > /dev/null || { echo "Could not cd to $repo_dir"; return 1; }

  # Step 3: Pick a base branch
  local base
  base=$(gum choose --header="Base branch:" \
    "upstream/main" \
    "upstream/nightly" \
    "main" \
    "(other)") || { popd > /dev/null; return 0; }

  if [[ "$base" == "(other)" ]]; then
    base=$(gum input --header="Custom base branch:" --placeholder="origin/main") || { popd > /dev/null; return 0; }
    [[ -z "$base" ]] && { echo "No base branch provided."; popd > /dev/null; return 1; }
  fi
  echo "Base: $base"

  # Step 4: Fetch remotes
  gum spin --title "Fetching remotes..." -- git fetch --all

  # Step 5: Feature name
  local feature
  feature=$(gum input --header="Feature name:" --placeholder="my-feature") || { popd > /dev/null; return 0; }
  [[ -z "$feature" ]] && { echo "No feature name provided."; popd > /dev/null; return 1; }
  echo "Feature: $feature"

  # Step 5: Create worktree
  local cmd="wt switch -c -b $base $feature"
  gum style --faint "→ $cmd"
  eval "$cmd"
}

register_command "Worktrunk" "new" "Quick worktree creation wizard (repo → fetch → branch → create)"
