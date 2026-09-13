$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $false

function Update-ProcessPath {
    $separator = [IO.Path]::PathSeparator
    $entries = @(
        $env:PATH -split $separator
        [Environment]::GetEnvironmentVariable('Path', 'User') -split $separator
        [Environment]::GetEnvironmentVariable('Path', 'Machine') -split $separator
    ) | Where-Object { $_ } | Select-Object -Unique

    $env:PATH = $entries -join $separator
}

if ($env:OS -ne 'Windows_NT') {
    throw 'This setup script is for Windows.'
}

Update-ProcessPath
if (-not (Get-Command chezmoi.exe -CommandType Application -ErrorAction SilentlyContinue)) {
    if (-not (Get-Command winget.exe -CommandType Application -ErrorAction SilentlyContinue)) {
        throw 'WinGet is required. Install or update App Installer from Microsoft Store, then run setup again.'
    }

    winget.exe install --id twpayne.chezmoi --exact --source winget --accept-package-agreements --accept-source-agreements
    if ($LASTEXITCODE -ne 0) {
        throw "WinGet failed to install chezmoi (exit code $LASTEXITCODE)."
    }
    Update-ProcessPath
    if (-not (Get-Command chezmoi.exe -CommandType Application -ErrorAction SilentlyContinue)) {
        throw 'chezmoi was installed but is not available on PATH. Open a new terminal and run setup again.'
    }
}

chezmoi.exe init --apply lbussell
if ($LASTEXITCODE -ne 0) {
    throw "chezmoi setup failed (exit code $LASTEXITCODE)."
}

Write-Host 'Setup complete.'
