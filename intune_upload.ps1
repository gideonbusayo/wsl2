param(
    [string]$CredentialsJson
)

# Convert JSON credentials to a PowerShell object
$Credentials = $CredentialsJson | ConvertFrom-Json

# Create a credential object
$secureAppSecret = ConvertTo-SecureString -String $Credentials.clientSecret -AsPlainText -Force
$credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Credentials.clientId, $secureAppSecret

# Install and Import Microsoft Graph PowerShell SDK
try {
    Install-Module -Name Microsoft.Graph -Scope CurrentUser -Force -AllowClobber
    Import-Module Microsoft.Graph
} catch {
    Write-Error "Error installing Microsoft Graph module: $_"
    exit 1
}

# Connect to Microsoft Graph
try {
    Connect-MgGraph -ClientId $Credentials.clientId -TenantId $Credentials.tenantId -ClientSecret $secureAppSecret
} catch {
    Write-Error "Error connecting to Microsoft Graph: $_"
    exit 1
}

# Application properties
$appFilePath = ".\exported.intunewin" # Ensure this path is correct
$appName = "Ubuntu-Custom"
$appDescription = "Custom Ubuntu WSL Image"
$appPublisher = "DEVOPS-LSEG"
$installCommand = "wsl --import Ubuntu C:\WSL\Ubuntu .\exported.tar"   
$uninstallCommand = "wsl --unregister Ubuntu"

# Detection Rule
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
        InstallExperience = "system"
        RestartBehavior = "basedOnReturnCode"
    }

    # Replace with appropriate cmdlet or method to upload the app to Intune using Microsoft Graph
    # This part needs to be updated based on the available Microsoft Graph cmdlets or REST API calls
    # Example: New-MgIntuneApp -App $intuneApp

} catch {
    Write-Error "Error uploading the package to Intune: $_"
    exit 1
}
