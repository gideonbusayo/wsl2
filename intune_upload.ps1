param(
  [string]$TenantId,
  [string]$AppId,
  [string]$AppSecret
)

# Application properties - Adjust file path for GitHub Actions
$appFilePath = "exported.intunewin" # Adjust the path as necessary
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

# Upload the package to Intune
try {
    $intuneApp = @{
        displayName = $appName
        description = $appDescription
        publisher = $appPublisher
        installCommandLine = $installCommand
        uninstallCommandLine = $uninstallCommand
        DetectionRule   = $detectionRule
    }

    Add-IntuneWin32App @intuneApp -FilePath $appFilePath -ErrorAction Stop
} catch {
    Write-Error "Error uploading the package to Intune: $_"
    exit 1
}
