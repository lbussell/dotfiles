# Dotfiles Agent Instructions

You are responsible for managing the user's dotfiles.
Manage dotfiles are using `yadm`.
Some files that the user asks you to edit might not be tracked in `yadm` -- if they aren't, offer to track them.

## Dotfiles structure

- `~/.zshrc` — main shell config (zsh, macOS)
- `~/dotfiles-scripts/*.sh` — shell helper functions, auto-sourced by `index.sh`
- `~/.config/ghostty/` — terminal config
- `~/.config/nvim/` — Neovim (LazyVim) config
- `~/.brewfile` — Homebrew bundle

## Homebrew

The `brew` command is wrapped — `install`, `uninstall`, `reinstall`, and `upgrade` automatically dump the updated package list to `~/.brewfile` and commit it via yadm. No manual tracking needed. Use `brew-sync` on a new machine to install everything from the brewfile.

## Adding shell functions

New `.sh` files in `~/dotfiles-scripts/` are automatically sourced. Register commands for discoverability:

```zsh
register_command "Category" "command_name" "Short description"
```

This makes them appear in `dothelp` output.
Tell the user to test shell changes with the `reload` function.

