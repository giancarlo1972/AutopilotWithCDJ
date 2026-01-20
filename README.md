# AutopilotWithCDJ
Autopilot Files
# Download from your GitHub repo
$url = "https://raw.githubusercontent.com/giancarlo1972/AutopilotWithCDJ/main/Set-AutopilotWithCDJ.ps1"
Invoke-WebRequest -Uri $url -OutFile "$env:TEMP\Set-AutopilotWithCDJ.ps1"

# Run it
& "$env:TEMP\Set-AutopilotWithCDJ.ps1" -Online -TenantId "b78d25b1-934c-433c-8534-477f0b8978f8" -TenantName "Mountainside.com"
