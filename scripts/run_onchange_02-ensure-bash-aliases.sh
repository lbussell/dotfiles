#!/bin/bash
# Ensure ~/.bashrc sources ~/.config/shell/aliases.sh.
# Uses a managed block so the script can be updated without leaving stale lines.
# Runs on chezmoi init and when this script changes.

set -euo pipefail

BASHRC="$HOME/.bashrc"
BLOCK_START="# BEGIN chezmoi-managed aliases block"
BLOCK_END="# END chezmoi-managed aliases block"

# Write the desired block to a temp file
BLOCK_FILE=$(mktemp)
cat > "$BLOCK_FILE" <<'ENDBLOCK'
# BEGIN chezmoi-managed aliases block
# User aliases (chezmoi-generated)
[ -f ~/.config/shell/aliases.sh ] && . ~/.config/shell/aliases.sh

# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
    for rc in ~/.bashrc.d/*; do
        if [ -f "$rc" ]; then
            . "$rc"
        fi
    done
fi
unset rc

alias reload="source ~/.bashrc"
# END chezmoi-managed aliases block
ENDBLOCK

DESIRED=$(cat "$BLOCK_FILE")
rm -f "$BLOCK_FILE"

# Create .bashrc if it doesn't exist
if [ ! -f "$BASHRC" ]; then
    printf '%s\n' "$DESIRED" > "$BASHRC"
    echo "Created $BASHRC with chezmoi-managed aliases block"
    exit 0
fi

# Extract existing managed block, if any
EXISTING=$(sed -n "/^$BLOCK_START$/,/^$BLOCK_END$/p" "$BASHRC" 2>/dev/null || true)

if [ -n "$EXISTING" ]; then
    if [ "$EXISTING" = "$DESIRED" ]; then
        echo "$BASHRC already has up-to-date chezmoi aliases block — nothing to do"
        exit 0
    fi
    # Block exists but is stale — delete old block and re-append
    TMPFILE=$(mktemp)
    sed "/^$BLOCK_START$/,/^$BLOCK_END$/d" "$BASHRC" > "$TMPFILE"
    printf '\n%s\n' "$DESIRED" >> "$TMPFILE"
    mv "$TMPFILE" "$BASHRC"
    echo "Updated chezmoi-managed aliases block in $BASHRC"
else
    # No block yet — append it
    printf '\n%s\n' "$DESIRED" >> "$BASHRC"
    echo "Added chezmoi-managed aliases block to $BASHRC"
fi
