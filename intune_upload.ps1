Install-Module -Name IntuneWin32App -Scope CurrentUser -Force -AllowClobber
Import-Module IntuneWin32App

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
