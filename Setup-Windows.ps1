[CmdletBinding()]
param(
	[switch]$SkipPackages,
	[string]$AllHostsProfilePath = (Join-Path ([Environment]::GetFolderPath('MyDocuments')) 'PowerShell\profile.ps1'),
	[string]$CurrentHostProfilePath = (Join-Path ([Environment]::GetFolderPath('MyDocuments')) 'PowerShell\Microsoft.PowerShell_profile.ps1')
)

$ErrorActionPreference = 'Stop'

function Update-ProcessPath {
	$separator = [IO.Path]::PathSeparator
	$entries = @(
		$env:PATH -split $separator
		[Environment]::GetEnvironmentVariable('Path', 'User') -split $separator
		[Environment]::GetEnvironmentVariable('Path', 'Machine') -split $separator
	) | Where-Object { $_ } | Select-Object -Unique

	$env:PATH = $entries -join $separator
}

function Install-WinGetPackage {
	param(
		[Parameter(Mandatory)]
		[string]$Id,

		[Parameter(Mandatory)]
		[string]$Command
	)

	if (Get-Command $Command -ErrorAction SilentlyContinue) {
		Write-Host "$Command is already installed."
		return
	}

	if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
		throw 'WinGet is required before running this setup script.'
	}

	$previousNativeCommandErrorPreference = $PSNativeCommandUseErrorActionPreference
	try {
		$PSNativeCommandUseErrorActionPreference = $false
		winget list --id $Id --exact --accept-source-agreements | Out-Null
		if ($LASTEXITCODE -eq 0) {
			Update-ProcessPath
			if (Get-Command $Command -ErrorAction SilentlyContinue) {
				Write-Host "$Command is already installed."
				return
			}

			throw "$Id is installed but $Command is not available on PATH."
		}

		Write-Host "Installing $Id..."
		winget install --id $Id --exact --accept-package-agreements --accept-source-agreements
		$installExitCode = $LASTEXITCODE
	}
	finally {
		$PSNativeCommandUseErrorActionPreference = $previousNativeCommandErrorPreference
	}

	if ($installExitCode -ne 0) {
		throw "WinGet failed to install $Id."
	}
	Update-ProcessPath
	if (-not (Get-Command $Command -ErrorAction SilentlyContinue)) {
		throw "$Command was installed but is not available on PATH. Open a new PowerShell session and run setup again."
	}
}

function Set-PowerShellProfileBootstrap {
	param(
		[Parameter(Mandatory)]
		[string]$Path
	)

	$beginMarker = '# BEGIN chezmoi managed PowerShell profile'
	$endMarker = '# END chezmoi managed PowerShell profile'
	$newLine = [Environment]::NewLine
	$managedBlock = @'
# BEGIN chezmoi managed PowerShell profile
$sharedProfile = Join-Path $HOME '.config\powershell\profile.ps1'
if (Test-Path -LiteralPath $sharedProfile) {
	. $sharedProfile
}
# END chezmoi managed PowerShell profile
'@ -replace "`r?`n", $newLine

	$content = if (Test-Path -LiteralPath $Path) {
		Get-Content -Raw -LiteralPath $Path
	}
	else {
		''
	}

	$pattern = "(?ms)^$([regex]::Escape($beginMarker))\r?\n.*?^$([regex]::Escape($endMarker))\r?\n?"
	$match = [regex]::Match($content, $pattern)
	if ($match.Success) {
		$content = $content.Substring(0, $match.Index) + $managedBlock + $newLine + $content.Substring($match.Index + $match.Length)
	}
	else {
		$prefix = if ([string]::IsNullOrWhiteSpace($content)) {
			''
		}
		else {
			$content.TrimEnd() + $newLine + $newLine
		}
		$content = $prefix + $managedBlock + $newLine
	}

	$parent = Split-Path -Parent $Path
	if ($parent) {
		New-Item -ItemType Directory -Force -Path $parent | Out-Null
	}

	$existing = if (Test-Path -LiteralPath $Path) {
		Get-Content -Raw -LiteralPath $Path
	}
	else {
		$null
	}

	if ($existing -cne $content) {
		[IO.File]::WriteAllText($Path, $content, [Text.UTF8Encoding]::new($false))
		Write-Host "Updated $Path"
	}
	else {
		Write-Host "$Path is already configured."
	}
}

function Remove-LegacyCurrentHostBootstrap {
	param(
		[Parameter(Mandatory)]
		[string]$Path
	)

	if (-not (Test-Path -LiteralPath $Path)) {
		return
	}

	$content = (((Get-Content -Raw -LiteralPath $Path) -replace "`r`n?", "`n").Trim()).Replace('\', '/')
	$legacyProfiles = @(
		(@'
$sharedProfile = Join-Path $HOME '.config/powershell/profile.ps1'
. $sharedProfile
'@ -replace "`r`n?", "`n"),
		(@'
$sharedProfile = Join-Path $HOME '.config/powershell/profile.ps1'
if (Test-Path -LiteralPath $sharedProfile) {
    . $sharedProfile
}
'@ -replace "`r`n?", "`n")
	)
	$legacyProfiles = $legacyProfiles.ForEach({ $_.Trim() })

	if ($content -cin $legacyProfiles) {
		Remove-Item -LiteralPath $Path
		Write-Host "Removed legacy bootstrap from $Path"
	}
}

if (-not $SkipPackages) {
	Install-WinGetPackage -Id 'twpayne.chezmoi' -Command 'chezmoi'
	Install-WinGetPackage -Id 'charmbracelet.gum' -Command 'gum'
}

Set-PowerShellProfileBootstrap -Path $AllHostsProfilePath
if ($CurrentHostProfilePath -ne $AllHostsProfilePath) {
	Remove-LegacyCurrentHostBootstrap -Path $CurrentHostProfilePath
}
