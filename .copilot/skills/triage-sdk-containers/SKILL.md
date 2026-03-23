---
name: triage-sdk-containers
description: Triage untriaged container issues in the dotnet/sdk repo. Lists open issues with Area-Containers + untriaged labels, then summarizes each issue for quick review. Use when the user wants to triage SDK container issues.
user-invokable: true
disable-model-invocation: true
---

# Triage SDK Container Issues

Summarize untriaged container issues in [dotnet/sdk](https://github.com/dotnet/sdk) for efficient triage.

## Workflow

1. **Fetch the issue list** by running `scripts/get-untriaged-issues.sh` (relative to this skill's directory).
2. **For each issue**, launch a sub-agent (explore agent) to get details and produce a short summary. Use `scripts/get-issue-details.sh <number>` to fetch the issue body and comments.
3. **Present a triage report** with all summaries once every sub-agent has completed.

Run sub-agents in parallel to save time. Each sub-agent should:
- Run `scripts/get-issue-details.sh <number>` to read the issue
- Produce a 2–3 sentence summary of the problem
- Suggest a category: `bug`, `feature-request`, `test-debt`, `docs`, or `question`
- Note if the issue looks stale or has a suggested fix

Do NOT have sub-agents investigate source code or attempt fixes — just summarize what the issue is asking for.

## Output Format

Present results as a table:

| # | Title | Category | Summary |
|---|-------|----------|---------|
| 12345 | Example title | bug | Short summary of the issue. |

Sort by created date (newest first), matching the script output order.

