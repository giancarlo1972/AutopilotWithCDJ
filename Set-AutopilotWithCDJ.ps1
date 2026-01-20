param(
    [Parameter(Mandatory=$false)]
    [switch]$Online,

    [Parameter(Mandatory=$false)]
    [string]$GroupTag,

    [Parameter(Mandatory=$false)]
    [switch]$Assign,

    [Parameter(Mandatory=$false)]
    [string]$TenantId,

    [Parameter(Mandatory=$false)]
    [string]$TenantName,

    [Parameter(Mandatory=$false)]
    [switch]$SkipCDJ
)

function Write-LogMessage {
    param(
        [string]$Message,
        [ValidateSet("Info", "Success", "Warning", "Error")]
        [string]$Level = "Info"
    )
    
    $colors = @{
        Info = "Cyan"
        Success = "Green"
        Warning = "Yellow"
        Error = "Red"
    }
    
    Write-Host $Message -ForegroundColor $colors[$Level]
}

function Set-CDJRegistry {
    param(
        [Parameter(Mandatory=$true)]
        [string]$TenantIdValue,
        
        [Parameter(Mandatory=$true)]
        [string]$TenantNameValue
    )
    
    $RegPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CDJ\AAD"
    
    try {
        Write-LogMessage "Configuring CDJ Client-Side SCP registry..." -Level Info
        
        if (!(Test-Path $RegPath)) {
            Write-LogMessage "Creating registry path: $RegPath" -Level Info
            New-Item -Path $RegPath -Force | Out-Null
        }
        
        New-ItemProperty -Path $RegPath -Name "TenantId" -Value $TenantIdValue -PropertyType String -Force | Out-Null
        Write-LogMessage "TenantId configured: $TenantIdValue" -Level Success
        
        New-ItemProperty -Path $RegPath -Name "TenantName" -Value $TenantNameValue -PropertyType String -Force | Out-Null
        Write-LogMessage "TenantName configured: $TenantNameValue" -Level Success
        
        $verification = Get-ItemProperty -Path $RegPath -ErrorAction SilentlyContinue
        if ($verification.TenantId -eq $TenantIdValue -and $verification.TenantName -eq $TenantNameValue) {
            Write-LogMessage "CDJ registry verification passed" -Level Success
            return $true
        } else {
            Write-LogMessage "CDJ registry verification failed" -Level Error
            return $false
        }
        
    } catch {
        Write-LogMessage "Failed to configure CDJ registry: $($_.Exception.Message)" -Level Error
        return $false
    }
}

Write-Host ""
Write-Host "Autopilot + Hybrid Azure AD Join Setup" -ForegroundColor Cyan
Write-Host ""

# Try to install dependencies and module
Write-LogMessage "Checking for Get-WindowsAutopilotInfo..." -Level Info

$scriptInstalled = Get-InstalledScript -Name Get-WindowsAutopilotInfo -ErrorAction SilentlyContinue
$moduleInstalled = Get-Module -ListAvailable -Name WindowsAutopilotIntune -ErrorAction SilentlyContinue

if (!$scriptInstalled -and !$moduleInstalled) {
    Write-LogMessage "Installing Get-WindowsAutopilotInfo script..." -Level Warning
    try {
        # Try installing as script first (easier, fewer dependencies)
        Install-Script -Name Get-WindowsAutopilotInfo -Force -Scope CurrentUser -ErrorAction Stop
        Write-LogMessage "Script installed successfully" -Level Success
    } catch {
        Write-LogMessage "Script installation failed. Trying module approach..." -Level Warning
        try {
            # Try module installation with dependencies
            Write-LogMessage "Installing dependencies..." -Level Info
            Install-Module -Name Microsoft.Graph.Intune -Force -Scope CurrentUser -AllowClobber -SkipPublisherCheck -ErrorAction SilentlyContinue
            Install-Module -Name WindowsAutopilotIntune -Force -Scope CurrentUser -AllowClobber -SkipPublisherCheck -ErrorAction Stop
            Write-LogMessage "Module installed successfully" -Level Success
        } catch {
            Write-LogMessage "Failed to install: $($_.Exception.Message)" -Level Error
            Write-LogMessage "Manual installation required. See instructions below." -Level Warning
            Write-Host ""
            Write-Host "Manual Installation Steps:" -ForegroundColor Yellow
            Write-Host "1. Run PowerShell as Administrator" -ForegroundColor Cyan
            Write-Host "2. Run: Install-Script -Name Get-WindowsAutopilotInfo -Force" -ForegroundColor Cyan
            Write-Host "3. Re-run this script" -ForegroundColor Cyan
            exit 1
        }
    }
} else {
    Write-LogMessage "Get-WindowsAutopilotInfo already installed" -Level Success
}

Write-Host ""
Write-Host "Hardware Hash Collection" -ForegroundColor Yellow

if ($Online) {
    Write-LogMessage "Uploading hardware hash to Intune..." -Level Info
    try {
        if ($scriptInstalled -or (Get-InstalledScript -Name Get-WindowsAutopilotInfo -ErrorAction SilentlyContinue)) {
            # Use script version
            $params = @('-Online')
            if ($GroupTag) { $params += "-GroupTag"; $params += $GroupTag }
            if ($Assign) { $params += "-Assign" }
            
            & Get-WindowsAutopilotInfo @params
        } else {
            # Use module version
            $params = @{ Online = $true }
            if ($GroupTag) { $params.GroupTag = $GroupTag }
            if ($Assign) { $params.Assign = $true }
            
            Get-WindowsAutopilotInfo @params
        }
        Write-LogMessage "Hardware hash uploaded successfully" -Level Success
    } catch {
        Write-LogMessage "Failed to upload hardware hash: $($_.Exception.Message)" -Level Error
    }
} else {
    Write-LogMessage "Collecting hardware hash in offline mode..." -Level Info
    $outputFile = "AutopilotHWID_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv"
    
    if ($scriptInstalled -or (Get-InstalledScript -Name Get-WindowsAutopilotInfo -ErrorAction SilentlyContinue)) {
        Get-WindowsAutopilotInfo -OutputFile $outputFile
    } else {
        Get-WindowsAutopilotInfo -OutputFile $outputFile
    }
    Write-LogMessage "Hardware hash saved to: $outputFile" -Level Success
}

if (!$SkipCDJ -and $TenantId -and $TenantName) {
    Write-Host ""
    Write-Host "CDJ Client-Side SCP Configuration" -ForegroundColor Yellow
    
    $cdjResult = Set-CDJRegistry -TenantIdValue $TenantId -TenantNameValue $TenantName
    
    if ($cdjResult) {
        Write-Host ""
        Write-Host "Device is ready for Hybrid Azure AD Join" -ForegroundColor Green
        Write-Host "Tenant: $TenantName" -ForegroundColor Cyan
        Write-Host "TenantID: $TenantId" -ForegroundColor Cyan
        Write-Host ""
    } else {
        Write-LogMessage "CDJ configuration failed - device may not join Hybrid Azure AD" -Level Warning
    }
} elseif ($SkipCDJ) {
    Write-LogMessage "CDJ registry creation skipped per SkipCDJ parameter" -Level Info
} else {
    Write-LogMessage "CDJ registry not configured - TenantId and TenantName parameters required" -Level Warning
    Write-Host "To configure CDJ, run with: -TenantId GUID -TenantName domain" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Script completed successfully" -ForegroundColor Green
Write-Host ""
