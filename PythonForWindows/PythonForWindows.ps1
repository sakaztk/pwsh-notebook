#Requires -Version 5
[CmdletBinding()]
Param(
    [String]$InstallationType = 'Computer',
    [ValidateSet('2.7','3.6','3.7','3.8','3.9','3.10')]
    [String]$PythonVersion = '3.9',
    [String]$OverwriteInstallOptionsTo = '',
    [Switch]$InstallPwsh7SDK,
    [Switch]$InstallGit,
    [Switch]$InstallDotnetInteractive,
    [Switch]$InstallNBExtensions,
    [Switch]$InstallNIIExtensions,
    [Switch]$UsePipKernel,
    [Switch]$InstallPwsh7ForPipKernel,
    [Switch]$CleanupDownloadFiles,
    [String]$WorkingFolder = $PSScriptRoot
)
$ErrorActionPreference = 'Stop'
Push-Location $WorkingFolder
chcp 65001
$OutputEncoding = [System.Console]::OutputEncoding = [System.Console]::InputEncoding = [System.Text.Encoding]::GetEncoding('utf-8')

if (($null -eq (Invoke-Command -ScriptBlock {$ErrorActionPreference="silentlycontinue"; git --version} -ErrorAction SilentlyContinue)) -and (-not($InstallGit))) {
    if ($InstallNIIExtensions) {
        throw 'You need git command or InstallGit option for InstallNIIExtensions option.'
    }
}

$psBoundParameters.Keys | ForEach-Object {
    if ($($PSBoundParameters.$_.GetType().Name) -eq 'SwitchParameter') {
        $paramStrings += " -$_"
    }
    else {
        $paramStrings += " -$_ $($PSBoundParameters.$_)"
    }
}
Write-Verbose "Commandline: `"$PSCommandPath`"$paramStrings"
switch ($InstallationType) {
    {@('system', 'computer', 'allusers') -contains $_} {
        if (-not([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
            Write-Verbose 'Relaunch script with admin privileges...'
            Start-Process powershell.exe "-NoExit -ExecutionPolicy Bypass -Command `"$PSCommandPath`" $paramStrings" -Verb RunAs
            exit
        }
        if ( '' -eq $OverwriteInstallOptionsTo ) {
            $installOpt = '/passive InstallAllUsers=1 PrependPath=1'
        }
        else {
            $installOpt = $OverwriteInstallOptionsTo
        }
        $pyTypeOpt = '--sys-prefix'
    }
    {@('user', 'justme') -contains $_} {
        if ( '' -eq $OverwriteInstallOptionsTo ) {
            $installOpt = '/passive InstallAllUsers=0 PrependPath=1'
        }
        else {
            $installOpt = $OverwriteInstallOptionsTo
        }
        $pyTypeOpt = '--sys-prefix' #install to $env:LOCALAPPDATA (not to $env:APPDATA with --user option)
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

Write-Verbose "Downloading latest Python $PythonVersion for Windows..."
$links = (Invoke-WebRequest -uri 'https://www.python.org/downloads/windows/' -UseBasicParsing).Links.href
$targetLinks = $links | Select-String -Pattern ".*python-($PythonVersion\.\d*)-amd64.exe"
$latestVer = $PythonVersion + '.' + ($targetLinks -replace ".*python-$PythonVersion\.(\d*)-amd64.exe", '$1'| Measure-Object -Maximum).Maximum
$fileUri = ($targetLinks | Select-String -Pattern ".*python-$latestVer-amd64.exe" | Get-Unique).Tostring().Trim()
Invoke-WebRequest -uri $fileUri -UseBasicParsing -OutFile (Join-Path $WorkingFolder 'pythoninstaller.exe') -Verbose

Write-Verbose 'Downloading latest Node.js...'
$links = (Invoke-WebRequest -uri 'https://nodejs.org/en/download/' -UseBasicParsing).Links.href
$fileUri = ($links | Select-String -Pattern "x64\.msi" | Get-Unique).Tostring().Trim()
Invoke-WebRequest -Uri $fileUri -OutFile (Join-Path $WorkingFolder '\nodeinstaller.msi')

if ($InstallGit) {
    Write-Verbose 'Downloading latest Git for Windows...'
    $releaseURI = 'https://github.com/git-for-windows/git/releases'
    $latestRelease = (Invoke-WebRequest -Uri "$releaseURI/latest" -UseBasicParsing -Headers @{'Accept'='application/json'}| ConvertFrom-Json).update_url
    $versionString = $latestRelease -replace '.*tag/(.*)', '$1'
    $links = (Invoke-WebRequest -Uri "$releaseURI/expanded_assets/$($versionString)" -UseBasicParsing).Links.href
    $fileUri = 'https://github.com' + ($links | Select-String -Pattern '.*64-bit.exe' | Get-Unique).Tostring().Trim()
    Write-Verbose "Download from $fileUri"
    Invoke-WebRequest -Uri $fileUri -UseBasicParsing -OutFile (Join-Path $WorkingFolder 'gitinstaller.exe') -Verbose
}

if ($InstallPwsh7ForPipKernel) {
    Write-Verbose 'Downloading latest PowerShell 7...'
    $releaseURI = 'https://github.com/PowerShell/PowerShell/releases'
    $latestRelease = (Invoke-WebRequest -Uri "$releaseURI/latest" -UseBasicParsing -Headers @{'Accept'='application/json'}| ConvertFrom-Json).update_url
    $versionString = $latestRelease -replace '.*tag/(.*)', '$1'
    $links = (Invoke-WebRequest -Uri "$releaseURI/expanded_assets/$($versionString)" -UseBasicParsing).Links.href
    $fileUri = 'https://github.com' + ($links | Select-String -Pattern '.*x64.msi' | Get-Unique).Tostring().Trim()
    Write-Verbose "Download from $fileUri"
    Invoke-WebRequest -Uri $fileUri -UseBasicParsing -OutFile (Join-Path $WorkingFolder 'pwsh.msi') -Verbose
}

if ($InstallDotnetInteractive) {
    Write-Verbose 'Downloading latest .NET SDK...'
    $links = (Invoke-WebRequest -Uri 'https://dotnet.microsoft.com/download' -UseBasicParsing).Links.href
    $latestVer = (($links | Select-String -Pattern '.*sdk.*windows-x64-installer') -replace '.*sdk-(([0-9]+\.){1}[0-9]+(\.[0-9]+)?)-.*', '$1' | Measure-Object -Maximum).Maximum
    $latestUri = 'https://dotnet.microsoft.com' + ($links | Select-String -Pattern ".*sdk-$latestVer-windows-x64-installer" | Get-Unique).Tostring().Trim()
    $fileUri = ((Invoke-WebRequest -Uri $latestUri -UseBasicParsing).Links.href | Select-String -Pattern '.*\.exe' | Get-Unique).Tostring().Trim()
    Invoke-WebRequest -Uri $fileUri -UseBasicParsing -OutFile (Join-Path $WorkingFolder 'dotnet.exe') -Verbose
}
else {
    Write-Verbose 'Downloading latest .NET Runtime...'
    $links = (Invoke-WebRequest -Uri 'https://dotnet.microsoft.com/en-us/download/dotnet/7.0/runtime' -UseBasicParsing).Links.href
    $latestVer = (($links | Select-String -Pattern '.*runtime.*windows-x64-installer') -replace '.*runtime-(([0-9]+\.){1}[0-9]+(\.[0-9]+)?)-.*', '$1' | Measure-Object -Maximum).Maximum
    $latestUri = 'https://dotnet.microsoft.com' + ($links | Select-String -Pattern ".*runtime-$latestVer-windows-x64-installer" | Get-Unique).Tostring().Trim()
    $fileUri = ((Invoke-WebRequest -Uri $latestUri -UseBasicParsing).Links.href | Select-String -Pattern '.*\.exe' | Get-Unique).Tostring().Trim()
    Invoke-WebRequest -Uri $fileUri -UseBasicParsing -OutFile (Join-Path $WorkingFolder 'dotnet.exe') -Verbose
}

if (-not($UsePipKernel)) {
    $releaseURI = 'https://github.com/sakaztk/Jupyter-PowerShellSDK/releases'
    $latestRelease = (Invoke-WebRequest -Uri "$releaseURI/latest" -UseBasicParsing -Headers @{'Accept'='application/json'}| ConvertFrom-Json).update_url
    $versionString = $latestRelease -replace '.*tag/(.*)', '$1'
    $links = (Invoke-WebRequest -Uri "$releaseURI/expanded_assets/$($versionString)" -UseBasicParsing).Links.href
    Write-Verbose 'Downloading latest DeepAQ pwsh5 Kernel...'
    $fileUri = 'https://github.com' + ( $links | Select-String -Pattern '.*PowerShell5.zip' | Get-Unique).Tostring().Trim()
    Invoke-WebRequest -uri $fileUri -UseBasicParsing -OutFile (Join-Path $WorkingFolder 'PowerShell5.zip') -Verbose
    Write-Verbose 'Downloading latest DeepAQ pwshSDK Kernel...'
    $fileUri = 'https://github.com' + ( $links | Select-String -Pattern 'Jupyter-PowerShellSDK-7.*\.zip' | Get-Unique).Tostring().Trim()
    Invoke-WebRequest -uri $fileUri -UseBasicParsing -OutFile (Join-Path $WorkingFolder 'PowerShellSDK.zip') -Verbose
}

if ($null -ne $exProgressPreference) {
    Write-Verbose "Restore $ProgressPreference to $exProgressPreference"
    $ProgressPreference = $exProgressPreference
}

Write-Verbose 'Installing Python...'
Start-Process -FilePath (Join-Path $WorkingFolder 'pythoninstaller.exe') -ArgumentList $installOpt -Wait
if ($CleanupDownloadFiles) {
    Start-Sleep -Seconds 5
    Remove-Item (Join-Path $WorkingFolder 'pythoninstaller.exe') -Force
}
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
$pythonRoot = Split-Path (python -c "import sys; print(sys.executable)") -Parent
$kernelPath = Join-Path $pythonRoot '\share\jupyter\kernels'
$packagePath = Join-Path $pythonRoot '\Lib\site-packages'

Write-Verbose 'Installing Node.js...'
Start-Process -FilePath (Join-Path $WorkingFolder 'nodeinstaller.msi') -ArgumentList ('/passive') -wait
if ($CleanupDownloadFiles) {
    Start-Sleep -Seconds 5
    Remove-Item (Join-Path $WorkingFolder 'nodeinstaller.msi') -Force
}

if ($InstallGit) {
    Write-Verbose 'Installing latest Git for Windows...'
    $installOpt = '/SILENT /NORESTART /NOCANCEL /SP- /CLOSEAPPLICATIONS /RESTARTAPPLICATIONS /COMPONENTS="icons,ext\reg\shellhere,assoc,assoc_sh"'
    Start-Process -FilePath (Join-Path $WorkingFolder 'gitinstaller.exe') -ArgumentList ($installOpt) -wait
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    if ( $CleanupDownloadFiles ) {
        Start-Sleep -Seconds 5
        Remove-Item (Join-Path $WorkingFolder 'gitinstaller.exe') -Force
    }
}

Write-Verbose '##### Jupyter Installation #####'
python -m pip install --upgrade pip
python -m pip install --upgrade wheel
python -m pip install jupyter
python -m pip install notebook
python -m pip install jupyterlab
if ($InstallNBExtensions) {
    python -m pip install jupyter_nbextensions_configurator
    python -m jupyter nbextensions_configurator enable
    python -m pip install https://github.com/ipython-contrib/jupyter_contrib_nbextensions/tarball/master
    python -m jupyter contrib nbextension install $pyTypeOpt
}
if ($InstallNIIExtensions) {
    python -m pip install git+https://github.com/NII-cloud-operation/Jupyter-LC_run_through
    python -m pip install git+https://github.com/NII-cloud-operation/Jupyter-LC_wrapper
    python -m pip install git+https://github.com/NII-cloud-operation/Jupyter-multi_outputs
    python -m pip install git+https://github.com/NII-cloud-operation/Jupyter-LC_index
    python -m pip install git+https://github.com/NII-cloud-operation/Jupyter-LC_notebook_diff
    python -m pip install git+https://github.com/NII-cloud-operation/sidestickies
    python -m pip install git+https://github.com/NII-cloud-operation/nbsearch
    python -m pip install git+https://github.com/NII-cloud-operation/Jupyter-LC_nblineage
    if ($InstallNBExtensions) {
        python -m jupyter nbextension install --py lc_run_through $pyTypeOpt
        python -m jupyter nbextension install --py lc_wrapper $pyTypeOpt
        python -m jupyter nbextension install --py lc_multi_outputs $pyTypeOpt
        python -m jupyter nbextension install --py notebook_index $pyTypeOpt
        python -m jupyter nbextension install --py lc_notebook_diff $pyTypeOpt
        python -m jupyter nbextension install --py nbtags $pyTypeOpt
        python -m jupyter nbextension install --py nbsearch $pyTypeOpt
        python -m jupyter nbextension install --py nblineage $pyTypeOpt
    }
}
if ($UsePipKernel) {
    python -m pip install powershell_kernel
    python -m powershell_kernel.install $pyTypeOpt
    $fileContent = Get-Content "$packagePath\powershell_kernel\powershell_proxy.py" -Raw
    $fileContent = $filecontent -replace '\^','\a'
    $filecontent | Set-Content "$packagePath\powershell_kernel\powershell_proxy.py" -Force
    if ($InstallPwsh7ForPipKernel) {
        Write-Verbose 'Installing PowerShell 7...'
        Start-Process -FilePath (Join-Path $WorkingFolder 'pwsh.msi') -ArgumentList '/passive' -Wait
        Copy-Item -Path "$kernelPath\powershell" -Destination "$kernelPath\powershell7" -Recurse -Force
        $fileContent = Get-Content "$kernelPath\powershell7\kernel.json" -Raw
        $fileContent = $filecontent -replace '"display_name": "[^"]*"','"display_name": "PowerShell 7"'
        $fileContent = $filecontent -replace '"powershell_command": "[^"]*"',"`"powershell_command`": `"pwsh.exe`""
        $filecontent | Set-Content "$kernelPath\powershell7\kernel.json"
        if ($CleanupDownloadFiles) {
            Start-Sleep -Seconds 5
            Remove-Item (Join-Path $WorkingFolder 'pwsh.msi') -Force
        }
    }
}
else {
    Write-Verbose 'Installing DeepAQ pwshSDK Kernel...'
    $installPath = Join-Path $packagePath 'powershell5_kernel'
    Expand-Archive -Path (Join-Path $WorkingFolder 'PowerShell5.zip') -DestinationPath $installPath -Force
    New-Item -ItemType Directory -Path (Join-Path $kernelPath '\powershell5\') -Force
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
    if ( $CleanupDownloadFiles ) {
        Remove-Item (Join-Path $WorkingFolder 'PowerShell5.zip') -Force
   }
}
if ($InstallPwsh7SDK) {
    Write-Verbose 'Installing DeepAQ pwshSDK Kernel...'
    $installPath = Join-Path $packagePath 'powershellSDK_kernel'
    Expand-Archive -Path (Join-Path $WorkingFolder 'PowerShellSDK.zip') -DestinationPath $installPath -Force
    New-Item -ItemType Directory -Path (Join-Path $kernelPath '\powershellSDK\') -Force
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
    if ($CleanupDownloadFiles) {
        Remove-Item (Join-Path $WorkingFolder 'PowerShellSDK.zip') -Force
    }
}

if ($InstallDotnetInteractive) {
    Write-Verbose 'Installing .NET Core SDK...'
    Start-Process -FilePath (Join-Path $WorkingFolder 'dotnet.exe') -ArgumentList '/install /passive /norestart' -Wait
    Write-Verbose 'Installing .NET Interactive...'
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    dotnet tool install -g --add-source "https://pkgs.dev.azure.com/dnceng/public/_packaging/dotnet-tools/nuget/v3/index.json" Microsoft.dotnet-interactive
    dotnet interactive jupyter install --path "$kernelPath"
    if ($CleanupDownloadFiles) {
        Start-Sleep -Seconds 5
        Remove-Item (Join-Path $WorkingFolder 'dotnet.exe') -Force
    }
}
elseif ($InstallPwsh7SDK) {
    Write-Verbose 'Installing .NET Runtime...'
    Start-Process -FilePath (Join-Path $WorkingFolder 'dotnet.exe') -ArgumentList '/install /passive /norestart' -Wait
    if ($CleanupDownloadFiles) {
        Start-Sleep -Seconds 5
        Remove-Item (Join-Path $WorkingFolder 'dotnet.exe') -Force
    }
}

Pop-Location
Write-Host 'Done, It may require reboot to some function(s).' -ForegroundColor Green