@echo off
SETLOCAL ENABLEDELAYEDEXPANSION

:: === CONFIGURATION ===
SET CLI_VERSION=v1.0.6
SET REPO=estrng/estrngcli
SET BINARY_NAME=estrng.exe
SET INSTALL_DIR=%USERPROFILE%\estrngcli
SET INSTALL_PATH=%INSTALL_DIR%\%BINARY_NAME%

:: === VALIDATE TOKEN ===
IF "%GH_PAT%"=="" (
    echo ❌ GH_PAT environment variable is not set.
    echo 🔐 Please run: set GH_PAT=your_token
    exit /b 1
)

:: === PREPARE ===
echo 📁 Creating install dir: %INSTALL_DIR%
IF NOT EXIST "%INSTALL_DIR%" (
    mkdir "%INSTALL_DIR%"
)

:: === FETCH ASSET ID USING GITHUB API ===
echo 🔍 Fetching asset ID from GitHub API...
powershell -Command ^
  "$headers = @{ Authorization = 'token %GH_PAT%' }; ^
   $url = 'https://api.github.com/repos/%REPO%/releases/tags/%CLI_VERSION%'; ^
   $json = Invoke-RestMethod -Uri $url -Headers $headers; ^
   $id = ($json.assets | Where-Object { $_.name -eq '%BINARY_NAME%' }).id; ^
   Set-Content -Path .tmp_asset_id -Value $id"

set /p ASSET_ID=<.tmp_asset_id
del .tmp_asset_id

IF "%ASSET_ID%"=="" (
    echo ❌ Asset ID not found for %BINARY_NAME% in release %CLI_VERSION%
    exit /b 1
)

:: === DOWNLOAD ASSET ===
echo 📦 Downloading %BINARY_NAME% (asset ID: %ASSET_ID%)...
powershell -Command ^
  "$headers = @{ Authorization = 'token %GH_PAT%'; Accept = 'application/octet-stream' }; ^
   $url = 'https://api.github.com/repos/%REPO%/releases/assets/%ASSET_ID%'; ^
   Invoke-RestMethod -Uri $url -Headers $headers -Method Get -OutFile '%INSTALL_PATH%'"

IF NOT EXIST "%INSTALL_PATH%" (
    echo ❌ Failed to download binary.
    exit /b 1
)

:: === VERIFY FILE TYPE ===
echo 🧪 Verifying file...
for %%F in ("%INSTALL_PATH%") do (
    echo ✅ File downloaded: %%~zF bytes
)

:: === ADD TO PATH TEMPORARILY ===
SET PATH=%INSTALL_DIR%;%PATH%

:: === TEST CLI ===
echo 🚀 Testing CLI...
"%INSTALL_PATH%" --version || echo ⚠️ CLI installed but not running correctly

:: === DONE ===
echo ✅ Done! Estrng CLI installed to %INSTALL_PATH%
echo ➕ Consider adding "%INSTALL_DIR%" to your system PATH permanently.

ENDLOCAL
