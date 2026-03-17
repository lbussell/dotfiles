# worktrunk.sh — Interactive worktree wizard (gum-powered)

wti() {
  # Step 1: What do you want to do?
  local action
  action=$(gum choose --header="What do you want to do?" \
    "Create a new branch" \
    "Switch to existing worktree" \
    "Check out a PR") || return 0

  local cmd="wt switch"

  case "$action" in
    "Create a new branch")
      # Branch name
      local branch
      branch=$(gum input --header="Branch name" --placeholder="my-feature") || return 0
      [[ -z "$branch" ]] && { echo "No branch name provided."; return 1; }

      # Base branch
      local base
      base=$(gum choose --header="Base branch" \
        "upstream/main" \
        "upstream/nightly" \
        "(custom)") || return 0

      if [[ "$base" == "(custom)" ]]; then
        base=$(gum input --header="Custom base branch" --placeholder="origin/main") || return 0
        [[ -z "$base" ]] && { echo "No base branch provided."; return 1; }
      fi

      cmd+=" --create $branch --base $base"
      ;;

    "Switch to existing worktree")
      local branches
      branches=$(wt list --format=json --branches 2>/dev/null \
        | jq -r '.[] | ((now - .commit.timestamp) / 3600 | floor) as $h |
          (if $h < 1 then "just now" elif $h < 24 then "\($h)h" elif ($h/24|floor) < 30 then "\($h/24|floor)d" elif ($h/24|floor) < 365 then "\($h/24/30|floor)mo" else "\($h/24/365|floor)y" end) as $age |
          "\(.branch) (\(.kind), \($age))"' 2>/dev/null)
      [[ -z "$branches" ]] && { echo "No branches found."; return 1; }

      local selection
      selection=$(echo "$branches" | gum choose --header="Pick a branch") || return 0
      cmd+=" ${selection%% (*}"
      ;;

    "Check out a PR")
      local pr
      pr=$(gum input --header="PR number" --placeholder="123") || return 0
      [[ -z "$pr" ]] && { echo "No PR number provided."; return 1; }
      cmd+=" pr:$pr"
      ;;
  esac

  # Launch copilot?
  if gum confirm "Launch copilot after switching?" --default; then
    cmd+=" -x copilot"
  fi

  # Show and execute
  gum style --faint "→ $cmd"
  eval "$cmd"
}

register_command "Worktrunk" "wti" "Interactive worktree wizard (gum-powered)"
