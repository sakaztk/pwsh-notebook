#Requires -Version 5
[CmdletBinding()]
Param(
    [String]$InstallationType = 'Computer',
    [Switch]$InstallPowerShell7,
    [Switch]$InstallDotnetInteractive,
    [Switch]$InstallNBExtensions,
    [Switch]$InstallNIIExtensions,
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
        $kernelPath = Join-Path $env:ProgramData '\Miniconda3\share\jupyter\kernels'
        $packagePath = Join-Path $env:ProgramData '\Miniconda3\Lib\site-packages'
        $pyTypeOpt = '--sys-prefix'
        [System.Environment]::SetEnvironmentVariable('PYTHONUTF8',1,[System.EnvironmentVariableTarget]::Machine)
    }
    { @('user', 'justme') -contains $_ } {
        $condaOpt = '/InstallationType=JustMe /AddToPath=0 /RegisterPython=1 /NoRegistru=0 /Noscripts=o /S'
        $dataPath = $env:UserProfile
        $kernelPath = Join-Path $env:AppData '\jupyter\kernels'
        $packagePath = Join-Path $env:USERPROFILE '\Miniconda3\Lib\site-packages'
        $pyTypeOpt = '--user'
        [System.Environment]::SetEnvironmentVariable('PYTHONUTF8',1,[System.EnvironmentVariableTarget]::User)
    }
    default {
        Write-Error 'Unexpected option.'
    }
}

$progressPreference = 'silentlyContinue'

Write-Verbose 'Downloading latest Miniconda...'
$fileUri = 'https://repo.anaconda.com/miniconda/Miniconda3-latest-Windows-x86_64.exe'
Invoke-WebRequest -Uri $fileUri -UseBasicParsing -OutFile (Join-Path $WorkingFolder 'miniconda.exe') -Verbose

if ( $InstallPowerShell7 ) {
    Write-Verbose 'Downloading latest PowerShell 7...'
    $latestRelease = (Invoke-WebRequest -Uri 'https://github.com/PowerShell/PowerShell/releases/latest' -UseBasicParsing -Headers @{'Accept'='application/json'}| ConvertFrom-Json).update_url
    $links = (Invoke-WebRequest -Uri "https://github.com$($latestRelease)" -UseBasicParsing).Links.href
    $fileUri = 'https://github.com' + ( $links | Select-String -Pattern '.*x64.msi' | Get-Unique).Tostring().Trim()
    Write-Verbose "Download from $fileUri"
    Invoke-WebRequest -Uri $fileUri -UseBasicParsing  -OutFile (Join-Path $WorkingFolder 'pwsh.msi') -Verbose
}
if ( $InstallDotnetInteractive ) {
    Write-Verbose 'Downloading latest .NET Core SDK...'
    $links = (Invoke-WebRequest -Uri 'https://dotnet.microsoft.com/download' -UseBasicParsing).Links.href
    $latestVer = (($links | Select-String -Pattern '.*sdk.*windows-x64-installer') -replace '.*sdk-(([0-9]+\.){1}[0-9]+(\.[0-9]+)?)-.*', '$1' | Measure-Object -Maximum).Maximum
    $latestUri = 'https://dotnet.microsoft.com' + ($links | Select-String -Pattern ".*sdk-$latestVer-windows-x64-installer" | Get-Unique).Tostring().Trim()
    $fileUri = ((Invoke-WebRequest -Uri $latestUri -UseBasicParsing).Links.href | Select-String -Pattern '.*\.exe' | Get-Unique).Tostring().Trim()
    Invoke-WebRequest -Uri $fileUri -UseBasicParsing  -OutFile (Join-Path $WorkingFolder 'dotnet.exe') -Verbose
}
if ( $InstallDeepAQKernel ) {
    Write-Verbose 'Downloading latest DeepAQ Kernel...'
    $links = (Invoke-WebRequest -Uri 'https://github.com/sakaztk/Jupyter-PowerShell5/releases/tag/Original(Unofficial)' -UseBasicParsing).Links.href
    $fileUri = 'https://github.com' + ( $links | Select-String -Pattern '.*UnofficialOriginalBinaries.zip' | Get-Unique)
    Invoke-WebRequest -uri $fileUri -UseBasicParsing  -OutFile (Join-Path $WorkingFolder 'DeepAQKernel.zip') -Verbose
}

$progressPreference = 'Continue'

Write-Verbose 'Installing Miniconda...'
$process = Start-Process -FilePath 'miniconda.exe' -ArgumentList $condaOpt -PassThru
for($i = 0; $i -le 100; $i = ($i + 1) % 100) {
    Write-Progress -Activity 'Installer' -PercentComplete $i -Status 'Installing...'
    Start-Sleep -Seconds 1
    if ($process.HasExited) {
        Write-Progress -Activity 'Installer' -Completed
        break
    }
}
if ( $CleanupDownloadFiles ) {
    Start-Sleep -Seconds 5
    Remove-Item 'miniconda.exe' -Force
}
& "$dataPath\Miniconda3\shell\condabin\conda-hook.ps1"
conda activate
Write-Verbose '##### Jupyter Installation #####'
conda install -y jupyter
conda install -y jupyterlab
conda install -y -c conda-forge nodejs
pip install powershell_kernel
python -m powershell_kernel.install $pyTypeOpt

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
    Write-Verbose 'Installing PowerShell 7...'
    Start-Process -FilePath 'pwsh.msi' -ArgumentList '/passive' -Wait
    Copy-Item -Path "$kernelPath\powershell" -Destination "$kernelPath\powershell7" -Recurse -Force
    $fileContent = Get-Content "$kernelPath\powershell7\kernel.json" -Raw
    $fileContent = $filecontent -replace '"display_name": "[^"]*"','"display_name": "PowerShell 7"'
    $fileContent = $filecontent -replace '"powershell_command": "[^"]*"',"`"powershell_command`": `"pwsh.exe`""
    $filecontent | Set-Content "$kernelPath\powershell7\kernel.json"
    if ( $CleanupDownloadFiles ) {
        Start-Sleep -Seconds 5
        Remove-Item 'pwsh.msi' -Force
    }
}
if ( $InstallDotnetInteractive ) {
    Write-Verbose 'Installing .NET Core SDK...'
    Start-Process -FilePath 'dotnet.exe' -ArgumentList '/install /passive /norestart' -Wait
    Write-Verbose 'Installing .NET Interactive...'
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    dotnet tool install -g --add-source "https://pkgs.dev.azure.com/dnceng/public/_packaging/dotnet-tools/nuget/v3/index.json" Microsoft.dotnet-interactive
    dotnet interactive jupyter install --path "$kernelPath"
    if ( $CleanupDownloadFiles ) {
        Start-Sleep -Seconds 5
        Remove-Item 'dotnet.exe' -Force
    }
}
if ( $InstallDeepAQKernel ) {
    Write-Verbose 'Installing DeepAQKernel...'
    $installPath = Join-Path $packagePath 'powershell5_kernel'
    Expand-Archive -Path (Join-Path $WorkingFolder 'DeepAQKernel.zip') -DestinationPath $installPath -Force
    New-Item -ItemType Directory -Path (Join-Path $kernelPath '\powershell5\') -Force
@"
{
  "argv": [
    "$($installPath.replace('\','/'))/Jupyter_PowerShell5.exe",
    "{connection_file}"
  ],
  "display_name": "PowerShell (Native)",
  "language": "Powershell"
}
"@ | Set-Content -Path (Join-Path $kernelPath '\powershell5\kernel.json')

    if ( $CleanupDownloadFiles ) {
        Remove-Item (Join-Path $WorkingFolder 'DeepAQKernel.zip') -Force
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