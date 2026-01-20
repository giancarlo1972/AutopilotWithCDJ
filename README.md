# Autopilot with CDJ Registry Configuration

Windows Autopilot hardware hash upload combined with Hybrid Azure AD Join client-side SCP registry configuration.

## Features

- Collects device hardware hash for Autopilot enrollment
- Creates CDJ client-side SCP registry entries for Hybrid Azure AD Join
- Supports both online and offline modes
- Configurable tenant parameters
- No symbols or special characters in code

## Prerequisites

- Windows 10 or Windows 11
- Administrator or SYSTEM account privileges
- Internet connection for online mode
- WindowsAutopilotIntune PowerShell module

## Usage

### Basic Online Upload

```powershell
$url = "https://raw.githubusercontent.com/giancarlo1972/AutopilotWithCDJ/main/Set-AutopilotWithCDJ.ps1"
Invoke-WebRequest -Uri $url -OutFile "Set-AutopilotWithCDJ.ps1"

.\Set-AutopilotWithCDJ.ps1 -Online -TenantId "b78d25b1-934c-433c-8534-477f0b8978f8" -TenantName "Mountainside.com"

