Install-Module -Name Microsoft.Graph -Scope CurrentUser -Force -AllowClobber
Install-Module -Name IntuneWin32App -Scope CurrentUser -Force -AllowClobber
Import-Module IntuneWin32App

param(
  [string]$TenantId,
  [string]$AppId,
  [string]$AppSecret,
  [string]$credential
)

# Install required modules
try {
    Install-Module -Name AzureAD -Force -AllowClobber -ErrorAction Stop
    Install-Module -Name Microsoft.Graph.Intune -Force -AllowClobber -ErrorAction Stop
    Install-Module -Name IntuneWin32App -Force -AllowClobber -ErrorAction Stop
} catch {
    Write-Error "Error installing required modules: $_"
    exit 1
}

# Connect to Azure AD
try {
    $secureAppSecret = ConvertTo-SecureString $AppSecret -AsPlainText -Force
    $credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $AppId, $secureAppSecret
    Connect-AzureAD -TenantId $TenantId -Credential $credential -ErrorAction Stop
} catch {
    Write-Error "Error connecting to Azure AD: $_"
    exit 1
}

# Application properties
$appFilePath = ".\exported.intunewin" # Adjust the path as necessary
$appName = "Ubuntu-Custom"
$appDescription = "Custom Ubuntu WSL Image"
$appPublisher = "DEVOPS-LSEG"
$installCommand = "wsl --import Ubuntu C:\WSL\Ubuntu .\exported.tar"   
$uninstallCommand = "wsl --unregister Ubuntu"

$detectionRule = @{
    detectionType = "file"
    path = "C:\\Program Files\\WSL" 
    fileName = "wsl.exe" 
    check32BitOn64System = $false
}
# Correctly format the DetectionRule
$detectionRule = New-Object 'System.Collections.Specialized.OrderedDictionary'
$detectionRule['detectionType'] = 'file'
$detectionRule['path'] = "C:\\Program Files\\WSL"
$detectionRule['fileName'] = "wsl.exe"
$detectionRule['check32BitOn64System'] = $false
$detectionRules = @($detectionRule)


# Upload the package to Intune
try {
    $intuneApp = @{
        displayName = $appName
        description = $appDescription
        publisher = $appPublisher
        installCommandLine = $installCommand
        uninstallCommandLine = $uninstallCommand
        DetectionRule = $detectionRules
        InstallExperience = "system" # Adjust as needed
        RestartBehavior = "basedOnReturnCode" # Adjust as needed
    }

    Add-IntuneWin32App @intuneApp -FilePath $appFilePath -ErrorAction Stop
} catch {
    Write-Error "Error uploading the package to Intune: $_"
    exit 1
}
