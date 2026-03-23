# init.ps1
#Requires -Version 5.1
[CmdletBinding()]
param(
    [string]$GH_PAT = $env:GH_PAT
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$CLI_VERSION = "v1.1.0"
$REPO        = "estrng/estrngcli"
$BINARY_NAME = "estrng.exe"
$INSTALL_DIR = "$env:USERPROFILE\estrngcli"
$INSTALL_PATH = "$INSTALL_DIR\$BINARY_NAME"

if (-not $GH_PAT) {
    Write-Error "GH_PAT is not set. Export it first: `$env:GH_PAT = 'your_token'"
    exit 1
}

$headers = @{
    Authorization = "token $GH_PAT"
    Accept        = "application/vnd.github+json"
}

Write-Host "Fetching asset ID from GitHub API..."
$release = Invoke-RestMethod -Uri "https://api.github.com/repos/$REPO/releases/tags/$CLI_VERSION" -Headers $headers
$asset   = $release.assets | Where-Object { $_.name -eq $BINARY_NAME }

if (-not $asset) {
    Write-Error "Asset '$BINARY_NAME' not found in release $CLI_VERSION"
    exit 1
}

if (-not (Test-Path $INSTALL_DIR)) {
    New-Item -ItemType Directory -Path $INSTALL_DIR | Out-Null
}

Write-Host "Downloading $BINARY_NAME (asset ID: $($asset.id))..."
$downloadHeaders = @{
    Authorization = "token $GH_PAT"
    Accept        = "application/octet-stream"
}
Invoke-RestMethod -Uri "https://api.github.com/repos/$REPO/releases/assets/$($asset.id)" `
    -Headers $downloadHeaders -OutFile $INSTALL_PATH

if (-not (Test-Path $INSTALL_PATH)) {
    Write-Error "Download failed."
    exit 1
}

Write-Host "File size: $((Get-Item $INSTALL_PATH).Length) bytes"

$currentPath = [Environment]::GetEnvironmentVariable("PATH", "User")
if ($currentPath -notlike "*$INSTALL_DIR*") {
    [Environment]::SetEnvironmentVariable("PATH", "$currentPath;$INSTALL_DIR", "User")
    Write-Host "Added $INSTALL_DIR to your PATH permanently."
}

Write-Host ""
Write-Host "Done! Estrng CLI installed to $INSTALL_PATH"
Write-Host "Restart your terminal, then run: estrng"
Write-Host "More info: https://github.com/$REPO"