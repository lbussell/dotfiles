---
name: rebase
description: Use when rebasing a branch.
user-invokable: true
disable-model-invocation: true
---

# Rebase

The user will provide a remote and branch name to rebase onto.
If the user doesn't provide the remote and/or branch name, ask them for it.
Usually, the pattern will be `<remote>/<branch>`.
`origin` and `upstream` are typical remote names.

Always fetch the latest changes from the remote before rebasing, unless the
user specifies a local branch. The user might provide just the branch name, in which case you can assume that
they want to rebase onto a local branch. In this instance, don't fetch the
latest changes from the remote. When in doubt check `git remote -v`.

Typical examples are:
- `upstream/main` - rebase onto the main branch of the upstream remote
- `upstream/nightly` - rebase onto the nightly branch of the upstream remote
- `origin/main` - rebase onto the main branch of the origin remote
- `dev/username/feature` - rebase onto a local branch named `dev/username/feature`

After you have the correct remote and branch name, perform the rebase using
`git rebase <remote>/<branch>` or `git rebase <branch>` for local branches.
Handle any conflicts that arise during the rebase process. If you don't know
how to resolve a conflict, ask the user for guidance on how to proceed.
