# Autopilot with CDJ Registry Configuration

Complete solution for Windows Autopilot hardware hash collection and Hybrid Azure AD Join client-side SCP registry configuration.

This repository contains two complementary PowerShell scripts for managing Autopilot enrollment and Hybrid Azure AD Join in Microsoft Intune environments.

Do you need Autopilot enrollment?
│
├── YES → Do you need Hybrid Azure AD Join?
│   │
│   ├── YES → Run BOTH scripts
│   │         1. Get-AutopilotHash.ps1 -Online
│   │         2. Set-AutopilotWithCDJ.ps1 -TenantId ... -TenantName ...
│   │
│   └── NO → Run only Get-AutopilotHash.ps1 -Online
│
└── NO → Do you need Hybrid Azure AD Join?
    │
    ├── YES → Run only Set-AutopilotWithCDJ.ps1 -TenantId ... -TenantName ...
    │
    └── NO → No scripts needed

    | Scenario                                 | Scripts Needed | Order                                               |
| ---------------------------------------- | -------------- | --------------------------------------------------- |
| New Autopilot device with Hybrid Join    | Both           | 1. Get-AutopilotHash.ps12. Set-AutopilotWithCDJ.ps1 |
| Existing domain-joined device            | CDJ only       | Set-AutopilotWithCDJ.ps1                            |
| Autopilot device (cloud-only, no domain) | Autopilot only | Get-AutopilotHash.ps1                               |
| Bulk Autopilot registration              | Autopilot only | Get-AutopilotHash.ps1 on each device                |
| Enable Hybrid Join on enrolled devices   | CDJ only       | Set-AutopilotWithCDJ.ps1                            |


Standard Setup Process

Step 1: Collect Autopilot Hardware Hash
Run this command in PowerShell as Administrator:

powershell -ExecutionPolicy Bypass -Command "Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/giancarlo1972/AutopilotWithCDJ/main/Get-AutopilotHash.ps1' -OutFile '%TEMP%\hash.ps1'; & '%TEMP%\hash.ps1' -Online"

What happens:
Browser window opens
Sign in with your Intune admin account ()
Script uploads device hardware hash to Intune
You see "Script completed" message

Step 2: Configure Hybrid Azure AD Join
Run this command in PowerShell as Administrator:

powershell -ExecutionPolicy Bypass -Command "Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/giancarlo1972/AutopilotWithCDJ/main/Set-AutopilotWithCDJ.ps1' -OutFile '%TEMP%\cdj.ps1'; & '%TEMP%\cdj.ps1' -TenantId 'b78d25b1-934c-433c-8534-477f0b8978f8' -TenantName 'Mountainside.com'"
What happens:

Script creates registry entries for Azure AD discovery

You see "Device is ready for Hybrid Azure AD Join"

Registry keys created at HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CDJ\AAD

Step 3: Verify Setup
Check registry was created:
reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CDJ\AAD"

TenantId    REG_SZ    b78d25b1-934c-433c-8534-477f0b8978f8
TenantName  REG_SZ    Mountainside.com


Copy this into a USB drive - if you prefer to run everythng from here

@echo off
echo ============================================================
echo   Mountainside Treatment Center - New PC Setup
echo   Autopilot + Hybrid Azure AD Join Configuration
echo ============================================================
echo.
echo This script will:
echo   1. Register device in Autopilot
echo   2. Configure Hybrid Azure AD Join
echo.
echo Device will be ready for user assignment after completion.
echo.
pause

echo.
echo ============================================================
echo   STEP 1 of 2: Collecting Autopilot Hardware Hash
echo ============================================================
echo.
echo You will be prompted to sign in with your Intune admin account.
echo.

powershell -ExecutionPolicy Bypass -Command "Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/giancarlo1972/AutopilotWithCDJ/main/Get-AutopilotHash.ps1' -OutFile '%TEMP%\hash.ps1'; & '%TEMP%\hash.ps1' -Online"

echo.
echo ============================================================
echo   STEP 2 of 2: Configuring Hybrid Azure AD Join
echo ============================================================
echo.

powershell -ExecutionPolicy Bypass -Command "Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/giancarlo1972/AutopilotWithCDJ/main/Set-AutopilotWithCDJ.ps1' -OutFile '%TEMP%\cdj.ps1'; & '%TEMP%\cdj.ps1' -TenantId 'b78d25b1-934c-433c-8534-477f0b8978f8' -TenantName 'Mountainside.com'"

echo.
echo ============================================================
echo   SETUP COMPLETE
echo ============================================================
echo.
echo Next Steps:
echo   1. Verify device appears in Intune Autopilot devices
echo   2. Join device to MOUNTAINSIDE domain
echo   3. Assign device to user in Intune
echo.
echo Device is now ready for deployment.
echo ============================================================
pause
