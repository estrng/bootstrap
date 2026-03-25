# init.ps1
#Requires -Version 5.1
[CmdletBinding()]
param(
    [string]$GH_PAT = $env:GH_PAT
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$CLI_VERSION  = "v1.1.3"
$REPO         = "estrng/estrngcli"
$ASSET_NAME   = "estrng-windows-x64.exe"
$BINARY_NAME  = "estrng.exe"
$INSTALL_DIR  = "$env:USERPROFILE\estrngcli"
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
$asset   = $release.assets | Where-Object { $_.name -eq $ASSET_NAME }

if (-not $asset) {
    Write-Error "Asset '$ASSET_NAME' not found in release $CLI_VERSION"
    exit 1
}

if (-not (Test-Path $INSTALL_DIR)) {
    New-Item -ItemType Directory -Path $INSTALL_DIR | Out-Null
}

Write-Host "Downloading $ASSET_NAME (asset ID: $($asset.id))..."
$assetApiUrl = "https://api.github.com/repos/$REPO/releases/assets/$($asset.id)"

$httpReq = [System.Net.HttpWebRequest]::CreateHttp($assetApiUrl)
$httpReq.Headers.Add("Authorization", "token $GH_PAT")
$httpReq.Accept = "application/octet-stream"
$httpReq.AllowAutoRedirect = $false
$httpReq.UserAgent = "PowerShell"

$httpResp = $httpReq.GetResponse()
$directUrl = $httpResp.Headers["Location"]
$httpResp.Close()

if (-not $directUrl) {
    Write-Error "GitHub did not return a redirect URL for the asset. Check your PAT permissions."
    exit 1
}

$wc = New-Object System.Net.WebClient
$wc.DownloadFile($directUrl, $INSTALL_PATH)
$wc.Dispose()

if (-not (Test-Path $INSTALL_PATH)) {
    Write-Error "Download failed."
    exit 1
}

$fileBytes = [System.IO.File]::ReadAllBytes($INSTALL_PATH)
if ($fileBytes[0] -ne 0x4D -or $fileBytes[1] -ne 0x5A) {
    Remove-Item $INSTALL_PATH -Force
    Write-Error "Downloaded file is not a valid Windows executable (expected MZ header). The release asset may be corrupt."
    exit 1
}

Write-Host "File size: $((Get-Item $INSTALL_PATH).Length) bytes"

$currentPath = [Environment]::GetEnvironmentVariable("PATH", "User")
if ($currentPath -notlike "*$INSTALL_DIR*") {
    [Environment]::SetEnvironmentVariable("PATH", "$currentPath;$INSTALL_DIR", "User")
    Write-Host "Added $INSTALL_DIR to your PATH permanently."
}

Write-Host ""
Write-Host "Verifying installation..."
try {
    $output = & $INSTALL_PATH help 2>&1
    Write-Host "OK: $output"
} catch {
    Write-Error "Installation verification failed: $_"
    exit 1
}

Write-Host ""
Write-Host "Done! Estrng CLI installed to $INSTALL_PATH"
Write-Host "Restart your terminal, then run: estrng"
Write-Host "More info: https://github.com/$REPO"