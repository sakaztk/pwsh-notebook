#Requires -Version 5
[CmdletBinding()]
Param(
    [ValidateSet('3.7','3.8','3.9','3.10','3.11','3.12','3.13')]
    [String]$WinPythonVersion = '3.13',
    [ValidateSet('unmarked','dot','cod','PyPy','dotPyPy','post1')]
    [String]$WinPythonType = 'dot',
    [Switch]$InstallPwsh7SDK,
    [Switch]$InstallDotnetInteractive,
    [Switch]$InstallPortableGit,
    [Switch]$AddStartMenu,
    [String]$WinPythonPath = (Join-Path $env:LOCALAPPDATA 'Programs\WinPython'),
    [String]$NodePath = (Join-Path $WinPythonPath 'node'),
    [String]$PortableGitPath = (Join-Path $WinPythonPath 'PortableGit'),
    [Switch]$CleanupDownloadFiles,
    [String]$WorkingFolder = $PSScriptRoot
)
$ErrorActionPreference = 'Stop'
Push-Location $WorkingFolder
chcp 65001
$OutputEncoding = [System.Text.Encoding]::GetEncoding('utf-8')
$osBits = ([System.IntPtr]::Size*8).ToString()

if (-not([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    if ($InstallDotnetInteractive) {
        Write-Error 'Require admin privileges for installation of .Net Interactive.'
        exit
    }
}

if ($ProgressPreference -ne 'SilentlyContinue') {
    Write-Verbose 'Change $ProgressPreference to SilentlyContinue.'
    $exProgressPreference = $ProgressPreference
    $ProgressPreference = 'SilentlyContinue'
}

Write-Host 'Downloading latest WinPython...'
if ($WinPythonType -eq 'unmarked') {
    $pattern = $osBits + '-' + $WinPythonVersion + '.*\d\.exe'
}
else {
    $pattern = $osBits + '-' + $WinPythonVersion + '.*' + $WinPythonType + '\.exe'
}
$releaseURI = 'https://github.com/winpython/winpython/releases'
$latestRelease = (Invoke-WebRequest -Uri "$releaseURI/latest" -UseBasicParsing -Headers @{'Accept'='application/json'}| ConvertFrom-Json).update_url
$versionString = $latestRelease -replace '.*tag/(.*)', '$1'
$links = (Invoke-WebRequest -Uri "$releaseURI/expanded_assets/$($versionString)" -UseBasicParsing).Links.href
Write-Verbose ('$pattern = ' + $pattern)
Try {
    $fileUri = ($links | Select-String -Pattern $pattern | Get-Unique).Tostring().Trim()
}
Catch {
    throw "Does not exist WinPython$osBits version $WinPythonVersion $WinPythonType in latest release."
}
Invoke-WebRequest -uri "https://github.com$($fileUri)" -OutFile (Join-Path $WorkingFolder 'Winpython.exe') -Verbose
$wpVer = $fileUri -replace ".*-((\d+\.)?(\d+\.)?(\d+\.)?(\*|\d+)).*\.exe",'$1'

Write-Host 'Downloading Node.js...'
$releaseURI = 'https://nodejs.org/download/release/latest-v22.x'
$links = (Invoke-WebRequest -uri $releaseURI -UseBasicParsing).Links.href
$pattern = "win-x$osBits.*\.zip"
$fileUri = 'https://nodejs.org' + ($links | Select-String -Pattern $pattern | Get-Unique).Tostring().Trim()
Invoke-WebRequest -Uri $fileUri -OutFile (Join-Path $WorkingFolder '\node.zip')

if ($InstallPortableGit) {
    Write-Host 'Downloading latest PortableGit...'
    $releaseURI = 'https://github.com/git-for-windows/git/releases'
    $latestRelease = (Invoke-WebRequest -Uri "$releaseURI/latest" -UseBasicParsing -Headers @{'Accept'='application/json'}| ConvertFrom-Json).update_url
    $versionString = $latestRelease -replace '.*tag/(.*)', '$1'
    $links = (Invoke-WebRequest -Uri "$releaseURI/expanded_assets/$($versionString)" -UseBasicParsing).Links.href
    $fileUri = ($links | Select-String -Pattern ".*PortableGit.*($osBits)-bit.*\.exe" | Get-Unique).Tostring().Trim()
    Invoke-WebRequest -uri "https://github.com$($fileUri)" -OutFile (Join-Path $WorkingFolder 'PortableGit.exe') -Verbose
}

if ($InstallDotnetInteractive) {
    Write-Host 'Downloading latest .NET Core SDK...'
    $links = (Invoke-WebRequest -uri 'https://dotnet.microsoft.com/download' -UseBasicParsing).Links.href
    $latestVer = (($links | Select-String -Pattern '.*sdk.*windows-x64-installer') -replace '.*sdk-(([0-9]+\.){1}[0-9]+(\.[0-9]+)?)-.*', '$1' | Measure-Object -Maximum).Maximum
    $latestUri = 'https://dotnet.microsoft.com' + ($links | Select-String -Pattern ".*sdk-$latestVer-windows-x64-installer" | Get-Unique).Tostring().Trim()
    $fileUri = ((Invoke-WebRequest -uri $latestUri -UseBasicParsing).Links.href | Select-String -Pattern '.*\.exe' | Get-Unique).Tostring().Trim()
    Invoke-WebRequest -uri $fileUri -UseBasicParsing -OutFile (Join-Path $WorkingFolder 'dotnet.exe') -Verbose
}
elseif ($InstallPwsh7SDK) {
    Write-Host 'Downloading latest .NET Runtime...'
    $links = (Invoke-WebRequest -Uri 'https://dotnet.microsoft.com/en-us/download/dotnet/8.0/runtime' -UseBasicParsing).Links.href
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
Write-Host 'Downloading latest DeepAQ pwshSDK Kernel...'
$fileUri = 'https://github.com' + ( $links | Select-String -Pattern 'Jupyter-PowerShellSDK-7.*\.zip' | Get-Unique).Tostring().Trim()
Invoke-WebRequest -uri $fileUri -UseBasicParsing -OutFile (Join-Path $WorkingFolder 'PowerShellSDK.zip') -Verbose

if ($null -ne $exProgressPreference) {
    Write-Verbose "Restore $ProgressPreference to $exProgressPreference"
    $ProgressPreference = $exProgressPreference
}

Write-Host 'Installing WinPython...'
New-Item -Path $WinPythonPath -ItemType Directory -Force
Start-Process -FilePath (Join-Path $WorkingFolder 'Winpython.exe') -ArgumentList ('-y -o"' + $WinPythonPath + '"') -wait
$wpRoot = (Join-Path $WinPythonPath "WPy$osBits-$($wpVer -replace('\.',''))")

$kernelPath = Join-Path $wpRoot '\settings\kernels'
if ($CleanupDownloadFiles) {
    Start-Sleep -Seconds 5
    Remove-Item (Join-Path $WorkingFolder 'Winpython.exe') -Force
}

Write-Host 'Installing Node.js...'
New-Item -Path $NodePath -ItemType Directory -Force
Expand-Archive -Path (Join-Path $WorkingFolder '\node.zip') -DestinationPath $NodePath -Force
[Reflection.Assembly]::LoadWithPartialName('System.IO.Compression.FileSystem')
$zipFile = [IO.Compression.ZipFile]::OpenRead("$(Join-Path $WorkingFolder '\node.zip')")
$nodeFolder = $zipFile.Entries[0].FullName -replace('/','')
$zipFile.Dispose()
$nodeEnvPath = join-path $nodePath $nodeFolder
. (join-path $nodeEnvPath "nodevars.bat")
$env:Path += (';' + $nodeEnvPath)
$nodeEnvPath = '%WINPYDIRBASE%\..\node\' + $nodeFolder
@"
set NODEPATH=$nodeEnvPath
echo ";%PATH%;" | %FINDDIR%\find.exe /C /I ";%NODEPATH%\;" >nul
if %ERRORLEVEL% NEQ 0 (
    set "PATH=%PATH%;%NODEPATH%\;"
)

"@ | Add-Content -Path "$wpRoot\scripts\env.bat"

if ($CleanupDownloadFiles) {
    Remove-Item (Join-Path $WorkingFolder '\node.zip') -Force
}

if ($InstallPortableGit) {
    Write-Host 'Installing PortableGit...'
    New-Item -Path $PortableGitPath -ItemType Directory -Force
    Start-Process -FilePath (Join-Path $WorkingFolder 'PortableGit.exe') -ArgumentList ('-y -o"' + $PortableGitPath + '"') -wait
    $gitEnvPath = Join-Path $PortableGitPath 'cmd'
    if ($CleanupDownloadFiles) {
        Start-Sleep -Seconds 5
        Remove-Item (Join-Path $WorkingFolder 'PortableGit.exe') -Force
    }
    $env:Path += ";$gitEnvPath"
    if ($PortableGitPath -eq (Join-Path $WinPythonPath 'PortableGit')) {
        $gitEnvPath = '%WINPYDIRBASE%\..\PortableGit\cmd'
    }
@"
set GITPATH=$gitEnvPath
echo ";%PATH%;" | %FINDDIR%\find.exe /C /I ";%GITPATH%\;" >nul
if %ERRORLEVEL% NEQ 0 (
    set "PATH=%PATH%;%GITPATH%\;"
)

"@ | Add-Content -Path "$wpRoot\scripts\env.bat"    
}

Write-Host 'Installing Jupyter...'
Get-Content "$wpRoot\scripts\WinPython_PS_Prompt.ps1" | ForEach-Object {
    if ($_ -match '^\s*\$host\.ui\.RawUI\.(BackgroundColor|ForegroundColor)\s*=') {
        "# $_"
    } else {
        $_
    }
} | Set-Content "$wpRoot\scripts\WinPython_PS_Prompt_temp.ps1"

& "$wpRoot\scripts\env_for_icons.bat"
. "$wpRoot\scripts\WinPython_PS_Prompt_temp.ps1"
Remove-Item "$wpRoot\scripts\WinPython_PS_Prompt_temp.ps1" -Force
python -m pip install --upgrade pip
python -m pip install --upgrade wheel
python -m pip install jupyter
python -m pip install notebook
python -m pip install jupyterlab

$packagePath = Join-Path $wpRoot (Get-ChildItem $wpRoot -Filter "python-$WinPythonVersion*" -Name) | Join-Path -ChildPath '\python\Lib\site-packages'
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
set PS5KPATH=%WINPYDIR%\Lib\site-packages\powershell5_kernel
echo ";%PATH%;" | %FINDDIR%\find.exe /C /I ";%PS5KPATH%\;" >nul
if %ERRORLEVEL% NEQ 0 (
    set "PATH=%PATH%;%PS5KPATH%\;"
)

"@ | Add-Content -Path "$wpRoot\scripts\env.bat"

@"
{
    "argv": [
        "Jupyter_PowerShell5.exe",
        "{connection_file}"
    ],
    "display_name": "PowerShell 5",
    "language": "Powershell"
}
"@ | Set-Content -Path (Join-Path $kernelPath '\powershell5\kernel.json')
Move-Item -Path (Join-Path $installPath '*.png') -Destination (Join-Path $kernelPath '\powershell5\') -Force
if ($CleanupDownloadFiles) {
    Remove-Item (Join-Path $WorkingFolder 'PowerShell5.zip') -Force
}

if ($InstallPwsh7SDK) {
    $packagePath = Join-Path $wpRoot (Get-ChildItem $wpRoot -Filter "python-$WinPythonVersion*" -Name) | Join-Path -ChildPath '\python\Lib\site-packages'
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
set PS7KPATH=%WINPYDIR%\Lib\site-packages\powershellSDK_kernel
echo ";%PATH%;" | %FINDDIR%\find.exe /C /I ";%PS7KPATH%\;" >nul
if %ERRORLEVEL% NEQ 0 (
    set "PATH=%PATH%;%PS7KPATH%\;"
)

"@ | Add-Content -Path "$wpRoot\scripts\env.bat"

@"
{
    "argv": [
        "Jupyter_PowerShellSDK.exe",
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
    Write-Host 'Installing .NET SDK...'
    Start-Process -FilePath (Join-Path $WorkingFolder 'dotnet.exe') -ArgumentList '/install /passive /norestart' -Wait
    Write-Output 'Installing .NET Interactive...'
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

if ($AddStartMenu) {
    $shortcutPath = join-path $env:APPDATA '\Microsoft\Windows\Start Menu\Programs\WinPython'
    New-Item -Path $shortcutPath -ItemType Directory -Force
    $wshShell = New-Object -comObject WScript.Shell
    Get-ChildItem -Path $wpRoot -Filter '*.exe' | ForEach-Object {
        $Shortcut = $WshShell.CreateShortcut("$shortcutPath\$($_.Name -replace '.exe','').lnk")
        $Shortcut.TargetPath = $_.FullName
        $Shortcut.Save()    
    }    
}

@(
    "$wpRoot\scripts\env.bat"
) | ForEach-Object {
    $fileContent = Get-Content $_ -Raw
    if ($fileContent -notcontains "chcp 65001") {
        $fileContent = $filecontent -replace "^@echo off", "$&`nchcp 65001"
        $filecontent | Set-Content $_
    }
}

@'
@echo off
pushd %~dp0
icacls ..\..\ /grant Everyone:F /T /C
popd
pause
'@ | Set-Content -Path "$wpRoot\scripts\sakaztk-everyonefull.bat"

Pop-Location
Write-Host 'Done, It may require reboot to some function(s).' -ForegroundColor Green