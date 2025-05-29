@echo off
SETLOCAL ENABLEDELAYEDEXPANSION

echo.
echo ===============================================
echo       Estrng CLI - Instalador para Windows
echo ===============================================
echo.

SET CLI_VERSION=v1.0.4
SET REPO=estrng/estrngcli
SET FILENAME=estrng.exe
SET DEST=%USERPROFILE%\.estrngcli
SET EXEC=%DEST%\%FILENAME%
SET URL=https://github.com/%REPO%/releases/download/%CLI_VERSION%/%FILENAME%

:: Criar pasta destino
IF NOT EXIST "%DEST%" (
    mkdir "%DEST%"
)

echo 🔽 Baixando Estrng CLI...
powershell -Command "Invoke-WebRequest -Uri '%URL%' -OutFile '%EXEC%'"

IF NOT EXIST "%EXEC%" (
    echo ❌ Falha ao baixar o executável.
    exit /b 1
)

:: PATH temporário
echo 🔗 Adicionando ao PATH da sessão...
SET "PATH=%DEST%;%PATH%"

echo 🧪 Testando execução...
"%EXEC%" --version

echo.
echo ✅ Instalado com sucesso!
echo ➕ Para adicionar ao PATH permanentemente, execute:
echo setx PATH "%%PATH%%;%DEST%" /M
echo.
ENDLOCAL
