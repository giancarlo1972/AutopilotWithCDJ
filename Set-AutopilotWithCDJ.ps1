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

Write-LogMessage "Checking for WindowsAutopilotIntune module..." -Level Info
if (!(Get-Module -ListAvailable -Name WindowsAutopilotIntune)) {
    Write-LogMessage "Installing WindowsAutopilotIntune module..." -Level Warning
    try {
        Install-Module -Name WindowsAutopilotIntune -Force -Scope CurrentUser -ErrorAction Stop
        Write-LogMessage "Module installed successfully" -Level Success
    } catch {
        Write-LogMessage "Failed to install module: $($_.Exception.Message)" -Level Error
        exit 1
    }
} else {
    Write-LogMessage "WindowsAutopilotIntune module already installed" -Level Success
}

Write-Host ""
Write-Host "Hardware Hash Collection" -ForegroundColor Yellow

if ($Online) {
    Write-LogMessage "Uploading hardware hash to Intune..." -Level Info
    try {
        $params = @{
            Online = $true
        }
        if ($GroupTag) { 
            $params.GroupTag = $GroupTag 
        }
        if ($Assign) { 
            $params.Assign = $true 
        }
        
        Get-WindowsAutopilotInfo @params
        Write-LogMessage "Hardware hash uploaded successfully" -Level Success
    } catch {
        Write-LogMessage "Failed to upload hardware hash: $($_.Exception.Message)" -Level Error
    }
} else {
    Write-LogMessage "Collecting hardware hash in offline mode..." -Level Info
    $outputFile = "AutopilotHWID_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv"
    Get-WindowsAutopilotInfo -OutputFile $outputFile
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
