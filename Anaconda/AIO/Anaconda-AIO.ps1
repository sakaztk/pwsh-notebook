$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"

# Anaconda
$uri = 'https://repo.anaconda.com/archive/Anaconda3-2020.07-Windows-x86_64.exe'
$opt = '/InstallationType=JustMe /AddToPath=0 /RegisterPython=1 /NoRegistru=0 /Noscripts=o /S'
Invoke-WebRequest -Uri $uri -OutFile "anaconda.exe"
Start-Process -FilePath "anaconda.exe" -ArgumentList $opt -wait
Remove-Item 'anaconda.exe'
& "$env:USERPROFILE\Anaconda3\shell\condabin\conda-hook.ps1"
conda activate

# Node.js
conda install -c conda-forge nodejs -y

# Jupyter
conda install -y jupyter
conda install -y jupyterlab
conda install -y -c conda-forge jupyter_nbextensions_configurator
jupyter nbextensions_configurator enable
pip install https://github.com/ipython-contrib/jupyter_contrib_nbextensions/tarball/master
jupyter contrib nbextension install --user
pip install powershell_kernel
python -m powershell_kernel.install

# PowerShell7
$uri = 'https://github.com/PowerShell/PowerShell/releases/download/v7.0.3/PowerShell-7.0.3-win-x64.msi'
Invoke-WebRequest -Uri $uri -OutFile "pwsh.msi"
.\pwsh.msi /passive
Copy-Item -Path "$env:APPDATA\jupyter\kernels\powershell" -Destination "$env:APPDATA\jupyter\kernels\powershell7" -Recurse
$fileContent = Get-Content "$env:APPDATA\jupyter\kernels\powershell7\kernel.json" -Raw
$fileContent = $filecontent -replace '"display_name": "[^"]*"','"display_name": "PowerShell 7"'
$fileContent = $filecontent -replace '"powershell_command": "[^"]*"',"`"powershell_command`": `"pwsh.exe`""
$filecontent | Set-Content "$env:APPDATA\jupyter\kernels\powershell7\kernel.json"
Remove-Item 'pwsh.msi'
