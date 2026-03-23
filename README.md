# Estrng CLI Bootstrap 🚀

release v1.1.2
epy-release v1.1.2

This repository helps install the private [estrng/estrngcli](https://github.com/estrng/estrngcli) and [estrng/estrng-py](https://github.com/estrng/estrng-py) on any machine quickly.

## 🧪 Install Estrng CLI (Linux/macOS)

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/estrng/bootstrap/main/init.sh)"
```

## 🧪 Install Estrng Python CLI (Linux/macOS)

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/estrng/bootstrap/main/init-py.sh)"
```

## 🧪 Install Estrng CLI (Windows)

A GitHub Personal Access Token (PAT) with access to `estrng/estrngcli` is required.

**Option 1 — Run directly without saving the file:**

```powershell
$env:GH_PAT = "your_token_here"
iex (iwr -Uri "https://raw.githubusercontent.com/estrng/bootstrap/main/init.ps1" -UseBasicParsing -Headers @{ Authorization = "token $env:GH_PAT" }).Content
```

**Option 2 — Download first, then run:**

```powershell
# 1. Download
iwr -Uri "https://raw.githubusercontent.com/estrng/bootstrap/main/init.ps1" `
    -Headers @{ Authorization = "token YOUR_PAT" } `
    -OutFile "$env:TEMP\init.ps1" -UseBasicParsing

# 2. Run
powershell -ExecutionPolicy Bypass -File "$env:TEMP\init.ps1" -GH_PAT "YOUR_PAT"
```

After installation completes, **restart your terminal** and run `estrng help` to verify.

## 🛠 Requirements

- cURL or PowerShell (preinstalled in most systems)
- Internet access to download the binary from GitHub Releases
- A GitHub PAT with read access to the private `estrng/estrngcli` repository (Windows only)
