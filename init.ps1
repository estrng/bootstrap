# init.ps1
#Requires -Version 5.1
[CmdletBinding()]
param(
    [string]$GH_PAT = $env:GH_PAT
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$CLI_VERSION = "v1.1.1"
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
$assetApiUrl = "https://api.github.com/repos/$REPO/releases/assets/$($asset.id)"
Write-Host "[DEBUG] Step 1: GET $assetApiUrl (AllowAutoRedirect=false)"

$httpReq = [System.Net.HttpWebRequest]::CreateHttp($assetApiUrl)
$httpReq.Headers.Add("Authorization", "token $GH_PAT")
$httpReq.Accept = "application/octet-stream"
$httpReq.AllowAutoRedirect = $false
$httpReq.UserAgent = "PowerShell"

$httpResp = $httpReq.GetResponse()
Write-Host "[DEBUG] Step 1 response: HTTP $([int]$httpResp.StatusCode) $($httpResp.StatusDescription)"
Write-Host "[DEBUG] Content-Type: $($httpResp.ContentType)"
$directUrl = $httpResp.Headers["Location"]
Write-Host "[DEBUG] Location header: $(if ($directUrl) { $directUrl.Substring(0, [Math]::Min(80, $directUrl.Length)) + '...' } else { '(none)' })"
$httpResp.Close()

if (-not $directUrl) {
    Write-Error "GitHub did not return a redirect URL for the asset. Check your PAT permissions."
    exit 1
}

Write-Host "[DEBUG] Step 2: Downloading from S3 pre-signed URL (no auth headers)..."
$wc = New-Object System.Net.WebClient
$wc.DownloadFile($directUrl, $INSTALL_PATH)
$wc.Dispose()

if (-not (Test-Path $INSTALL_PATH)) {
    Write-Error "Download failed."
    exit 1
}

$fileSize = (Get-Item $INSTALL_PATH).Length
$fileBytes = [System.IO.File]::ReadAllBytes($INSTALL_PATH)
Write-Host "[DEBUG] Downloaded file size: $fileSize bytes"
Write-Host "[DEBUG] First 4 bytes (hex): $($fileBytes[0].ToString('X2')) $($fileBytes[1].ToString('X2')) $($fileBytes[2].ToString('X2')) $($fileBytes[3].ToString('X2'))"

if ($fileBytes[0] -ne 0x4D -or $fileBytes[1] -ne 0x5A) {
    $previewLength = [Math]::Min(500, $fileSize)
    $textPreview = [System.Text.Encoding]::UTF8.GetString($fileBytes, 0, $previewLength)
    Write-Host "[DEBUG] File content preview (first 500 bytes as UTF-8):"
    Write-Host $textPreview
    Remove-Item $INSTALL_PATH -Force
    Write-Error "Downloaded file is not a valid Windows executable (expected MZ header)."
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
    Write-Error "Installation verification failed. The binary did not execute successfully: $_"
    exit 1
}

Write-Host ""
Write-Host "Done! Estrng CLI installed to $INSTALL_PATH"
Write-Host "Restart your terminal, then run: estrng"
Write-Host "More info: https://github.com/$REPO"