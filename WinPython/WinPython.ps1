#Requires -Version 5
[CmdletBinding()]
Param(
    [ValidateSet(,'3.8','3.9')]
    [String]$WinPythonVersion = '3.8',
    [ValidateSet('unmarked','dot','cod')]
    [String]$WinPythonType = 'dot',
    [Switch]$InstallPowerShell7,
    [Switch]$InstallDotnetInteractive,
    [Switch]$InstallNBExtensions,
    [Switch]$InstallNIIExtensions,
    [Switch]$InstallPortableGit,
    [Switch]$ReplaceToAndrewguKernel,
    [String]$WinPythonPath = (Join-Path $env:LOCALAPPDATA 'Programs\WinPython'),
    [String]$NodePath = (Join-Path $env:LOCALAPPDATA 'Programs\node'),
    [String]$PowerShell7Path = (Join-Path $env:LOCALAPPDATA 'Programs\pwsh7'),
    [String]$PortableGitPath = (Join-Path $env:LOCALAPPDATA 'Programs\PortableGit'),
    [Switch]$CleanupDownloadFiles,
    [String]$WorkingFolder = $PSScriptRoot
)
$ErrorActionPreference = 'Stop'
Push-Location $WorkingFolder
$osBits = ( [System.IntPtr]::Size*8 ).ToString()
Write-Output '##### WinPython Installation #####'
if ( $WinPythonType = 'unmarked' ) {
    $pattern = $osBits + '-' + $WinPythonVersion + '.*\d\.exe'
}
else {
    $pattern = $osBits + '-' + $WinPythonVersion + '.*' + $WinPythonType + '\.exe'
}
$latestRelease = (Invoke-WebRequest 'https://github.com/winpython/winpython/releases/latest' -UseBasicParsing -Headers @{'Accept'='application/json'}| ConvertFrom-Json).update_url
$links = (Invoke-WebRequest -uri "https://github.com$($latestRelease)" -UseBasicParsing).Links.href
$fileUri = ($links | Select-String -Pattern $pattern | Get-Unique).Tostring().Trim()
$progressPreference = 'SilentlyContinue'
Write-Output 'Downloading Winpython...'
Invoke-WebRequest -uri "https://github.com$($fileUri)" -OutFile (Join-Path $WorkingFolder 'Winpython.exe') -Verbose
$progressPreference = 'Continue'
New-Item -Path $WinPythonPath -ItemType Directory -Force
Start-Process -FilePath (Join-Path $WorkingFolder 'Winpython.exe') -ArgumentList ('-y -o"' + $WinPythonPath + '"') -wait
$wpVer = $fileUri -replace ".*-((\d+\.)?(\d+\.)?(\d+\.)?(\*|\d+)).*\.exe",'$1'
$wpRoot = Join-Path $WinPythonPath "WPy$osBits-$($wpVer -replace('\.',''))"
$kernelPath = Join-Path $wpRoot '\settings\kernels'
if ( $CleanupDownloadFiles ) {
    Start-Sleep -Seconds 5
    Remove-Item (Join-Path $WorkingFolder 'Winpython.exe') -Force
}

Write-Output '##### Node.js Installation #####'
$links = (Invoke-WebRequest -uri 'https://nodejs.org/ja/download/' -UseBasicParsing).Links.href
$pattern = "win-x$osBits.*\.zip"
$fileUri = ($links | Select-String -Pattern $pattern | Get-Unique).Tostring().Trim()
$progressPreference = 'SilentlyContinue'
Invoke-WebRequest -Uri $fileUri -OutFile (Join-Path $WorkingFolder '\node.zip')
$progressPreference = 'Continue'
New-Item -Path $NodePath -ItemType Directory -Force
Expand-Archive -Path (Join-Path $WorkingFolder '\node.zip') -DestinationPath $NodePath -Force
[Reflection.Assembly]::LoadWithPartialName('System.IO.Compression.FileSystem') > $null
$nodeFolder = [IO.Compression.ZipFile]::OpenRead("$(Join-Path $WorkingFolder '\node.zip')").Entries[0].FullName -replace('/','')
. (join-path $NodePath "$nodeFolder\nodevars.bat")
$env:Path += (';' + (join-path $nodePath "node-v$nodeVer-win-x64"))
$nodeEnvPath = join-path $nodePath $nodeFolder
@"
set NODEPATH=$nodeEnvPath
echo ";%PATH%;" | %FINDDIR%\find.exe /C /I ";%NODEPATH%\;" >nul
if %ERRORLEVEL% NEQ 0 (
   set "PATH=%PATH%;%NODEPATH%\;"
)

"@ | Add-Content -Path "$wpRoot\scripts\env.bat"

if ( $CleanupDownloadFiles -and $downloaded ) {
    Start-Sleep -Seconds 5
    Remove-Item (Join-Path $WorkingFolder '\node.zip') -Force
}

if ( $InstallPortableGit ) {
    Write-Output '##### PortableGit Installation #####'
    $latestRelease = (Invoke-WebRequest 'https://github.com/git-for-windows/git/releases/latest' -UseBasicParsing -Headers @{'Accept'='application/json'}| ConvertFrom-Json).update_url
    $links = (Invoke-WebRequest -uri "https://github.com$($latestRelease)" -UseBasicParsing).Links.href
    $fileUri = ($links | Select-String -Pattern ".*PortableGit.*$osBits.*\.exe" | Get-Unique).Tostring().Trim()
    $progressPreference = 'SilentlyContinue'
    Write-Output 'Downloading PortableGit...'
    Invoke-WebRequest -uri "https://github.com$($fileUri)" -OutFile (Join-Path $WorkingFolder 'PortableGit.exe') -Verbose
    $progressPreference = 'Continue'
    New-Item -Path $PortableGitPath -ItemType Directory -Force
    Start-Process -FilePath (Join-Path $WorkingFolder 'PortableGit.exe') -ArgumentList ('-y -o"' + $PortableGitPath + '"') -wait
    $gitEnvPath = Join-Path $PortableGitPath 'cmd'
    if ( $CleanupDownloadFiles ) {
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

Write-Output '##### Jupyter Installation #####'
& "$wpRoot\scripts\env_for_icons.bat"
. "$wpRoot\scripts\WinPython_PS_Prompt.ps1"
pip install jupyter
pip install jupyterhub
pip install jupyterlab
pip install powershell_kernel
python -m powershell_kernel.install

if ( $ReplaceToAndrewguKernel ) {
    Rename-Item -Path (Join-Path $env:WINPYDIR 'Lib\site-packages\powershell_kernel\powershell_proxy.py') -NewName 'powershell_proxy.py.org' -Force
    Invoke-WebRequest -UseBasicParsing `
        -Uri 'https://raw.githubusercontent.com/andrewgu/jupyter-powershell/master/powershell_kernel/powershell_proxy.py' `
        -OutFile (Join-Path $env:WINPYDIR 'Lib\site-packages\powershell_kernel\powershell_proxy.py')
}
if ( $InstallNBExtensions ) {
    pip install jupyter_nbextensions_configurator
    jupyter nbextensions_configurator enable
    pip install https://github.com/ipython-contrib/jupyter_contrib_nbextensions/tarball/master
    jupyter contrib nbextension install --sys-prefix
}
if ( $InstallNIIExtensions ) {
    pip install git+https://github.com/NII-cloud-operation/Jupyter-LC_run_through
    pip install git+https://github.com/NII-cloud-operation/Jupyter-LC_wrapper
    pip install git+https://github.com/NII-cloud-operation/Jupyter-multi_outputs
    pip install git+https://github.com/NII-cloud-operation/Jupyter-LC_index
    pip install git+https://github.com/NII-cloud-operation/Jupyter-LC_notebook_diff
    pip install git+https://github.com/NII-cloud-operation/sidestickies
    pip install git+https://github.com/NII-cloud-operation/nbsearch
    pip install git+https://github.com/NII-cloud-operation/Jupyter-LC_nblineage
    if ( $InstallNBExtensions ) {
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

if ( $InstallPowerShell7 ) {
    Write-Output '##### PowerShell 7 Installation #####'
    $latestRelease = (Invoke-WebRequest -Uri 'https://github.com/PowerShell/PowerShell/releases/latest' -UseBasicParsing -Headers @{'Accept'='application/json'}| ConvertFrom-Json).update_url
    $links = (Invoke-WebRequest -Uri "https://github.com$($latestRelease)" -UseBasicParsing).Links.href
    $fileUri = 'https://github.com' + ( $links | Select-String -Pattern '.*x64.zip' | Get-Unique).Tostring().Trim()
    $pwsh7Ver = $fileUri -replace ".*Powershell-(7.*(\d+\.)?(\*|\d+).*)\.zip",'$1'
    $pwsh7Root = Join-Path $PowerShell7Path $pwsh7Ver
    $progressPreference = 'silentlyContinue'
    Write-Output 'Downloading latest PowerShell 7...'
    Invoke-WebRequest -uri $fileUri -UseBasicParsing  -OutFile (Join-Path $WorkingFolder 'pwsh.zip') -Verbose
    $progressPreference = 'Continue'
    Write-Output 'Installing PowerShell 7...'
    Expand-Archive -Path (Join-Path $WorkingFolder 'pwsh.zip') -DestinationPath $pwsh7Root -Force
    Set-Content -Value "@`"$pwsh7Root\pwsh.exe`" %*" -Path "$env:WINPYDIR\pwsh.cmd"
    Copy-Item -Path "$kernelPath\powershell" -Destination "$kernelPath\powershell7" -Recurse -Force
    $fileContent = Get-Content "$kernelPath\powershell7\kernel.json" -Raw
    $fileContent = $filecontent -replace '"display_name": "[^"]*"','"display_name": "PowerShell 7"'
    $fileContent = $filecontent -replace '"powershell_command": "[^"]*"',"`"powershell_command`": `"pwsh.exe`""
    $filecontent | Set-Content "$kernelPath\powershell7\kernel.json"
    if ( $CleanupDownloadFiles -and $downloaded ) {
        Start-Sleep -Seconds 5
        Remove-Item (Join-Path $WorkingFolder 'pwsh.zip') -Force
    }

}

if ( $InstallDotnetInteractive ) {
    Write-Output '##### .Net Interactive Installation #####'
    $links = (Invoke-WebRequest -uri 'https://dotnet.microsoft.com/download' -UseBasicParsing).Links.href
    $latestVer = (($links | Select-String -Pattern '.*sdk.*windows-x64-installer') -replace '.*sdk-(([0-9]+\.){1}[0-9]+(\.[0-9]+)?)-.*', '$1' | Measure-Object -Maximum).Maximum
    $latestUri = 'https://dotnet.microsoft.com' + ($links | Select-String -Pattern ".*sdk-$latestVer-windows-x64-installer" | Get-Unique).Tostring().Trim()
    $fileUri = ((Invoke-WebRequest -uri $latestUri -UseBasicParsing).Links.href | Select-String -Pattern '.*\.exe' | Get-Unique).Tostring().Trim()
    Write-Output 'Downloading latest .NET Core SDK...'
    $progressPreference = 'SilentlyContinue'
    Invoke-WebRequest -uri $fileUri -UseBasicParsing  -OutFile (Join-Path $WorkingFolder 'dotnet.exe') -Verbose
    $progressPreference = 'Continue'
    Write-Output 'Installing .NET Core SDK...'
    Start-Process -FilePath (Join-Path $WorkingFolder 'dotnet.exe') -ArgumentList '/install /passive /norestart' -Wait
    Write-Output 'Installing .NET Interactive...'
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    dotnet tool install -g --add-source "https://pkgs.dev.azure.com/dnceng/public/_packaging/dotnet-tools/nuget/v3/index.json" Microsoft.dotnet-interactive
    dotnet interactive jupyter install --path "$kernelPath"
    if ( $CleanupDownloadFiles -and $downloaded ) {
        Start-Sleep -Seconds 5
        Remove-Item (Join-Path $WorkingFolder 'dotnet.exe') -Force
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
