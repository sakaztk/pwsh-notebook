$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"

# Anaconda
$uri = 'https://repo.anaconda.com/archive/Anaconda3-2020.11-Windows-x86_64.exe'
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
