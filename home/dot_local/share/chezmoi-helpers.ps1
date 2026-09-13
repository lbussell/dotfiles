function Show-ChezmoiMotd {
    $launchArguments = [Environment]::GetCommandLineArgs()
    if ([Console]::IsInputRedirected -or [Console]::IsOutputRedirected -or
        (Test-Path -LiteralPath (Join-Path $HOME '.hushlogin')) -or
        $env:CI -or $env:CHEZMOI -or
        ($launchArguments -match '^-(NonI.*|Command.*|EncodedCommand|e|ec|File|f|c)$')) {
        return
    }

    $chezmoi = Get-Command chezmoi -CommandType Application -ErrorAction SilentlyContinue
    if (-not $chezmoi) {
        Write-Warning 'Cannot check your dotfiles: install chezmoi or add it to your PATH.'
        return
    }

    $PSNativeCommandUseErrorActionPreference = $false
    $status = @(& $chezmoi.Source status --color=false)
    if ($LASTEXITCODE -ne 0) {
        Write-Warning 'Could not check your dotfiles. Run chezmoi status to see what went wrong.'
        return
    } elseif ($status.Count -eq 0) {
        return
    }

    Write-Host 'Your dotfiles have pending local changes.'
    Write-Host '  Review changes:      chezmoi diff'
    Write-Host '  Apply configuration: chezmoi apply'
    Write-Host "  Sync from GitHub:    chezmoi update`n"
}
