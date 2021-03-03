#Requires -Version 5
$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = 'tls12, tls11, tls'

$installationType = 'Computer'
$cleanupDownloadFiles = $true

switch ($installationType) {
    { @('system', 'computer', 'allusers') -contains $_ } {
        $condaOpt = '/InstallationType=AllUsers /AddToPath=0 /RegisterPython=1 /NoRegistru=0 /Noscripts=o /S'
        $dataPath = "$env:ProgramData"
        $pyTypeOpt = '--sys-prefix'
    }
    { @('user', 'justme') -contains $_ } {
        $condaOpt = '/InstallationType=JustMe /AddToPath=0 /RegisterPython=1 /NoRegistru=0 /Noscripts=o /S'
        $dataPath = "$env:ProgramData"
        $pyTypeOpt = '--user'
    }
    default {
        Write-Error 'Unexpected option.'
    }
}

# Miniconda
if ( Test-Path 'miniconda.exe' ) {
    $uri = 'https://repo.anaconda.com/miniconda/Miniconda3-latest-Windows-x86_64.exe'
    Invoke-WebRequest -Uri $uri -OutFile "miniconda.exe"
}
$process = Start-Process -FilePath 'miniconda.exe' -ArgumentList $condaOpt -PassThru
for($i = 0; $i -le 100; $i = ($i + 1) % 100) {
    Write-Progress -Activity 'Installer' -PercentComplete $i -Status 'Installing Miniconda...'
    Start-Sleep -Seconds 1
    if ($process.HasExited) {
        Write-Progress -Activity 'Installer' -Completed
        break
    }
}
if ( $cleanupDownloadFiles ) { Remove-Item 'miniconda.exe' }
& "$env:ProgramData\Miniconda3\shell\condabin\conda-hook.ps1"
conda activate

# Jupyter
conda install -y -c conda-forge nodejs
conda install -y git
conda install -y jupyter
conda install -y jupyterlab
conda install -y -c conda-forge jupyter_nbextensions_configurator
jupyter nbextensions_configurator enable
pip install https://github.com/ipython-contrib/jupyter_contrib_nbextensions/tarball/master
jupyter contrib nbextension install $pyTypeOpt
pip install powershell_kernel
pip install git+https://github.com/NII-cloud-operation/Jupyter-LC_run_through
pip install git+https://github.com/NII-cloud-operation/Jupyter-LC_wrapper
pip install git+https://github.com/NII-cloud-operation/Jupyter-multi_outputs
pip install git+https://github.com/NII-cloud-operation/Jupyter-LC_index
pip install git+https://github.com/NII-cloud-operation/Jupyter-LC_notebook_diff
pip install git+https://github.com/NII-cloud-operation/sidestickies
pip install git+https://github.com/NII-cloud-operation/nbsearch
pip install git+https://github.com/NII-cloud-operation/Jupyter-LC_nblineage
jupyter nbextension install --py lc_run_through $pyTypeOpt
jupyter nbextension install --py lc_wrapper $pyTypeOpt
jupyter nbextension install --py lc_multi_outputs $pyTypeOpt
jupyter nbextension install --py notebook_index $pyTypeOpt
jupyter nbextension install --py lc_notebook_diff $pyTypeOpt
jupyter nbextension install --py nbtags $pyTypeOpt
jupyter nbextension install --py nbsearch $pyTypeOpt
jupyter nbextension install --py nblineage $pyTypeOpt
python -m powershell_kernel.install $pyTypeOpt

# PowerShell7
if ( Test-Path 'pwsh.msi' ) {
    $uri = 'https://github.com/PowerShell/PowerShell/releases/download/v7.1.1/PowerShell-7.1.1-win-x64.msi'
    Invoke-WebRequest -Uri $uri -OutFile 'pwsh.msi'
}
Start-Process -FilePath 'pwsh.msi' -ArgumentList '/passive' -Wait
Copy-Item -Path "$dataPath\Anaconda3\share\jupyter\kernels\powershell" -Destination "$dataPath\Anaconda3\share\jupyter\kernels\powershell7" -Recurse -Force
$fileContent = Get-Content "$dataPath\Anaconda3\share\jupyter\kernels\powershell7\kernel.json" -Raw
$fileContent = $filecontent -replace '"display_name": "[^"]*"','"display_name": "PowerShell 7"'
$fileContent = $filecontent -replace '"powershell_command": "[^"]*"',"`"powershell_command`": `"pwsh.exe`""
$filecontent | Set-Content "$dataPath\Anaconda3\share\jupyter\kernels\powershell7\kernel.json"
if ( $cleanupDownloadFiles ) { Remove-Item 'pwsh.msi' }

Write-Host 'Done, It may require reboot to some function(s).' -ForegroundColor Yellow
