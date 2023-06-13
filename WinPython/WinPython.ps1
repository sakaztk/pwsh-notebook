#Requires -Version 5
#Requires -RunAsAdministrator
[CmdletBinding()]
Param(
    [ValidateSet('3.7','3.8','3.9','3.10','3.11')]
    [String]$WinPythonVersion = '3.11',
    [ValidateSet('unmarked','dot','cod','PyPy','dotPyPy','post1')]
    [String]$WinPythonType = 'dot',
    [Switch]$InstallPwsh7SDK,
    [Switch]$InstallDotnetInteractive,
    [Switch]$InstallNBExtensions,
    [Switch]$InstallNIIExtensions,
    [Switch]$InstallPortableGit,
    [Switch]$UsePipKernel,
    [Switch]$InstallPwsh7ForPipKernel,
    [Switch]$AddStartMenu,
    [String]$WinPythonPath = (Join-Path $env:LOCALAPPDATA 'Programs\WinPython'),
    [String]$NodePath = (Join-Path $WinPythonPath 'node'),
    [String]$Pwsh7ForPipKernelPath = (Join-Path $WinPythonPath 'pwsh7'),
    [String]$PortableGitPath = (Join-Path $WinPythonPath 'PortableGit'),
    [Switch]$CleanupDownloadFiles,
    [String]$WorkingFolder = $PSScriptRoot
)
$ErrorActionPreference = 'Stop'
Push-Location $WorkingFolder
$osBits = ([System.IntPtr]::Size*8).ToString()

if (($null -eq (Invoke-Command -ScriptBlock {$ErrorActionPreference="silentlycontinue"; cmd.exe /c where git 2> null} -ErrorAction SilentlyContinue)) -and (-not($InstallPortableGit))) {
    if ($InstallNIIExtensions) {
        throw 'You need git or InstallPortableGit option for InstallNIIExtensions option.'
    }
}

if ($ProgressPreference -ne 'SilentlyContinue') {
    Write-Verbose 'Change $ProgressPreference to SilentlyContinue.'
    $exProgressPreference = $ProgressPreference
    $ProgressPreference = 'SilentlyContinue'
}

Write-Verbose 'Downloading latest WinPython...'
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

Write-Verbose 'Downloading latest Node.js...'
$links = (Invoke-WebRequest -uri 'https://nodejs.org/ja/download/' -UseBasicParsing).Links.href
$pattern = "win-x$osBits.*\.zip"
$fileUri = ($links | Select-String -Pattern $pattern | Get-Unique).Tostring().Trim()
Invoke-WebRequest -Uri $fileUri -OutFile (Join-Path $WorkingFolder '\node.zip')

if ($InstallPortableGit) {
    Write-Verbose 'Downloading latest PortableGit...'
    $releaseURI = 'https://github.com/git-for-windows/git/releases'
    $latestRelease = (Invoke-WebRequest -Uri "$releaseURI/latest" -UseBasicParsing -Headers @{'Accept'='application/json'}| ConvertFrom-Json).update_url
    $versionString = $latestRelease -replace '.*tag/(.*)', '$1'
    $links = (Invoke-WebRequest -Uri "$releaseURI/expanded_assets/$($versionString)" -UseBasicParsing).Links.href
    $fileUri = ($links | Select-String -Pattern ".*PortableGit.*$osBits.*\.exe" | Get-Unique).Tostring().Trim()
    Invoke-WebRequest -uri "https://github.com$($fileUri)" -OutFile (Join-Path $WorkingFolder 'PortableGit.exe') -Verbose
}

if ($InstallPwsh7ForPipKernel) {
    Write-Verbose 'Downloading latest PowerShell 7...'
    $releaseURI = 'https://github.com/PowerShell/PowerShell/releases'
    $latestRelease = (Invoke-WebRequest -Uri "$releaseURI/latest" -UseBasicParsing -Headers @{'Accept'='application/json'}| ConvertFrom-Json).update_url
    $versionString = $latestRelease -replace '.*tag/(.*)', '$1'
    $links = (Invoke-WebRequest -Uri "$releaseURI/expanded_assets/$($versionString)" -UseBasicParsing).Links.href
    $fileUri = 'https://github.com' + ($links | Select-String -Pattern '.*x64.zip' | Get-Unique).Tostring().Trim()
    $pwsh7Root = Join-Path $Pwsh7ForPipKernelPath 'Latest'
    Invoke-WebRequest -uri $fileUri -UseBasicParsing -OutFile (Join-Path $WorkingFolder 'pwsh.zip') -Verbose
    $pwsh7Ver = $fileUri -replace ".*Powershell-(7.*(\d+\.)?(\*|\d+).*)\.zip",'$1'
}

if ($InstallDotnetInteractive) {
    Write-Verbose 'Downloading latest .NET Core SDK...'
    $links = (Invoke-WebRequest -uri 'https://dotnet.microsoft.com/download' -UseBasicParsing).Links.href
    $latestVer = (($links | Select-String -Pattern '.*sdk.*windows-x64-installer') -replace '.*sdk-(([0-9]+\.){1}[0-9]+(\.[0-9]+)?)-.*', '$1' | Measure-Object -Maximum).Maximum
    $latestUri = 'https://dotnet.microsoft.com' + ($links | Select-String -Pattern ".*sdk-$latestVer-windows-x64-installer" | Get-Unique).Tostring().Trim()
    $fileUri = ((Invoke-WebRequest -uri $latestUri -UseBasicParsing).Links.href | Select-String -Pattern '.*\.exe' | Get-Unique).Tostring().Trim()
    Invoke-WebRequest -uri $fileUri -UseBasicParsing -OutFile (Join-Path $WorkingFolder 'dotnet.exe') -Verbose
}
elseif ($InstallPwsh7SDK) {
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

Write-Verbose 'Installing WinPython...'
New-Item -Path $WinPythonPath -ItemType Directory -Force
Start-Process -FilePath (Join-Path $WorkingFolder 'Winpython.exe') -ArgumentList ('-y -o"' + $WinPythonPath + '"') -wait
$wpRoot = (Join-Path $WinPythonPath 'Latest')
New-Item -ItemType SymbolicLink -Path $wpRoot -Target (Join-Path $WinPythonPath "WPy$osBits-$($wpVer -replace('\.',''))") -Force

$kernelPath = Join-Path $wpRoot '\settings\kernels'
if ($CleanupDownloadFiles) {
    Start-Sleep -Seconds 5
    Remove-Item (Join-Path $WorkingFolder 'Winpython.exe') -Force
}

Write-Verbose 'Installing Node.js...'
New-Item -Path $NodePath -ItemType Directory -Force
Expand-Archive -Path (Join-Path $WorkingFolder '\node.zip') -DestinationPath $NodePath -Force
[Reflection.Assembly]::LoadWithPartialName('System.IO.Compression.FileSystem')
$zipFile = [IO.Compression.ZipFile]::OpenRead("$(Join-Path $WorkingFolder '\node.zip')")
$nodeFolder = $zipFile.Entries[0].FullName -replace('/','')
$zipFile.Dispose()
$nodeEnvPath = join-path $nodePath 'Latest'
New-Item -ItemType SymbolicLink -Path $nodeEnvPath -Target (join-path $nodePath $nodeFolder) -Force
. (join-path $nodeEnvPath "nodevars.bat")
$env:Path += (';' + $nodeEnvPath)
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
    Write-Verbose 'Installing PortableGit...'
    New-Item -Path $PortableGitPath -ItemType Directory -Force
    Start-Process -FilePath (Join-Path $WorkingFolder 'PortableGit.exe') -ArgumentList ('-y -o"' + $PortableGitPath + '"') -wait
    $gitEnvPath = Join-Path $PortableGitPath 'cmd'
    if ($CleanupDownloadFiles) {
        Start-Sleep -Seconds 5
        Remove-Item (Join-Path $WorkingFolder 'PortableGit.exe') -Force
    }
    $env:Path += ";$gitEnvPath"
@"
set GITPATH=$gitEnvPath
echo ";%PATH%;" | %FINDDIR%\find.exe /C /I ";%GITPATH%\;" >nul
if %ERRORLEVEL% NEQ 0 (
    set "PATH=%PATH%;%GITPATH%\;"
)

"@ | Add-Content -Path "$wpRoot\scripts\env.bat"    
}

Write-Verbose 'Installing Jupyter...'
& "$wpRoot\scripts\env_for_icons.bat"
. "$wpRoot\scripts\WinPython_PS_Prompt.ps1"
pip install --upgrade pip
pip install --upgrade wheel
pip install jupyter
pip install notebook
pip install jupyterlab
if ($InstallNBExtensions) {
    pip install jupyter_nbextensions_configurator
    jupyter nbextensions_configurator enable
    pip install https://github.com/ipython-contrib/jupyter_contrib_nbextensions/tarball/master
    jupyter contrib nbextension install --sys-prefix
}
if ($InstallNIIExtensions) {
    pip install git+https://github.com/NII-cloud-operation/Jupyter-LC_run_through
    pip install git+https://github.com/NII-cloud-operation/Jupyter-LC_wrapper
    pip install git+https://github.com/NII-cloud-operation/Jupyter-multi_outputs
    pip install git+https://github.com/NII-cloud-operation/Jupyter-LC_index
    pip install git+https://github.com/NII-cloud-operation/Jupyter-LC_notebook_diff
    pip install git+https://github.com/NII-cloud-operation/sidestickies
    pip install git+https://github.com/NII-cloud-operation/nbsearch
    pip install git+https://github.com/NII-cloud-operation/Jupyter-LC_nblineage
    if ($InstallNBExtensions) {
        jupyter nbextension install --py lc_run_through --sys-prefix
        jupyter nbextension install --py lc_wrapper --sys-prefix
        jupyter nbextension install --py lc_multi_outputs --sys-prefix
        jupyter nbextension install --py notebook_index --sys-prefix
        jupyter nbextension install --py lc_notebook_diff --sys-prefix
        jupyter nbextension install --py nbtags --sys-prefix
        jupyter nbextension install --py nbsearch --sys-prefix
        jupyter nbextension install --py nblineage --sys-prefix
    }
}

if ($UsePipKernel) {
    pip install powershell_kernel
    python -m powershell_kernel.install
    $fileContent = Get-Content "$env:WINPYDIR\Lib\site-packages\powershell_kernel\powershell_proxy.py" -Raw
    $fileContent = $filecontent -replace '\^','\a'
    $filecontent | Set-Content "$env:WINPYDIR\Lib\site-packages\powershell_kernel\powershell_proxy.py" -Force
    if ($InstallPwsh7ForPipKernel) {
        Write-Verbose 'Installing PowerShell 7...'
        Expand-Archive -Path (Join-Path $WorkingFolder 'pwsh.zip') -DestinationPath (Join-Path $Pwsh7ForPipKernelPath $pwsh7Ver) -Force
        New-Item -ItemType SymbolicLink -Path $pwsh7Root -Target (Join-Path $Pwsh7ForPipKernelPath $pwsh7Ver) -Force
        Set-Content -Value "@`"$pwsh7Root\pwsh.exe`" %*" -Path "$env:WINPYDIR\pwsh.cmd"
        Copy-Item -Path "$kernelPath\powershell" -Destination "$kernelPath\powershell7" -Recurse -Force
        $fileContent = Get-Content "$kernelPath\powershell7\kernel.json" -Raw
        $fileContent = $filecontent -replace '"display_name": "[^"]*"','"display_name": "PowerShell 7"'
        $fileContent = $filecontent -replace '"powershell_command": "[^"]*"',"`"powershell_command`": `"pwsh.exe`""
        $filecontent | Set-Content "$kernelPath\powershell7\kernel.json"
        if ($CleanupDownloadFiles) {
            Start-Sleep -Seconds 5
            Remove-Item (Join-Path $WorkingFolder 'pwsh.zip') -Force
        }
    }
}
else {
    $packagePath = Join-Path $wpRoot (Get-ChildItem $wpRoot -Filter "python-$WinPythonVersion*" -Name) | Join-Path -ChildPath '\Lib\site-packages'
    Write-Verbose 'Installing DeepAQ pwsh5 Kernel...'
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
    if ($CleanupDownloadFiles) {
        Remove-Item (Join-Path $WorkingFolder 'PowerShell5.zip') -Force
    }
}
if ($InstallPwsh7SDK) {
    $packagePath = Join-Path $wpRoot (Get-ChildItem $wpRoot -Filter "python-$WinPythonVersion*" -Name) | Join-Path -ChildPath '\Lib\site-packages'
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
    Write-Verbose 'Installing .NET SDK...'
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
    Write-Verbose 'Installing .NET Runtime...'
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

Pop-Location
Write-Host 'Done, It may require reboot to some function(s).' -ForegroundColor Green