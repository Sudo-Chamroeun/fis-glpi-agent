#https://raw.githubusercontent.com/Sudo-Chamroeun/fis-glpi-agent/refs/heads/main/installer.ps1"
<#
.SYNOPSIS
    GLPI Agent Interactive Management Menu
#>

# 1. Ensure Administrator
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "ERROR: Please run this script as Administrator!" -ForegroundColor Red
    Break
}

# Function to pause the screen so the user can read messages
function Pause-Menu {
    Write-Host "`nPress any key to return to the menu..." -ForegroundColor Yellow
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

# Function to handle the installation
function Install-Agent($Tag) {
    Write-Host "`nPreparing to install as $Tag..." -ForegroundColor Green
    
    # Download the installer.ps1 from GitHub
    $InstallerUrl = "https://raw.githubusercontent.com/Sudo-Chamroeun/fis-glpi-agent/refs/heads/main/installer.ps1"
    $InstallerPath = "$env:TEMP\glpi-installer.ps1"
    
    Write-Host "Downloading installer script..." -ForegroundColor Cyan
    try {
        Invoke-WebRequest -Uri $InstallerUrl -OutFile $InstallerPath -UseBasicParsing
    } catch {
        Write-Host "Failed to download installer.ps1. Check your GitHub repo is public." -ForegroundColor Red
        Pause-Menu
        return
    }

    # Execute installer.ps1 using cmd.exe
    Write-Host "Running installation via cmd.exe..." -ForegroundColor Cyan
    $CmdArgs = "/c powershell.exe -ExecutionPolicy Bypass -File `"$InstallerPath`" -Tag $Tag"
    Start-Process cmd.exe -ArgumentList $CmdArgs -Wait -NoNewWindow
    
    Pause-Menu
}

# Function to force the agent to sync immediately
function Force-Sync {
    Write-Host "`nForcing GLPI Agent to sync..." -ForegroundColor Cyan
    
    # Correct path to the agent's executable/batch file
    $AgentExe = "C:\Program Files\GLPI-Agent\glpi-agent.bat"
    
    if (Test-Path $AgentExe) {
        # We call it via cmd.exe to ensure the environment is correct, just like the installer
        $Process = Start-Process cmd.exe -ArgumentList "/c `"$AgentExe`" --force" -Wait -PassThru -NoNewWindow
        
        if ($Process.ExitCode -eq 0) {
            Write-Host "Sync command sent successfully." -ForegroundColor Green
        } else {
            Write-Host "Sync command failed with exit code $($Process.ExitCode)." -ForegroundColor Red
        }
    } else {
        Write-Host "GLPI Agent not found at $AgentExe" -ForegroundColor Red
    }
    Pause-Menu
}

# Function to uninstall the agent
function Uninstall-Agent {
    Write-Host "`nSearching for GLPI Agent..." -ForegroundColor Cyan
    
    # Search the registry for the GLPI Agent uninstall string
    $GlpiApp = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object { $_.DisplayName -like '*GLPI Agent*' }
    
    if ($GlpiApp) {
        Write-Host "Found $($GlpiApp.DisplayName). Uninstalling..." -ForegroundColor Yellow
        $Process = Start-Process msiexec.exe -ArgumentList "/x $($GlpiApp.PSChildName) /quiet" -Wait -PassThru -NoNewWindow
        
        if ($Process.ExitCode -eq 0) {
            Write-Host "Uninstalled successfully." -ForegroundColor Green
        } else {
            Write-Host "Uninstall failed with exit code $($Process.ExitCode)." -ForegroundColor Red
        }
    } else {
        Write-Host "GLPI Agent is not installed on this machine." -ForegroundColor Yellow
    }
    Pause-Menu
}

# --- MAIN MENU LOOP ---
while ($true) {
    Clear-Host
    Write-Host "=========================================" -ForegroundColor Cyan
    Write-Host "   GLPI Agent Deployment Menu" -ForegroundColor Cyan
    Write-Host "=========================================" -ForegroundColor Cyan
    Write-Host "1. Install as Laptop" -ForegroundColor Yellow
    Write-Host "2. Install as Desktop" -ForegroundColor Yellow
    Write-Host "3. Install as Server" -ForegroundColor Yellow
    Write-Host "F. Force Agent Sync (Run Inventory Now)" -ForegroundColor Magenta
    Write-Host "U. Uninstall GLPI Agent" -ForegroundColor Red
    Write-Host "0. Exit & Clear Screen" -ForegroundColor Red
    Write-Host "=========================================" -ForegroundColor Cyan

    $Choice = Read-Host "Select an option"

    switch ($Choice) {
        "1" { Install-Agent "Laptop" }
        "2" { Install-Agent "Desktop" }
        "3" { Install-Agent "Server" }
        "F" { Force-Sync }
        "f" { Force-Sync }
        "U" { Uninstall-Agent }
        "u" { Uninstall-Agent }
        "0" { 
            Clear-Host
            Write-Host "Exiting. Have a great day!" -ForegroundColor Green
            Break 
        }
        Default { 
            Write-Host "Invalid choice. Please try again." -ForegroundColor Red
            Start-Sleep -Seconds 1
        }
    }
}
