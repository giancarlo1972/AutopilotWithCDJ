<#
.SYNOPSIS
    Complete new PC setup for Mountainside Treatment Center
    Run during OOBE on brand new machines

.DESCRIPTION
    This script:
    1. Enables TLS 1.2 for PowerShell Gallery
    2. Sets execution policy
    3. Installs Get-WindowsAutopilotInfo
    4. Uploads hardware hash to Intune Autopilot
    5. Configures CDJ registry for Hybrid Azure AD Join

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File Setup-NewPC.ps1
#>

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  Mountainside Treatment Center - New PC Setup" -ForegroundColor Cyan
Write-Host "  Complete Autopilot + Hybrid Azure AD Join Configuration" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# STEP 1: Enable TLS 1.2
Write-Host "STEP 1: Enabling TLS 1.2 for PowerShell Gallery..." -ForegroundColor Yellow
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Write-Host "TLS 1.2 enabled" -ForegroundColor Green
Write-Host ""

# STEP 2: Set Execution Policy
Write-Host "STEP 2: Setting Execution Policy..." -ForegroundColor Yellow
Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned -Force
Write-Host "Execution Policy set" -ForegroundColor Green
Write-Host ""

# STEP 3: Install Autopilot Script
Write-Host "STEP 3: Installing Get-WindowsAutopilotInfo script..." -ForegroundColor Yellow
Install-Script -Name Get-WindowsAutopilotInfo -Force
Write-Host "Get-WindowsAutopilotInfo installed" -ForegroundColor Green
Write-Host ""

# STEP 4: Upload Hardware Hash
Write-Host "STEP 4: Uploading hardware hash to Intune Autopilot..." -ForegroundColor Yellow
Write-Host ""
Write-Host "You will be prompted to sign in with your Intune admin account." -ForegroundColor Cyan
Write-Host ""
Get-WindowsAutopilotInfo.ps1 -Online
Write-Host ""
Write-Host "Hardware hash uploaded" -ForegroundColor Green
Write-Host ""

# STEP 5: Configure CDJ Registry
Write-Host "STEP 5: Configuring Hybrid Azure AD Join registry..." -ForegroundColor Yellow

$TenantId = "b78d25b1-934c-433c-8534-477f0b8978f8"
$TenantName = "Mountainside.com"
$RegPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CDJ\AAD"

try {
    if (!(Test-Path $RegPath)) {
        New-Item -Path $RegPath -Force | Out-Null
    }
    
    New-ItemProperty -Path $RegPath -Name "TenantId" -Value $TenantId -PropertyType String -Force | Out-Null
    New-ItemProperty -Path $RegPath -Name "TenantName" -Value $TenantName -PropertyType String -Force | Out-Null
    
    Write-Host "CDJ registry configured" -ForegroundColor Green
    Write-Host "TenantId: $TenantId" -ForegroundColor Cyan
    Write-Host "TenantName: $TenantName" -ForegroundColor Cyan
} catch {
    Write-Host "Error configuring CDJ registry: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  SETUP COMPLETE!" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Device is ready for:" -ForegroundColor Yellow
Write-Host "  - Autopilot enrollment" -ForegroundColor Cyan
Write-Host "  - Hybrid Azure AD Join" -ForegroundColor Cyan
Write-Host "  - Domain join to MOUNTAINSIDE" -ForegroundColor Cyan
Write-Host ""
