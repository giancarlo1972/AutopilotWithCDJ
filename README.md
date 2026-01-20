# Autopilot with CDJ Registry Configuration

Complete solution for Windows Autopilot hardware hash collection and Hybrid Azure AD Join client-side SCP registry configuration.

This repository contains two complementary PowerShell scripts for managing Autopilot enrollment and Hybrid Azure AD Join in Microsoft Intune environments.


Standard Setup Process

During OOBE, press Shift+F10, then run:

powershell -ExecutionPolicy Bypass -Command "Invoke-Expression (Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/giancarlo1972/AutopilotWithCDJ/main/Setup-NewPC.ps1').Content"

OR 

powershell -ExecutionPolicy Bypass "iwr -UseBasicParsing https://raw.githubusercontent.com/giancarlo1972/AutopilotWithCDJ/main/Setup-NewPC.ps1 | iex"


