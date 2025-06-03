@echo off
set VERSION=v1.0.0
set BINARY=epy.exe
set REPO=estrng/epy
set GH_API=https://api.github.com/repos/%REPO%/releases/tags/%VERSION%
set DEST=%USERPROFILE%\epy

echo 🔐 Checking GH_PAT...
if "%GH_PAT%"=="" (
    echo ❌ GH_PAT not set!
    exit /b 1
)

if not exist %DEST% (
    mkdir %DEST%
)

set FILE=%DEST%\%BINARY%

echo 🔽 Downloading %BINARY%...
powershell -Command "Invoke-WebRequest -Uri 'https://%GH_PAT%@github.com/%REPO%/releases/download/%VERSION%/%BINARY%' -OutFile '%FILE%'"

echo ✅ Downloaded to %FILE%

%FILE% --help
