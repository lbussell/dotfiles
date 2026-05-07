#!/usr/bin/env bash
set -euo pipefail

ROOT=$(git rev-parse --show-toplevel)
OUTDIR="$ROOT/.rendered-examples"
STATE_BASE="$ROOT/.cache/rendered-examples"

mkdir -p "$OUTDIR" "$STATE_BASE"
rm -rf "$OUTDIR"/* "$STATE_BASE"/*

examples=$(chezmoi data | jq -r '.examples | keys[]')
for name in $examples; do
  dest="$OUTDIR/$name"
  state="$STATE_BASE/$name-state.boltdb"
  mkdir -p "$dest"
  config=$(mktemp)
  cat > "$config" <<EOF
sourceDir: $ROOT
destDir: $dest
data:
  os: $(chezmoi data | jq -r --arg n "$name" '.examples[$n].os')
  username: $(chezmoi data | jq -r --arg n "$name" '.examples[$n].username')
  ephemeral: $(chezmoi data | jq -r --arg n "$name" '.examples[$n].ephemeral')
  email: $(chezmoi data | jq -r --arg n "$name" '.examples[$n].email')
  work: $(chezmoi data | jq -r --arg n "$name" '.examples[$n].work')
  immutable: $(chezmoi data | jq -r --arg n "$name" '.examples[$n].immutable')
  headless: $(chezmoi data | jq -r --arg n "$name" '.examples[$n].headless')
  minimal: $(chezmoi data | jq -r --arg n "$name" '.examples[$n].minimal')
  hostname: $(chezmoi data | jq -r --arg n "$name" '.examples[$n].hostname')
  personal: $(chezmoi data | jq -r --arg n "$name" '.examples[$n].personal')
  osid: $(chezmoi data | jq -r --arg n "$name" '.examples[$n].osid')
  package_manager: $(chezmoi data | jq -r --arg n "$name" '.examples[$n].package_manager')
EOF

  chezmoi apply --force --exclude=scripts --config "$config" --config-format yaml --destination "$dest" --persistent-state "$state" >/dev/null
  rm -f "$config"
done

echo "Rendered examples to $OUTDIR"
find "$OUTDIR" -maxdepth 2 -type f | sort
