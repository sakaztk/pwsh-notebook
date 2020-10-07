$ErrorActionPreference = 'Stop'

# Miniconda
$uri = 'https://repo.anaconda.com/miniconda/Miniconda3-latest-Windows-x86_64.exe'
$opt = '/InstallationType=JustMe /AddToPath=0 /RegisterPython=1 /NoRegistru=0 /Noscripts=o /S'
Invoke-WebRequest -Uri $uri -OutFile "miniconda.exe"
Start-Process -FilePath "miniconda.exe" -ArgumentList $opt -wait
Remove-Item 'miniconda.exe'
& "$env:USERPROFILE\Miniconda3\shell\condabin\conda-hook.ps1"
conda activate

# Node.js
conda install -c conda-forge nodejs -y

# Jupyter
conda install -y jupyter
conda install -y jupyterhub
conda install -y jupyterlab
conda install -y -c conda-forge jupyter_nbextensions_configurator
jupyter nbextensions_configurator enable
pip install https://github.com/ipython-contrib/jupyter_contrib_nbextensions/tarball/master
jupyter contrib nbextension install --user
pip install powershell_kernel
python -m powershell_kernel.install
