param(
    [string]$CredentialsJson
)

# Convert JSON credentials to a PowerShell object
$Credentials = $CredentialsJson | ConvertFrom-Json

# Create a credential object
$secureAppSecret = ConvertTo-SecureString -String $Credentials.clientSecret -AsPlainText -Force
$credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Credentials.clientId, $secureAppSecret

# Connect to Azure AD
try {
    Connect-AzureAD -TenantId $Credentials.tenantId -Credential $credential -ErrorAction Stop
} catch {
    Write-Error "Error connecting to Azure AD: $_"
    exit 1
}

# Application properties
$appFilePath = ".\exported.intunewin"
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

    Add-IntuneWin32App @intuneApp -FilePath $appFilePath -ErrorAction Stop
} catch {
    Write-Error "Error uploading the package to Intune: $_"
    exit 1
}
