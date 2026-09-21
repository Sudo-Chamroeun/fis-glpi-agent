#Main Menu Interface
<#
.SYNOPSIS
    Automated GLPI Agent Installer
.DESCRIPTION
    Downloads the GLPI Agent MSI from a GitHub repository and installs it silently.
    Requires Administrator privileges. Safe to run from PowerShell.
.PARAMETER Tag
    The inventory tag to assign to this machine (e.g., "Desktop", "Laptop", "Server").
.EXAMPLE
    .\main.ps1 -Tag "Laptop"
#>

param(
    [Parameter(Mandatory=$false)]
    [string]$Tag = "Desktop"
)

# 1. Ensure the script is running as Administrator
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "Please run this script as Administrator!"
    Break
}

# 2. Configuration Variables
$MsiUrl = "https://agent-inventory.footprints.work/GLPI-Agent-1.19-x64.msi"
$MsiPath = "$env:TEMP\GLPI-Agent.msi"
$GlpiServer = "http://172.26.0.2:9090/front/inventory.php"

Write-Host "Starting GLPI Agent installation..." -ForegroundColor Cyan
Write-Host "Tag: $Tag" -ForegroundColor Yellow
Write-Host "Server: $GlpiServer" -ForegroundColor Yellow

# 3. Download the MSI
Write-Host "Downloading agent from $MsiUrl..."
try {
    Invoke-WebRequest -Uri $MsiUrl -OutFile $MsiPath -UseBasicParsing
    Write-Host "Download complete." -ForegroundColor Green
} catch {
    Write-Error "Failed to download the MSI. Check the URL and your internet connection."
    Break
}

# 4. Install the MSI silently — THE FIX IS HERE
Write-Host "Installing agent..."
$InstallArgs = "/i `"$MsiPath`" /quiet SERVER=`"$GlpiServer`" TAG=$Tag RUNNOW=1 ADD_FIREWALL_EXCEPTION=1"
$Process = Start-Process msiexec.exe -ArgumentList $InstallArgs -WorkingDirectory $env:TEMP -Wait -PassThru

# 5. Check the result and clean up
if ($Process.ExitCode -eq 0) {
    Write-Host "Installation successful!" -ForegroundColor Green
} else {
    Write-Warning "Installation finished with exit code: $($Process.ExitCode). Something might be wrong."
}

Write-Host "Cleaning up temporary files..."
Remove-Item -Path $MsiPath -Force -ErrorAction SilentlyContinue

Write-Host "Done! The agent should sync with GLPI shortly." -ForegroundColor Cyan
