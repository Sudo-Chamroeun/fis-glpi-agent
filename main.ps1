<#
.SYNOPSIS
    GLPI Agent Interactive Installer Menu
#>

# 1. Ensure Administrator
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "ERROR: Please run this script as Administrator!" -ForegroundColor Red
    Break
}

# 2. Clear and Display Menu
Clear-Host
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "   GLPI Agent Deployment Menu" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "1. Install as Laptop" -ForegroundColor Yellow
Write-Host "2. Install as Desktop" -ForegroundColor Yellow
Write-Host "3. Install as Server" -ForegroundColor Yellow
Write-Host "4. Exit" -ForegroundColor Red
Write-Host "=========================================" -ForegroundColor Cyan

# 3. Get User Choice
$Choice = Read-Host "Select an option (1-4)"

switch ($Choice) {
    "1" { $Tag = "Laptop" }
    "2" { $Tag = "Desktop" }
    "3" { $Tag = "Server" }
    "4" { Write-Host "Exiting..."; Break }
    Default { Write-Host "Invalid choice. Exiting." -ForegroundColor Red; Break }
}

Write-Host "`nPreparing to install as $Tag..." -ForegroundColor Green

# 4. Download the installer.ps1 from GitHub
# IMPORTANT: Update this URL to your actual raw GitHub URL
$InstallerUrl = "https://raw.githubusercontent.com/Sudo-Chamroeun/fis-glpi-agent/refs/heads/main/installer.ps1"
$InstallerPath = "$env:TEMP\glpi-installer.ps1"

Write-Host "Downloading installer script..."
try {
    Invoke-WebRequest -Uri $InstallerUrl -OutFile $InstallerPath -UseBasicParsing
} catch {
    Write-Host "Failed to download installer.ps1. Check your GitHub repo is public." -ForegroundColor Red
    Break
}

# 5. Execute installer.ps1 using cmd.exe to avoid PowerShell environment issues
Write-Host "Running installation via cmd.exe..." -ForegroundColor Cyan
# We use cmd.exe to call powershell.exe -File, and the .ps1 file itself uses cmd.exe for msiexec
$CmdArgs = "/c powershell.exe -ExecutionPolicy Bypass -File `"$InstallerPath`" -Tag $Tag"
Start-Process cmd.exe -ArgumentList $CmdArgs -Wait -NoNewWindow

Write-Host "`nProcess finished. Press any key to exit." -ForegroundColor Green
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
