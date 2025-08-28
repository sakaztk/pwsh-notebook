#Requires -Version 5
[CmdletBinding()]
Param(
    [String]$InstallationType = 'Computer',
    [Switch]$InstallPwsh7SDK,
    [Switch]$InstallDotnetInteractive,
    [Switch]$CleanupDownloadFiles,
    [String]$WorkingFolder = $PSScriptRoot
)
$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = 'tls12, tls11, tls'
Push-Location $WorkingFolder
chcp 65001
#$OutputEncoding = [System.Console]::OutputEncoding = [System.Console]::InputEncoding = [System.Text.Encoding]::GetEncoding('utf-8')
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
    { @('system', 'computer', 'allusers') -contains $_ } {
        if (-not([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
            Write-Verbose 'Relaunch script with admin privileges...'
            Start-Process powershell.exe "-NoExit -ExecutionPolicy Bypass -Command `"$PSCommandPath`" $paramStrings" -Verb RunAs
            exit
        }
        $condaOpt = '/InstallationType=AllUsers /AddToPath=0 /RegisterPython=1 /NoRegistru=0 /Noscripts=o /S'
        $dataPath = $env:ProgramData
        $kernelPath = Join-Path $env:ProgramData '\Anaconda3\share\jupyter\kernels'
        $packagePath = Join-Path $env:ProgramData '\Anaconda3\Lib\site-packages'
        #$pyTypeOpt = '--sys-prefix'
        [System.Environment]::SetEnvironmentVariable('PYTHONUTF8',1,[System.EnvironmentVariableTarget]::Machine)
    }
    { @('user', 'justme') -contains $_ } {
        $condaOpt = '/InstallationType=JustMe /AddToPath=0 /RegisterPython=1 /NoRegistru=0 /Noscripts=o /S'
        $dataPath = $env:UserProfile
        $kernelPath = Join-Path $env:AppData '\jupyter\kernels'
        $packagePath = Join-Path $env:USERPROFILE '\Anaconda3\Lib\site-packages'
        #$pyTypeOpt = '--user'
        [System.Environment]::SetEnvironmentVariable('PYTHONUTF8',1,[System.EnvironmentVariableTarget]::User)
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

Write-Host 'Downloading latest Anaconda...'
$links = (Invoke-WebRequest -Uri 'https://www.anaconda.com/download/success' -UseBasicParsing).Links.href
$fileUri = ($links | Select-String -Pattern '.*Anaconda3.*Windows-x86_64.exe' | Get-Unique).Tostring().Trim()
Invoke-WebRequest -Uri $fileUri -UseBasicParsing -OutFile (Join-Path $WorkingFolder 'anaconda.exe') -Verbose

if ($InstallDotnetInteractive) {
    Write-Host 'Downloading latest .NET Core SDK...'
    $links = (Invoke-WebRequest -Uri 'https://dotnet.microsoft.com/download' -UseBasicParsing).Links.href
    $latestVer = (($links | Select-String -Pattern '.*sdk.*windows-x64-installer') -replace '.*sdk-(([0-9]+\.){1}[0-9]+(\.[0-9]+)?)-.*', '$1' | Measure-Object -Maximum).Maximum
    $latestUri = 'https://dotnet.microsoft.com' + ($links | Select-String -Pattern ".*sdk-$latestVer-windows-x64-installer" | Get-Unique).Tostring().Trim()
    $fileUri = ((Invoke-WebRequest -Uri $latestUri -UseBasicParsing).Links.href | Select-String -Pattern '.*\.exe' | Get-Unique).Tostring().Trim()
    Invoke-WebRequest -Uri $fileUri -UseBasicParsing -OutFile (Join-Path $WorkingFolder 'dotnet.exe') -Verbose
}
elseif ($InstallPwsh7SDK) {
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
Write-Host 'Downloading latest DeepAQ pwshSDK Kernel...'
$fileUri = 'https://github.com' + ( $links | Select-String -Pattern 'Jupyter-PowerShellSDK-7.*\.zip' | Get-Unique).Tostring().Trim()
Invoke-WebRequest -uri $fileUri -UseBasicParsing -OutFile (Join-Path $WorkingFolder 'PowerShellSDK.zip') -Verbose

if ($null -ne $exProgressPreference) {
    Write-Verbose "Restore $ProgressPreference to $exProgressPreference"
    $ProgressPreference = $exProgressPreference
}

Write-Host 'Installing Anaconda. this may take survival minutes...'
$process = Start-Process -FilePath 'anaconda.exe' -ArgumentList $condaOpt -PassThru
for($i = 0; $i -le 100; $i = ($i + 1) % 100) {
    Write-Progress -Activity 'Installer' -PercentComplete $i -Status 'Installing...'
    Start-Sleep -Seconds 1
    if ($process.HasExited) {
        Write-Progress -Activity 'Installer' -Completed
        break
    }
}
if ($CleanupDownloadFiles) {
    Start-Sleep -Seconds 5
    Remove-Item 'anaconda.exe' -Force
}
Write-Host '...Done'
& "$dataPath\Anaconda3\shell\condabin\conda-hook.ps1"
conda activate
Write-Host '##### Jupyter Installation #####'
conda upgrade -y pip
conda upgrade -y wheel
conda install -y jupyter
conda install -y notebook
conda install -y jupyterlab
conda install -y -c conda-forge nodejs

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
if ($CleanupDownloadFiles) {
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
    Write-Host 'Installing .NET SDK...'
    Start-Process -FilePath 'dotnet.exe' -ArgumentList '/install /passive /norestart' -Wait
    Write-Host 'Installing .NET Interactive...'
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    dotnet tool install -g --add-source "https://pkgs.dev.azure.com/dnceng/public/_packaging/dotnet-tools/nuget/v3/index.json" Microsoft.dotnet-interactive
    dotnet interactive jupyter install --path "$kernelPath"
    if ($CleanupDownloadFiles) {
        Start-Sleep -Seconds 5
        Remove-Item 'dotnet.exe' -Force
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

@(
    "$dataPath\Anaconda3\Scripts\jupyter-notebook-script.py"
) | ForEach-Object {
    $fileContent = Get-Content $_ -Raw
    if ($fileContent -notcontains "chcp 65001") {
        $fileContent = $filecontent -replace "import sys", "$&`nimport os `nos.system('chcp 65001')"
        $filecontent | Set-Content $_
    }
}
Pop-Location
Write-Host 'Done, It may require reboot to some function(s).' -ForegroundColor Green