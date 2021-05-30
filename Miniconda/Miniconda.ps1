#Requires -Version 5
[CmdletBinding()]
Param(
    [String]$InstallationType = 'Computer',
    [Switch]$InstallPowerShell7,
    [Switch]$InstallDotnetInteractive,
    [Switch]$InstallNBExtensions,
    [Switch]$InstallNIIExtensions,
    [Switch]$ReplaceToAndrewguVersion,
    [Switch]$CleanupDownloadFiles,
    [String]$WorkingFolder = $PSScriptRoot
)
$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = 'tls12, tls11, tls'
Push-Location $WorkingFolder
$psBoundParameters.Keys | ForEach-Object {
    if ($($PSBoundParameters.$_.GetType().Name) -eq 'SwitchParameter') {
        $paramStrings += " -$_"
    }
    else {
        $paramStrings += " -$_ $($PSBoundParameters.$_)"
    }
}
Write-Verbose "Commandline: `"$PSCommandPath`"$paramStrings"
switch ($installationType) {
    { @('system', 'computer', 'allusers') -contains $_ } {
        if (-not([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
            Write-Verbose 'Relaunch script with admin privileges...'
            Start-Process powershell.exe "-NoExit -ExecutionPolicy Bypass -Command `"$PSCommandPath`" $paramStrings" -Verb RunAs
            exit
        }
        $condaOpt = '/InstallationType=AllUsers /AddToPath=0 /RegisterPython=1 /NoRegistru=0 /Noscripts=o /S'
        $dataPath = "$env:ProgramData"
        $kernelPath = "$env:ProgramData\Miniconda3\share\jupyter\kernels"
        $pyTypeOpt = '--sys-prefix'
        [System.Environment]::SetEnvironmentVariable('PYTHONUTF8',1,[System.EnvironmentVariableTarget]::Machine)
    }
    { @('user', 'justme') -contains $_ } {
        $condaOpt = '/InstallationType=JustMe /AddToPath=0 /RegisterPython=1 /NoRegistru=0 /Noscripts=o /S'
        $dataPath = $env:UserProfile
        $kernelPath = "$env:AppData\jupyter\kernels"
        $pyTypeOpt = '--user'
        [System.Environment]::SetEnvironmentVariable('PYTHONUTF8',1,[System.EnvironmentVariableTarget]::User)
    }
    default {
        Write-Error 'Unexpected option.'
    }
}
Write-Output '##### Miniconda Installation #####'
if ( Test-Path 'miniconda.exe' ) {
    Write-Output 'Use existing miniconda.exe.'
}
else {
    Write-Output 'Downloading latest Miniconda...'
    $progressPreference = 'silentlyContinue'
    $fileUri = 'https://repo.anaconda.com/miniconda/Miniconda3-latest-Windows-x86_64.exe'
    Invoke-WebRequest -Uri $fileUri -UseBasicParsing -OutFile (Join-Path $WorkingFolder 'miniconda.exe') -Verbose
    $progressPreference = 'Continue'
    $downloaded = $true
}
Write-Output 'Installing Miniconda...'
$process = Start-Process -FilePath 'miniconda.exe' -ArgumentList $condaOpt -PassThru
for($i = 0; $i -le 100; $i = ($i + 1) % 100) {
    Write-Progress -Activity 'Installer' -PercentComplete $i -Status 'Installing...'
    Start-Sleep -Seconds 1
    if ($process.HasExited) {
        Write-Progress -Activity 'Installer' -Completed
        break
    }
}
if ( $CleanupDownloadFiles -and $downloaded ) {
    Start-Sleep -Seconds 5
    Remove-Item 'miniconda.exe' -Force
}
& "$dataPath\Miniconda3\shell\condabin\conda-hook.ps1"
conda activate
Write-Output '##### Jupyter Installation #####'
conda install -y jupyter
conda install -y jupyterlab
conda install -y -c conda-forge nodejs
pip install powershell_kernel
python -m powershell_kernel.install $pyTypeOpt

if ( $ReplaceToAndrewguKernel ) {
    Rename-Item -Path (Join-Path $env:WINPYDIR 'Lib\site-packages\powershell_kernel\powershell_proxy.py') -NewName 'powershell_proxy.py.org' -Force
    Invoke-WebRequest -UseBasicParsing `
        -Uri 'https://raw.githubusercontent.com/andrewgu/jupyter-powershell/master/powershell_kernel/powershell_proxy.py' `
        -OutFile (Join-Path $env:WINPYDIR 'Lib\site-packages\powershell_kernel\powershell_proxy.py')
}
if ( $InstallNBExtensions ) {
    conda install -y -c conda-forge jupyter_nbextensions_configurator
    jupyter nbextensions_configurator enable
    pip install https://github.com/ipython-contrib/jupyter_contrib_nbextensions/tarball/master
    jupyter contrib nbextension install $pyTypeOpt    
}
if ( $InstallNIIExtensions ) {
    conda install -y git
    pip install git+https://github.com/NII-cloud-operation/Jupyter-LC_run_through
    pip install git+https://github.com/NII-cloud-operation/Jupyter-LC_wrapper
    pip install git+https://github.com/NII-cloud-operation/Jupyter-multi_outputs
    pip install git+https://github.com/NII-cloud-operation/Jupyter-LC_index
    pip install git+https://github.com/NII-cloud-operation/Jupyter-LC_notebook_diff
    pip install git+https://github.com/NII-cloud-operation/sidestickies
    pip install git+https://github.com/NII-cloud-operation/nbsearch
    pip install git+https://github.com/NII-cloud-operation/Jupyter-LC_nblineage
    if ( $InstallNBExtensions ) {
        jupyter nbextension install --py lc_run_through $pyTypeOpt
        jupyter nbextension install --py lc_wrapper $pyTypeOpt
        jupyter nbextension install --py lc_multi_outputs $pyTypeOpt
        jupyter nbextension install --py notebook_index $pyTypeOpt
        jupyter nbextension install --py lc_notebook_diff $pyTypeOpt
        jupyter nbextension install --py nbtags $pyTypeOpt
        jupyter nbextension install --py nbsearch $pyTypeOpt
        jupyter nbextension install --py nblineage $pyTypeOpt
    }
}
if ( $InstallPowerShell7 ) {
    Write-Output '##### PowerShell 7 Installation #####'
    if ( Test-Path 'pwsh.msi' ) {
        Write-Output 'Use existing pwsh.msi.'
        $downloaded = $false
    }
    else {
        Write-Output 'Downloading latest PowerShell 7...'
        $progressPreference = 'silentlyContinue'
        $latestRelease = (Invoke-WebRequest -Uri 'https://github.com/PowerShell/PowerShell/releases/latest' -UseBasicParsing -Headers @{'Accept'='application/json'}| ConvertFrom-Json).update_url
        $links = (Invoke-WebRequest -Uri "https://github.com$($latestRelease)" -UseBasicParsing).Links.href
        $fileUri = 'https://github.com' + ( $links | Select-String -Pattern '.*x64.msi' | Get-Unique).Tostring().Trim()
        Write-Verbose "Download from $fileUri"
        Invoke-WebRequest -Uri $fileUri -UseBasicParsing  -OutFile (Join-Path $WorkingFolder 'pwsh.msi') -Verbose
        $progressPreference = 'Continue'
        $downloaded = $true
    }
    Write-Output 'Installing PowerShell 7...'
    Start-Process -FilePath 'pwsh.msi' -ArgumentList '/passive' -Wait
    Copy-Item -Path "$kernelPath\powershell" -Destination "$kernelPath\powershell7" -Recurse -Force
    $fileContent = Get-Content "$kernelPath\powershell7\kernel.json" -Raw
    $fileContent = $filecontent -replace '"display_name": "[^"]*"','"display_name": "PowerShell 7"'
    $fileContent = $filecontent -replace '"powershell_command": "[^"]*"',"`"powershell_command`": `"pwsh.exe`""
    $filecontent | Set-Content "$kernelPath\powershell7\kernel.json"
    if ( $CleanupDownloadFiles -and $downloaded ) {
        Start-Sleep -Seconds 5
        Remove-Item 'pwsh.msi' -Force
    }
}
if ( $InstallDotnetInteractive ) {
    Write-Output '##### PowerShell .Net Interactive #####'
    if ( Test-Path 'dotnet.exe' ) {
        Write-Output 'Use existing dotnet.exe.'
        $downloaded = $false
    }
    else {
        Write-Output 'Downloading latest .NET Core SDK...'
        $progressPreference = 'silentlyContinue'
        $links = (Invoke-WebRequest -Uri 'https://dotnet.microsoft.com/download' -UseBasicParsing).Links.href
        $latestVer = (($links | Select-String -Pattern '.*sdk.*windows-x64-installer') -replace '.*sdk-(([0-9]+\.){1}[0-9]+(\.[0-9]+)?)-.*', '$1' | Measure-Object -Maximum).Maximum
        $latestUri = 'https://dotnet.microsoft.com' + ($links | Select-String -Pattern ".*sdk-$latestVer-windows-x64-installer" | Get-Unique).Tostring().Trim()
        $fileUri = ((Invoke-WebRequest -Uri $latestUri -UseBasicParsing).Links.href | Select-String -Pattern '.*\.exe' | Get-Unique).Tostring().Trim()
        Invoke-WebRequest -Uri $fileUri -UseBasicParsing  -OutFile (Join-Path $WorkingFolder 'dotnet.exe') -Verbose
        $progressPreference = 'Continue'
    }
    Write-Output 'Installing .NET Core SDK...'
    Start-Process -FilePath 'dotnet.exe' -ArgumentList '/install /passive /norestart' -Wait
    Write-Output 'Installing .NET Interactive...'
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    dotnet tool install -g --add-source "https://pkgs.dev.azure.com/dnceng/public/_packaging/dotnet-tools/nuget/v3/index.json" Microsoft.dotnet-interactive
    dotnet interactive jupyter install --path "$kernelPath"
    if ( $CleanupDownloadFiles -and $downloaded ) {
        Start-Sleep -Seconds 5
        Remove-Item 'dotnet.exe' -Force
    }
}

@(
    "$dataPath\Miniconda3\Scripts\jupyter-notebook-script.py"
) | ForEach-Object {
    $fileContent = Get-Content $_ -Raw
    if ($fileContent -notcontains "chcp 65001") {
        $fileContent = $filecontent -replace "import sys", "$&`nimport os `nos.system('chcp 65001')"
        $filecontent | Set-Content $_
    }
}
Pop-Location
Write-Host 'Done, It may require reboot to some function(s).' -ForegroundColor Green