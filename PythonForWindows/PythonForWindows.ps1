#Requires -Version 5
[CmdletBinding()]
Param(
    [String]$InstallationType = 'Computer',
    [ValidateSet('3.7','3.8','3.9','3.10','3.11','3.12','3.13')]
    [String]$PythonVersion = '3.13',
    [String]$OverwriteInstallOptionsTo = '',
    [Switch]$InstallPwsh7SDK,
    [Switch]$InstallDotnetInteractive,
    [Switch]$CleanupDownloadFiles,
    [String]$WorkingFolder = $PSScriptRoot
)
$ErrorActionPreference = 'Stop'
Push-Location $WorkingFolder
chcp 65001
$OutputEncoding = [System.Text.Encoding]::GetEncoding('utf-8')

$psBoundParameters.Keys | ForEach-Object {
    if ($($PSBoundParameters.$_.GetType().Name) -eq 'SwitchParameter') {
        $paramStrings += " -$_"
    }
    else {
        $paramStrings += " -$_ $($PSBoundParameters.$_)"
    }
}
Write-Host "Commandline: `"$PSCommandPath`"$paramStrings"
switch ($InstallationType) {
    {@('system', 'computer', 'allusers') -contains $_} {
        if (-not([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
            Write-Host 'Relaunch script with admin privileges...'
            Start-Process powershell.exe "-NoExit -ExecutionPolicy Bypass -Command `"$PSCommandPath`" $paramStrings" -Verb RunAs
            exit
        }
        if ( '' -eq $OverwriteInstallOptionsTo ) {
            $installOpt = '/passive InstallAllUsers=1 PrependPath=1'
        }
        else {
            $installOpt = $OverwriteInstallOptionsTo
        }
    }
    {@('user', 'justme') -contains $_} {
        if ( '' -eq $OverwriteInstallOptionsTo ) {
            $installOpt = '/passive InstallAllUsers=0 PrependPath=1'
        }
        else {
            $installOpt = $OverwriteInstallOptionsTo
        }
    }
    default {
        Write-Error 'Unexpected option.'
    }
}

if ($ProgressPreference -ne 'SilentlyContinue') {
    Write-Verbose 'Change $ProgressPreference to SilentlyContinue.'
    $exProgressPreference = $ProgressPreference
    $ProgressPreference = 'SilentlyContinue'
}

Write-Host "Downloading latest Python $PythonVersion for Windows..."
$links = (Invoke-WebRequest -uri 'https://www.python.org/downloads/windows/' -UseBasicParsing).Links.href
$targetLinks = $links | Select-String -Pattern ".*python-($PythonVersion\.\d*)-amd64.exe"
$latestVer = $PythonVersion + '.' + ($targetLinks -replace ".*python-$PythonVersion\.(\d*)-amd64.exe", '$1'| Measure-Object -Maximum).Maximum
$fileUri = ($targetLinks | Select-String -Pattern ".*python-$latestVer-amd64.exe" | Get-Unique).Tostring().Trim()
Invoke-WebRequest -uri $fileUri -UseBasicParsing -OutFile (Join-Path $WorkingFolder 'pythoninstaller.exe') -Verbose

Write-Host 'Downloading Node.js...'
$releaseURI = 'https://nodejs.org/download/release/latest-v22.x'
$links = (Invoke-WebRequest -uri $releaseURI -UseBasicParsing).Links.href
$fileUri = 'https://nodejs.org' + ($links | Select-String -Pattern "x64.*\.msi" | Get-Unique).Tostring().Trim()
Invoke-WebRequest -Uri $fileUri -OutFile (Join-Path $WorkingFolder '\nodeinstaller.msi')

if ($InstallGit) {
    Write-Host 'Downloading latest Git for Windows...'
    $releaseURI = 'https://github.com/git-for-windows/git/releases'
    $latestRelease = (Invoke-WebRequest -Uri "$releaseURI/latest" -UseBasicParsing -Headers @{'Accept'='application/json'}| ConvertFrom-Json).update_url
    $versionString = $latestRelease -replace '.*tag/(.*)', '$1'
    $links = (Invoke-WebRequest -Uri "$releaseURI/expanded_assets/$($versionString)" -UseBasicParsing).Links.href
    $fileUri = 'https://github.com' + ($links | Select-String -Pattern '.*64-bit.exe' | Get-Unique).Tostring().Trim()
    Write-Host "Download from $fileUri"
    Invoke-WebRequest -Uri $fileUri -UseBasicParsing -OutFile (Join-Path $WorkingFolder 'gitinstaller.exe') -Verbose
}

if ($InstallDotnetInteractive) {
    Write-Host 'Downloading latest .NET SDK...'
    $links = (Invoke-WebRequest -Uri 'https://dotnet.microsoft.com/download' -UseBasicParsing).Links.href
    $latestVer = (($links | Select-String -Pattern '.*sdk.*windows-x64-installer') -replace '.*sdk-(([0-9]+\.){1}[0-9]+(\.[0-9]+)?)-.*', '$1' | Measure-Object -Maximum).Maximum
    $latestUri = 'https://dotnet.microsoft.com' + ($links | Select-String -Pattern ".*sdk-$latestVer-windows-x64-installer" | Get-Unique).Tostring().Trim()
    $fileUri = ((Invoke-WebRequest -Uri $latestUri -UseBasicParsing).Links.href | Select-String -Pattern '.*\.exe' | Get-Unique).Tostring().Trim()
    Invoke-WebRequest -Uri $fileUri -UseBasicParsing -OutFile (Join-Path $WorkingFolder 'dotnet.exe') -Verbose
}
else {
    Write-Host 'Downloading latest .NET Runtime...'
    $links = (Invoke-WebRequest -Uri 'https://dotnet.microsoft.com/en-us/download/dotnet/9.0/runtime' -UseBasicParsing).Links.href
    $latestVer = (($links | Select-String -Pattern '.*runtime.*windows-x64-installer') -replace '.*runtime-(([0-9]+\.){1}[0-9]+(\.[0-9]+)?)-.*', '$1' | Measure-Object -Maximum).Maximum
    $latestUri = 'https://dotnet.microsoft.com' + ($links | Select-String -Pattern ".*runtime-$latestVer-windows-x64-installer" | Get-Unique).Tostring().Trim()
    $fileUri = ((Invoke-WebRequest -Uri $latestUri -UseBasicParsing).Links.href | Select-String -Pattern '.*\.exe' | Get-Unique).Tostring().Trim()
    Invoke-WebRequest -Uri $fileUri -UseBasicParsing -OutFile (Join-Path $WorkingFolder 'dotnet.exe') -Verbose
}

$releaseURI = 'https://github.com/sakaztk/Jupyter-PowerShellSDK/releases'
$latestRelease = (Invoke-WebRequest -Uri "$releaseURI/latest" -UseBasicParsing -Headers @{'Accept'='application/json'}| ConvertFrom-Json).update_url
$versionString = $latestRelease -replace '.*tag/(.*)', '$1'
$links = (Invoke-WebRequest -Uri "$releaseURI/expanded_assets/$($versionString)" -UseBasicParsing).Links.href
Write-Host 'Downloading latest DeepAQ pwsh5 Kernel...'
$fileUri = 'https://github.com' + ( $links | Select-String -Pattern '.*PowerShell5.zip' | Get-Unique).Tostring().Trim()
Invoke-WebRequest -uri $fileUri -UseBasicParsing -OutFile (Join-Path $WorkingFolder 'PowerShell5.zip') -Verbose
if ($InstallPwsh7SDK) {
    Write-Host 'Downloading latest DeepAQ pwshSDK Kernel...'
    $fileUri = 'https://github.com' + ( $links | Select-String -Pattern 'Jupyter-PowerShellSDK-7.*\.zip' | Get-Unique).Tostring().Trim()
    Invoke-WebRequest -uri $fileUri -UseBasicParsing -OutFile (Join-Path $WorkingFolder 'PowerShellSDK.zip') -Verbose
}

if ($null -ne $exProgressPreference) {
    Write-Verbose "Restore $ProgressPreference to $exProgressPreference"
    $ProgressPreference = $exProgressPreference
}

Write-Host 'Installing Python...'
Start-Process -FilePath (Join-Path $WorkingFolder 'pythoninstaller.exe') -ArgumentList $installOpt -Wait
if ($CleanupDownloadFiles) {
    Start-Sleep -Seconds 5
    Remove-Item (Join-Path $WorkingFolder 'pythoninstaller.exe') -Force
}
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
$pythonRoot = Split-Path (python -c "import sys; print(sys.executable)") -Parent
$kernelPath = Join-Path $pythonRoot '\share\jupyter\kernels'
$packagePath = Join-Path $pythonRoot '\Lib\site-packages'

Write-Host 'Installing Node.js...'
Start-Process -FilePath (Join-Path $WorkingFolder 'nodeinstaller.msi') -ArgumentList ('/passive') -wait
if ($CleanupDownloadFiles) {
    Start-Sleep -Seconds 5
    Remove-Item (Join-Path $WorkingFolder 'nodeinstaller.msi') -Force
}

Write-Host '##### Jupyter Installation #####'
python -m pip install --upgrade pip
python -m pip install --upgrade wheel
python -m pip install jupyter
python -m pip install notebook
python -m pip install jupyterlab

Write-Host 'Installing DeepAQ pwsh5 Kernel...'
$installPath = Join-Path $packagePath 'powershell5_kernel'
Expand-Archive -Path (Join-Path $WorkingFolder 'PowerShell5.zip') -DestinationPath $installPath -Force
New-Item -ItemType Directory -Path (Join-Path $kernelPath '\powershell5\') -Force
Invoke-WebRequest -UseBasicParsing -Verbose -Uri 'https://raw.githubusercontent.com/PowerShell/PowerShell/master/assets/Powershell_64.png' -OutFile (Join-Path $kernelPath '\powershell5\logo-64x64.png')
Add-Type -AssemblyName System.Drawing
$image = [System.Drawing.Image]::FromFile((Join-Path $kernelPath '\powershell5\logo-64x64.png'))
$bitmap32 = New-Object System.Drawing.Bitmap(32, 32)
[System.Drawing.Graphics]::FromImage($bitmap32).DrawImage($image, 0, 0, 32, 32)
$bitmap32.Save((Join-Path $kernelPath '\powershell5\logo-32x32.png'), [System.Drawing.Imaging.ImageFormat]::Png)
@"
{
    "argv": [
        "$($installPath.replace('\','/'))/Jupyter_PowerShell5.exe",
        "{connection_file}"
    ],
    "display_name": "PowerShell 5",
    "language": "Powershell"
}
"@ | Set-Content -Path (Join-Path $kernelPath '\powershell5\kernel.json')
Move-Item -Path (Join-Path $installPath '*.png') -Destination (Join-Path $kernelPath '\powershell5\') -Force
if ( $CleanupDownloadFiles ) {
    Remove-Item (Join-Path $WorkingFolder 'PowerShell5.zip') -Force
}

if ($InstallPwsh7SDK) {
    Write-Host 'Installing DeepAQ pwshSDK Kernel...'
    $installPath = Join-Path $packagePath 'powershellSDK_kernel'
    Expand-Archive -Path (Join-Path $WorkingFolder 'PowerShellSDK.zip') -DestinationPath $installPath -Force
    New-Item -ItemType Directory -Path (Join-Path $kernelPath '\powershellSDK\') -Force
    Invoke-WebRequest -UseBasicParsing -Verbose -Uri 'https://raw.githubusercontent.com/PowerShell/PowerShell/master/assets/Powershell_black_64.png' -OutFile (Join-Path $kernelPath '\powershellSDK\logo-64x64.png')
    Add-Type -AssemblyName System.Drawing
    $image = [System.Drawing.Image]::FromFile((Join-Path $kernelPath '\powershellSDK\logo-64x64.png'))
    $bitmap32 = New-Object System.Drawing.Bitmap(32, 32)
    [System.Drawing.Graphics]::FromImage($bitmap32).DrawImage($image, 0, 0, 32, 32)
    $bitmap32.Save((Join-Path $kernelPath '\powershellSDK\logo-32x32.png'), [System.Drawing.Imaging.ImageFormat]::Png)
@"
{
    "argv": [
        "$($installPath.replace('\','/'))/Jupyter_PowerShellSDK.exe",
        "{connection_file}"
    ],
    "display_name": "PowerShell 7 (SDK)",
    "language": "Powershell"
}
"@ | Set-Content -Path (Join-Path $kernelPath '\powershellSDK\kernel.json')
    Move-Item -Path (Join-Path $installPath '*.png') -Destination (Join-Path $kernelPath '\powershellSDK\') -Force
    if ($CleanupDownloadFiles) {
        Remove-Item (Join-Path $WorkingFolder 'PowerShellSDK.zip') -Force
    }
}

if ($InstallDotnetInteractive) {
    Write-Host 'Installing .NET Core SDK...'
    Start-Process -FilePath (Join-Path $WorkingFolder 'dotnet.exe') -ArgumentList '/install /passive /norestart' -Wait
    Write-Host 'Installing .NET Interactive...'
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    dotnet tool install -g --add-source "https://pkgs.dev.azure.com/dnceng/public/_packaging/dotnet-tools/nuget/v3/index.json" Microsoft.dotnet-interactive
    dotnet interactive jupyter install --path "$kernelPath"
    if ($CleanupDownloadFiles) {
        Start-Sleep -Seconds 5
        Remove-Item (Join-Path $WorkingFolder 'dotnet.exe') -Force
    }
}
elseif ($InstallPwsh7SDK) {
    Write-Host 'Installing .NET Runtime...'
    Start-Process -FilePath (Join-Path $WorkingFolder 'dotnet.exe') -ArgumentList '/install /passive /norestart' -Wait
    if ($CleanupDownloadFiles) {
        Start-Sleep -Seconds 5
        Remove-Item (Join-Path $WorkingFolder 'dotnet.exe') -Force
    }
}

Pop-Location
Write-Host 'Done, It may require reboot to some function(s).' -ForegroundColor Green