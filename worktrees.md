# Worktree Workflow Design

When running `w`:
1. Show the user some compact git status.
    - Show pull request info if there's one associated with the current branch
    - List worktrees if there are any
2. Accept input:
    g: go to worktree
    n: create worktree
    d: remove worktrees
    o: open pull request in browser (if there is a PR)

## Go to worktree

Let the user select what worktree to `cd` to using gum.

## Creating new worktrees

1. Select base - could be one of:
    - local or remote branch
    - new branch based on a remote branch
    - new branch based on my local branch/HEAD
    - new branch from a commit
    - detached
    - an open pull request (smartly figures out if you already have it in a branch or in a worktree)
2. If necessary, ask for the worktree name/branch name
3. Create it

## Removing worktrees

1. Use gum to prompt multiple-selection of all the worktrees
    - Show associated PR details, since the user likely wants to clean up worktrees where PRs have been merged.
2. Confirm before removing
