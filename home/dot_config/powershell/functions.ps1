# Interactively select a repo under SOURCE_DIR with gum and cd into it
function s {
    $root = $env:SOURCE_DIR
    if (-not $root) {
        Write-Warning 'SOURCE_DIR is not set'
        return
    }

    $repos = Get-ChildItem -Path $root -Directory |
        ForEach-Object { Get-ChildItem -Path $_.FullName -Directory } |
        ForEach-Object { $_.FullName.Substring($root.Length + 1) } |
        Sort-Object

    if (-not $repos) {
        Write-Warning "No repos found under $root"
        return
    }

    $selected = gum filter --height 10 --placeholder 'Select a repo...' -- $repos
    if ($selected) {
        Set-Location (Join-Path $root $selected)
    }
}

# Interactively select a worktree for the current repo with gum and cd into it
function w {
    $worktreeOutput = git worktree list --porcelain 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Warning 'Not in a git repo'
        return
    }

    $worktrees = @()
    $current = $null

    foreach ($line in $worktreeOutput) {
        if ([string]::IsNullOrWhiteSpace($line)) {
            if ($current) {
                $worktrees += [pscustomobject]$current
                $current = $null
            }
            continue
        }

        if ($line -like 'worktree *') {
            if ($current) {
                $worktrees += [pscustomobject]$current
            }
            $current = [ordered]@{
                Path   = $line.Substring('worktree '.Length)
                Branch = '(detached)'
            }
            continue
        }

        if (-not $current) {
            continue
        }

        if ($line -like 'branch *') {
            $branch = $line.Substring('branch '.Length)
            if ($branch -like 'refs/heads/*') {
                $branch = $branch.Substring('refs/heads/'.Length)
            }
            $current.Branch = $branch
        } elseif ($line -eq 'bare') {
            $current.Branch = '(bare)'
        }
    }

    if ($current) {
        $worktrees += [pscustomobject]$current
    }

    if (-not $worktrees) {
        Write-Warning 'No worktrees found'
        return
    }

    $choices = $worktrees | ForEach-Object {
        $_ | Add-Member -NotePropertyName Display -NotePropertyValue ("{0}  [{1}]" -f $_.Path, $_.Branch) -PassThru
    }

    $selected = gum choose --height 10 --header 'Select a worktree...' --select-if-one -- ($choices.Display)
    if ($selected) {
        $worktree = $choices | Where-Object { $_.Display -eq $selected } | Select-Object -First 1
        if ($worktree) {
            Set-Location $worktree.Path
        }
    }
}
