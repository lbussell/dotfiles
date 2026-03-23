#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <issue-number>" >&2
  exit 1
fi

gh issue view "$1" --repo dotnet/sdk --comments
