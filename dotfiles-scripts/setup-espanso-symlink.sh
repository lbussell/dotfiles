#!/usr/bin/env bash
set -euo pipefail

# Symlinks the macOS espanso config directory to ~/.config/espanso
# so espanso config can be tracked in dotfiles via .config/espanso.
#
# Per https://espanso.org/docs/sync/#macos:
#   1. The real config lives at ~/.config/espanso (tracked by YADM)
#   2. A symlink at ~/Library/Application Support/espanso points to it

DOTFILES_CONFIG="$HOME/.config/espanso"
ESPANSO_DEFAULT="$HOME/Library/Application Support/espanso"

if [ ! -d "$DOTFILES_CONFIG" ]; then
    echo "Error: $DOTFILES_CONFIG does not exist."
    echo "Create your espanso config there first (or run 'yadm checkout')."
    exit 1
fi

# If the default location is already a symlink pointing to the right place, we're done.
if [ -L "$ESPANSO_DEFAULT" ]; then
    current_target="$(readlink "$ESPANSO_DEFAULT")"
    if [ "$current_target" = "$DOTFILES_CONFIG" ]; then
        echo "Symlink already exists: $ESPANSO_DEFAULT -> $DOTFILES_CONFIG"
        exit 0
    else
        echo "Removing existing symlink (pointed to $current_target)..."
        rm "$ESPANSO_DEFAULT"
    fi
elif [ -d "$ESPANSO_DEFAULT" ]; then
    # Real directory exists — move contents into dotfiles config if needed, then remove.
    echo "Found existing espanso config at $ESPANSO_DEFAULT"
    echo "Merging into $DOTFILES_CONFIG..."

    # Copy any files not already present in the dotfiles config
    rsync -a --ignore-existing "$ESPANSO_DEFAULT/" "$DOTFILES_CONFIG/"

    # Back up and remove the original
    backup="$ESPANSO_DEFAULT.bak.$(date +%s)"
    mv "$ESPANSO_DEFAULT" "$backup"
    echo "Original config backed up to $backup"
fi

# Ensure parent directory exists
mkdir -p "$(dirname "$ESPANSO_DEFAULT")"

ln -s "$DOTFILES_CONFIG" "$ESPANSO_DEFAULT"
echo "Created symlink: $ESPANSO_DEFAULT -> $DOTFILES_CONFIG"
echo ""
echo "Restart espanso to pick up the change:"
echo "  espanso restart"
