[CmdletBinding()]
param(
	[string]$PackageManifest,
	[string]$PackageManifestUrl = 'https://raw.githubusercontent.com/lbussell/dotfiles/main/.windows/winget-packages.json'
)

$ErrorActionPreference = 'Stop'

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
	throw 'WinGet is required before running this setup script.'
}

if (-not $PackageManifest -and $PSScriptRoot) {
	$PackageManifest = Join-Path $PSScriptRoot 'winget-packages.json'
}

$tempManifest = $null

try {
	if ($PackageManifest -and (Test-Path -LiteralPath $PackageManifest)) {
		$manifestPath = (Resolve-Path -LiteralPath $PackageManifest).Path
	}
	else {
		$tempManifest = Join-Path ([System.IO.Path]::GetTempPath()) "winget-packages-$([Guid]::NewGuid()).json"
		Invoke-WebRequest -Uri $PackageManifestUrl -OutFile $tempManifest
		$manifestPath = $tempManifest
	}

	$manifest = Get-Content -Raw -LiteralPath $manifestPath | ConvertFrom-Json
	$packageCount = @($manifest.Sources[0].Packages).Count
	Write-Host "Installing $packageCount WinGet packages from $manifestPath"

	winget import --import-file $manifestPath --accept-package-agreements --accept-source-agreements
}
finally {
	if ($tempManifest -and (Test-Path -LiteralPath $tempManifest)) {
		Remove-Item -LiteralPath $tempManifest -Force
	}
}
