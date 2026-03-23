#!/usr/bin/env bash
set -euo pipefail

gh search issues \
  --repo dotnet/sdk \
  --state open \
  --label "Area-Containers" \
  --label "untriaged" \
  --sort created \
  --order desc \
  --json number,title,labels,createdAt \
  --template '{{range .}}#{{.number}}	{{.title}}	{{join ", " (pluck "name" .labels)}}	{{timeago .createdAt}}
{{end}}' \
  -- "is:issue" | column -t -s $'\t'
