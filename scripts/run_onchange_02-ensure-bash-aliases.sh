#!/bin/bash
# Ensure ~/.bashrc sources ~/.bash_aliases. Runs on chezmoi init and when this script changes.

set -euo pipefail

BASHRC="$HOME/.bashrc"
SOURCE_LINE='[ -f ~/.bash_aliases ] && . ~/.bash_aliases'

# Create .bashrc if it doesn't exist
if [ ! -f "$BASHRC" ]; then
    echo "$SOURCE_LINE" > "$BASHRC"
    echo "Created $BASHRC with bash_aliases source line"
    exit 0
fi

# Already present? Nothing to do
if grep -qF "$SOURCE_LINE" "$BASHRC"; then
    echo "$BASHRC already sources ~/.bash_aliases — nothing to do"
    exit 0
fi

# Append the source line
echo "$SOURCE_LINE" >> "$BASHRC"
echo "Appended bash_aliases source line to $BASHRC"
