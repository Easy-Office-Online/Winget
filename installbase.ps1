# This script checks if recent version of Winget is installed and installs software throug Winget
# Works in conjunction with install.ps1 which is placed in intunewin

$AppInstaller = Get-AppxPackage | Where-Object name -eq Microsoft.DesktopAppInstaller

#Start Logging
Start-Transcript -Path "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\$($PackageName)_Install.log" -Append

If($AppInstaller.Version -lt "1.20.2201.0") {

    Write-Host "Winget is not installed, trying to install latest version from Github" -ForegroundColor Yellow

    Try {
            
        Write-Host "Creating Winget Packages Folder" -ForegroundColor Yellow

        if (!(Test-Path -Path C:\ProgramData\EOO\WinGetPackages)) {
            New-Item -Path C:\ProgramData\EOO\WinGetPackages -Force -ItemType Directory
        }

        Set-Location C:\ProgramData\EOO\WinGetPackages

$progressPreference = 'silentlyContinue'
Write-Information "Downloading WinGet and its dependencies..."
Invoke-WebRequest -Uri https://aka.ms/getwinget -OutFile Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle
Invoke-WebRequest -Uri https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx -OutFile Microsoft.VCLibs.x64.14.00.Desktop.appx
Invoke-WebRequest -Uri https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.7.3/Microsoft.UI.Xaml.2.7.x64.appx -OutFile Microsoft.UI.Xaml.2.7.x64.appx
Add-AppxPackage Microsoft.VCLibs.x64.14.00.Desktop.appx
Add-AppxPackage Microsoft.UI.Xaml.2.7.x64.appx
Add-AppxPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle

        Write-Host "Starting sleep for Winget to initiate" -Foregroundcolor Yellow
        Start-Sleep 2
    }
    Catch {
        Throw "Failed to install Winget"
        Break
    }

    }
Else {
    Write-Host "Winget already installed, moving on" -ForegroundColor Green
}
#Trying to install Package with Winget
IF ($PackageName){
    try {
        Write-Host "Installing $($PackageName) via Winget" -ForegroundColor Green

        $ResolveWingetPath = Resolve-Path "C:\Program Files\WindowsApps\Microsoft.DesktopAppInstaller_*_x64__8wekyb3d8bbwe"
        if ($ResolveWingetPath){
               $WingetPath = $ResolveWingetPath[-1].Path
        }
    
        $config
        cd $wingetpath

        .\winget.exe install $PackageName --silent --accept-source-agreements --accept-package-agreements
    }
    Catch {
        Throw "Failed to install package $($_)"
    }
}
Else {
    Write-Host "Package $($PackageName) not available" -ForegroundColor Yellow
}
Stop-Transcript
