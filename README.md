# Autopilot with CDJ Registry Configuration

Complete solution for Windows Autopilot hardware hash collection and Hybrid Azure AD Join client-side SCP registry configuration.

This repository contains two complementary PowerShell scripts for managing Autopilot enrollment and Hybrid Azure AD Join in Microsoft Intune environments.

## Overview

### What These Scripts Do

**Set-AutopilotWithCDJ.ps1**
- Configures CDJ (Cloud Domain Join) client-side SCP registry entries
- Enables devices to discover and join Hybrid Azure AD without domain-wide SCP
- Provides controlled rollout via Group Policy or Intune deployment
- Supports optional Autopilot hardware hash collection

**Get-AutopilotHash.ps1**
- Dedicated script for collecting Windows Autopilot hardware hash
- Supports both online upload to Intune and offline CSV export
- Can be deployed independently or as part of provisioning workflow
- Includes fallback to offline mode if online upload fails

## Features

- Clean PowerShell code with no symbols or special characters
- Supports both online and offline operation modes
- Configurable tenant parameters
- Error handling and fallback mechanisms
- Works with Windows 10 and Windows 11
- Can be deployed via Intune, Group Policy, or USB provisioning

## Prerequisites

- Windows 10 or Windows 11
- Administrator or SYSTEM account privileges
- Internet connection for online modes
- Azure AD tenant with Intune
- Active Directory domain (for Hybrid Join scenarios)

## Quick Start

### Setup Hybrid Azure AD Join (CDJ Registry)

```powershell
$url = "https://raw.githubusercontent.com/giancarlo1972/AutopilotWithCDJ/main/Set-AutopilotWithCDJ.ps1"
Invoke-WebRequest -Uri $url -OutFile "Set-AutopilotWithCDJ.ps1"
.\Set-AutopilotWithCDJ.ps1 -TenantId "b78d25b1-934c-433c-8534-477f0b8978f8" -TenantName "Mountainside.com"
