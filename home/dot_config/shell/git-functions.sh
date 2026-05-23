# Prompts for a directory under ~/src and prints the selected directory name.
src_choose_directory() {
  ls -1 ~/src/ | gum filter --height 10 --header "Pick a directory:" --no-show-help
}

# Changes into a selected directory under ~/src.
s() {
  local choice
  choice=$(src_choose_directory) || return 1
  pushd ~/src/"$choice"
}

# Ensures the current directory is inside a git repository.
git_require_repo() {
  git rev-parse --git-common-dir >/dev/null 2>&1 || {
    echo "Not in a git repository." >&2
    return 1
  }
}

# Prints the root path of the current git repository.
git_repo_root() {
  git rev-parse --show-toplevel
}

# Prints the current repository name, preferring remote.origin.url over the directory name.
git_repo_name() {
  local origin_url
  local repo_name=""
  local repo_root

  repo_root=$(git_repo_root) || return 1
  origin_url=$(git config --get remote.origin.url 2>/dev/null)

  if [ -n "$origin_url" ]; then
    repo_name=$(printf '%s\n' "$origin_url" | sed 's#/*$##; s#\.git$##; s#^.*/##; s#^.*:##')
  fi

  if [ -z "$repo_name" ]; then
    repo_name=$(basename "$repo_root") || return 1
  fi

  printf '%s\n' "$repo_name"
}

# Prints the directory where new worktrees should be created.
git_worktrees_dir() {
  local worktrees_dir

  worktrees_dir=${WORKTREES_DIR:-"$HOME/w"}
  case "$worktrees_dir" in
    "~") worktrees_dir=$HOME ;;
    "~/"*) worktrees_dir="$HOME/${worktrees_dir#"~/"}" ;;
  esac

  printf '%s\n' "$worktrees_dir"
}

# Prints selectable worktree records as "display path [branch]:actual path".
git_worktree_records() {
  git worktree list --porcelain | awk -v h="$HOME" '
    /^worktree / { path=substr($0,10); next }
    /^branch /   { br=substr($0,8); sub("^refs/heads/","",br) }
    /^detached/  { br="detached" }
    /^$/         { disp=path; sub("^"h,"~",disp); print disp " [" br "]:" path; br="" }
    END          { if (path && br!="") { disp=path; sub("^"h,"~",disp); print disp " [" br "]:" path } }
  '
}

# Prompts for an existing git worktree and prints its path.
git_choose_worktree() {
  local worktrees

  worktrees=$(git_worktree_records) || return 1
  if [ -z "$worktrees" ]; then
    echo "No git worktrees found." >&2
    return 1
  fi

  printf '%s\n' "$worktrees" | gum choose --height 10 --label-delimiter=":" --header "Pick a worktree:" --no-show-help
}

# Prints the current branch for a worktree, or its short commit when detached.
git_worktree_branch() {
  local branch
  local worktree_path=$1

  branch=$(git -C "$worktree_path" symbolic-ref --quiet --short HEAD 2>/dev/null)
  if [ -z "$branch" ]; then
    branch=$(git -C "$worktree_path" rev-parse --short HEAD) || return 1
    branch="detached ($branch)"
  fi

  printf '%s\n' "$branch"
}

# Prints a staged, unstaged, and untracked file count summary for a worktree.
git_worktree_status_summary() {
  local git_status
  local worktree_path=$1

  git_status=$(git -C "$worktree_path" status --porcelain) || return 1
  printf '%s\n' "$git_status" | awk '
    length($0) == 0 { next }
    substr($0, 1, 2) == "??" { untracked++; next }
    substr($0, 1, 1) != " " { staged++ }
    substr($0, 2, 1) != " " { unstaged++ }
    END { printf "%d staged, %d unstaged, %d untracked", staged, unstaged, untracked }
  '
}

# Prints the current GitHub PR summary and URL for a worktree, if one exists.
git_worktree_pr_info() {
  local worktree_path=$1

  (cd "$worktree_path" && gh pr view --json number,url,state --template '#{{.number}} {{.state}}: {{.url}}{{"\n"}}{{.url}}' 2>/dev/null)
}

# Renders a markdown-formatted worktree summary with gum.
git_render_worktree_summary() {
  local branch=$2
  local pr=$3
  local status_summary=$4
  local worktree_path=$1

  printf '# Worktree\n- **Path:** %s\n- **Branch:** %s\n- **PR:** %s\n- **Status:** %s\n' "$worktree_path" "$branch" "$pr" "$status_summary" | gum format
}

# Prompts for the next action to perform on a selected worktree.
git_choose_worktree_action() {
  local actions
  local pr_url=$1

  actions=()
  actions+=("Go there")
  if [ -n "$pr_url" ]; then
    actions+=("Open PR in browser")
  fi
  actions+=("Remove worktree")

  printf '%s\n' "${actions[@]}" | gum choose --height 10 --header "What next:" --no-show-help
}

# Runs a selected worktree action against the provided worktree path.
git_run_worktree_action() {
  local action=$1
  local pr_url=$3
  local worktree_path=$2

  case "$action" in
    "Go there")
      pushd "$worktree_path"
      ;;
    "Open PR in browser")
      open "$pr_url"
      ;;
    "Remove worktree")
      git worktree remove "$worktree_path"
      ;;
    *)
      echo "Invalid worktree action: $action" >&2
      return 1
      ;;
  esac
}

# Selects a worktree, shows its details, and prompts for an action to perform.
w() {
  local action
  local branch
  local choice
  local pr="none"
  local pr_info
  local pr_url=""
  local status_summary

  git_require_repo || return 1

  choice=$(git_choose_worktree) || return 1
  branch=$(git_worktree_branch "$choice") || return 1
  status_summary=$(git_worktree_status_summary "$choice") || return 1

  pr_info=$(git_worktree_pr_info "$choice") || pr_info=""
  if [ -n "$pr_info" ]; then
    pr=$(printf '%s\n' "$pr_info" | sed -n '1p')
    pr_url=$(printf '%s\n' "$pr_info" | sed -n '2p')
  fi

  git_render_worktree_summary "$choice" "$branch" "$pr" "$status_summary"
  echo ""

  action=$(git_choose_worktree_action "$pr_url") || return 1
  git_run_worktree_action "$action" "$choice" "$pr_url"
}

# Ensures a command exists on PATH.
git_require_command() {
  local command_name=$1

  command -v "$command_name" >/dev/null 2>&1 || {
    echo "Required command not found: $command_name" >&2
    return 1
  }
}

# Prints selectable open pull request records as "label<TAB>number".
git_pr_records() {
  local limit=${GH_PR_LIST_LIMIT:-200}

  gh pr list --state open --limit "$limit" --json number,title,author,headRefName,isDraft --template '{{range .}}{{if .isDraft}}[draft] {{end}}#{{.number}} {{.title}} ({{.author.login}}:{{.headRefName}}){{"\t"}}{{.number}}{{"\n"}}{{end}}'
}

# Prompts for an open pull request and prints the selected PR number.
git_choose_pr() {
  local delimiter
  local prs

  prs=$(git_pr_records) || return 1
  if [ -z "$prs" ]; then
    echo "No open pull requests found." >&2
    return 1
  fi

  delimiter=$(printf '\t')
  printf '%s\n' "$prs" | gum choose --height 20 --label-delimiter="$delimiter" --header "Pick a pull request:" --no-show-help
}

# Prints the synthetic git ref used for a fetched pull request head.
git_pr_ref() {
  local pr_number=$1

  printf 'refs/remotes/github-pr/%s/head\n' "$pr_number"
}

# Prints the pull request's base repository URL.
git_pr_base_url() {
  local base_url
  local pr_number=$1
  local pr_url

  pr_url=$(gh pr view "$pr_number" --json url --jq '.url') || return 1
  base_url=$(printf '%s\n' "$pr_url" | sed 's#/pull/[0-9][0-9]*$##')
  if [ "$base_url" = "$pr_url" ]; then
    echo "Could not determine base repository URL for PR #$pr_number." >&2
    return 1
  fi

  printf '%s\n' "$base_url"
}

# Fetches a pull request head into a synthetic local remote ref and prints that ref.
git_fetch_pr_ref() {
  local base_url
  local pr_number=$1
  local pr_ref

  base_url=$(git_pr_base_url "$pr_number") || return 1
  pr_ref=$(git_pr_ref "$pr_number") || return 1

  echo "Fetching PR #$pr_number from $base_url" >&2
  git fetch "$base_url" "+refs/pull/$pr_number/head:$pr_ref" || return 1
  git rev-parse --verify --quiet "$pr_ref^{commit}" >/dev/null || return 1

  printf '%s\n' "$pr_ref"
}

# Prints the PR head branch name when the PR comes from the current repository.
git_pr_same_repo_head_branch() {
  local pr_number=$1

  gh pr view "$pr_number" --json headRefName,isCrossRepository --jq 'if .isCrossRepository then "" else .headRefName end'
}

# Prints the preferred local branch name for a pull request.
git_pr_local_branch() {
  local head_branch
  local pr_number=$1

  head_branch=$(git_pr_same_repo_head_branch "$pr_number") || return 1
  if [ -n "$head_branch" ] && git_branch_exists "$head_branch"; then
    printf '%s\n' "$head_branch"
    return 0
  fi

  printf 'pr/%s\n' "$pr_number"
}

# Returns success when the named local branch exists.
git_branch_exists() {
  local branch=$1

  git show-ref --verify --quiet "refs/heads/$branch"
}

# Prints the worktree path where a local branch is checked out, if any.
git_branch_worktree_path() {
  local branch=$1

  git worktree list --porcelain | awk -v target="refs/heads/$branch" '
    /^worktree / { path=substr($0,10); next }
    /^branch /   { if (substr($0,8) == target) { print path; exit } }
  '
}

# Prints how a local branch relates to another commit-ish: same, behind, ahead, or diverged.
git_branch_divergence() {
  local branch=$1
  local branch_sha
  local other=$2
  local other_sha

  branch_sha=$(git rev-parse --verify "$branch^{commit}") || return 1
  other_sha=$(git rev-parse --verify "$other^{commit}") || return 1

  if [ "$branch_sha" = "$other_sha" ]; then
    printf '%s\n' "same"
  elif git merge-base --is-ancestor "$other" "$branch"; then
    printf '%s\n' "ahead"
  elif git merge-base --is-ancestor "$branch" "$other"; then
    printf '%s\n' "behind"
  else
    printf '%s\n' "diverged"
  fi
}

# Builds and prints the default worktree path for a pull request.
git_pr_worktree_path() {
  local branch
  local pr_number=$1
  local repo_name

  branch=$(git_pr_local_branch "$pr_number") || return 1
  repo_name=$(git_repo_name) || return 1

  git_new_worktree_path "$repo_name" "$branch"
}

# Returns success when a worktree has an in-progress git operation.
git_worktree_has_operation() {
  local state
  local state_path
  local worktree_path=$1

  for state in MERGE_HEAD REBASE_HEAD CHERRY_PICK_HEAD REVERT_HEAD rebase-merge rebase-apply; do
    state_path=$(git -C "$worktree_path" rev-parse --git-path "$state") || return 1
    if [ -e "$state_path" ]; then
      return 0
    fi
  done

  return 1
}

# Returns success when a worktree has no tracked, untracked, or staged changes.
git_worktree_clean() {
  local worktree_path=$1

  [ -z "$(git -C "$worktree_path" status --porcelain)" ]
}

# Returns success when a worktree is safe to fast-forward in place.
git_worktree_can_fast_forward() {
  local worktree_path=$1

  git_worktree_clean "$worktree_path" || return 1
  ! git_worktree_has_operation "$worktree_path"
}

# Fast-forwards a local branch to a PR ref when it is safe to do so.
git_fast_forward_pr_branch() {
  local branch=$1
  local divergence
  local pr_ref=$2
  local worktree_path=$3

  divergence=$(git_branch_divergence "$branch" "$pr_ref") || return 1
  case "$divergence" in
    same)
      return 0
      ;;
    behind)
      if [ -n "$worktree_path" ]; then
        if git_worktree_can_fast_forward "$worktree_path"; then
          echo "Fast-forwarding $branch in $worktree_path." >&2
          git -C "$worktree_path" merge --ff-only "$pr_ref"
        else
          echo "Branch '$branch' is behind the PR, but its worktree is dirty or busy; opening without updating." >&2
        fi
      else
        echo "Fast-forwarding $branch to the PR head." >&2
        git branch -f "$branch" "$pr_ref"
      fi
      ;;
    ahead)
      echo "Branch '$branch' is ahead of the PR head; opening without updating." >&2
      ;;
    diverged)
      echo "Branch '$branch' has diverged from the PR head; opening without updating." >&2
      ;;
    *)
      echo "Unknown branch divergence: $divergence" >&2
      return 1
      ;;
  esac
}

# Creates a worktree for an existing local branch.
git_add_branch_worktree() {
  local branch=$1
  local worktree_path=$2

  mkdir -p "$(dirname "$worktree_path")" || return 1
  git worktree add "$worktree_path" "$branch"
}

# Opens a pull request branch in a worktree, creating or updating safe local state.
git_open_pr_worktree() {
  local branch=$1
  local existing_worktree_path
  local pr_ref=$3
  local worktree_path=$2

  if git_branch_exists "$branch"; then
    existing_worktree_path=$(git_branch_worktree_path "$branch") || return 1
    if [ -n "$existing_worktree_path" ]; then
      git_fast_forward_pr_branch "$branch" "$pr_ref" "$existing_worktree_path" || return 1
      pushd "$existing_worktree_path"
      return
    fi

    git_fast_forward_pr_branch "$branch" "$pr_ref" "" || return 1
    git_add_branch_worktree "$branch" "$worktree_path" || return 1
    pushd "$worktree_path"
    return
  fi

  git_create_worktree "$branch" "$worktree_path" "$pr_ref" || return 1
  pushd "$worktree_path"
}

# Selects an open pull request and opens it in a git worktree.
wpr() {
  local branch
  local pr_number
  local pr_ref
  local worktree_path

  git_require_repo || return 1
  git_require_command gh || return 1
  git_require_command gum || return 1

  pr_number=$(git_choose_pr) || return 1
  echo "Selected PR: #$pr_number" >&2

  pr_ref=$(git_fetch_pr_ref "$pr_number") || return 1
  branch=$(git_pr_local_branch "$pr_number") || return 1
  worktree_path=$(git_pr_worktree_path "$pr_number") || return 1

  echo "Selected branch: $branch" >&2
  echo "Selected worktree path: $worktree_path" >&2

  git_open_pr_worktree "$branch" "$worktree_path" "$pr_ref"
}

# Prompts for the base source to use when creating a new worktree.
git_choose_worktree_start() {
  local remotes

  remotes=$(git remote) || return 1
  {
    echo "HEAD"
    printf '%s\n' "$remotes" | sed '/^$/d; s/^/remote: /'
  } | gum choose --height 10 --header "Create new worktree from:" --no-show-help
}

# Prints branch names available under a remote's refs/remotes namespace.
git_remote_branches() {
  local remote=$1

  git for-each-ref --format='%(refname)' "refs/remotes/$remote" | awk -v prefix="refs/remotes/$remote/" '
    $0 == prefix "HEAD" { next }
    index($0, prefix) == 1 { print substr($0, length(prefix) + 1) }
  '
}

# Prompts for a branch from the given remote and prints the selected branch name.
git_choose_remote_branch() {
  local remote=$1
  local remote_branches

  remote_branches=$(git_remote_branches "$remote") || return 1
  if [ -z "$remote_branches" ]; then
    echo "No branches found for remote '$remote'." >&2
    return 1
  fi

  printf '%s\n' "$remote_branches" | gum filter --height 10 --header "Pick a branch from $remote:" --no-show-help
}

# Resolves the selected worktree start source into a git start point.
git_resolve_start_point() {
  local base_choice
  local remote
  local remote_branch

  base_choice=$(git_choose_worktree_start) || return 1
  echo "Selected start: $base_choice" >&2

  case "$base_choice" in
    HEAD)
      printf '%s\n' "HEAD"
      ;;
    remote:\ *)
      remote=${base_choice#remote: }
      git fetch "$remote" || return 1

      remote_branch=$(git_choose_remote_branch "$remote") || return 1
      echo "Selected remote branch: $remote_branch" >&2
      printf '%s\n' "$remote/$remote_branch"
      ;;
    *)
      echo "Invalid start point: $base_choice" >&2
      return 1
      ;;
  esac
}

# Prompts for and prints a required new branch name.
git_prompt_branch_name() {
  local branch

  branch=$(gum input --prompt "Branch name: " --placeholder "feature/my-branch") || return 1
  if [ -z "$branch" ]; then
    echo "Branch name is required." >&2
    return 1
  fi

  printf '%s\n' "$branch"
}

# Builds and prints the path for a new worktree.
git_new_worktree_path() {
  local branch=$2
  local repo_name=$1
  local worktrees_dir

  worktrees_dir=$(git_worktrees_dir) || return 1
  printf '%s\n' "$worktrees_dir/$repo_name/$branch"
}

# Creates a new git worktree at the provided path and branch.
git_create_worktree() {
  local branch=$1
  local start_point=$3
  local worktree_path=$2

  mkdir -p "$(dirname "$worktree_path")" || return 1
  git worktree add --no-track -b "$branch" "$worktree_path" "$start_point"
}

# Creates a new worktree from HEAD or a selected remote branch, then changes into it.
wn() {
  local branch
  local repo_name
  local start_point
  local worktree_path

  git_require_repo || return 1

  repo_name=$(git_repo_name) || return 1
  start_point=$(git_resolve_start_point) || return 1

  branch=$(git_prompt_branch_name) || return 1
  echo "Selected branch name: $branch"

  worktree_path=$(git_new_worktree_path "$repo_name" "$branch") || return 1
  echo "Selected worktree path: $worktree_path"

  git_create_worktree "$branch" "$worktree_path" "$start_point" || return 1
  pushd "$worktree_path"
}
