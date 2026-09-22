<#
.SYNOPSIS
    GLPI Agent MSI Installer Worker
#>
param(
    [string]$Tag = "Desktop"
)

# Configuration
$MsiUrl = "https://raw.githubusercontent.com/Sudo-Chamroeun/fis-glpi-agent/main/GLPI-Agent-1.19-x64.msi"
$MsiPath = "$env:TEMP\GLPI-Agent-1.19-x64.msi"
$GlpiServer = "http://172.26.0.2:9090/front/inventory.php"
$LogPath = "$env:TEMP\GLPI-Agent-Install.log"

Write-Host "Downloading GLPI Agent MSI..." -ForegroundColor Cyan
Invoke-WebRequest -Uri $MsiUrl -OutFile $MsiPath -UseBasicParsing

Write-Host "Installing GLPI Agent (Tag: $Tag)..." -ForegroundColor Cyan

# THE CRITICAL FIX: Use cmd.exe to run msiexec
# This prevents PowerShell from messing with the working directory context.
$MsiArgs = "/i `"$MsiPath`" /quiet SERVER=`"$GlpiServer`" TAG=$Tag RUNNOW=1 ADD_FIREWALL_EXCEPTION=1 /l*v `"$LogPath`""
$CmdCommand = "msiexec $MsiArgs"

# Execute via cmd.exe
$Process = Start-Process cmd.exe -ArgumentList "/c $CmdCommand" -Wait -PassThru -NoNewWindow

if ($Process.ExitCode -eq 0) {
    Write-Host "Installation successful!" -ForegroundColor Green
} else {
    Write-Host "Installation failed with exit code: $($Process.ExitCode)" -ForegroundColor Red
    Write-Host "Check the log file at: $LogPath" -ForegroundColor Yellow
}

# Cleanup
if (Test-Path $MsiPath) {
    Remove-Item -Path $MsiPath -Force -ErrorAction SilentlyContinue
}
