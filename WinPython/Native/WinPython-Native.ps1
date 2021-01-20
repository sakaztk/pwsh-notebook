$ErrorActionPreference = 'Stop'
. (join-path (Get-Item $PSScriptRoot).Parent.FullName 'Definition.ps1')
# [Definition.ps1]
# $wpTag    = '3.0.202011219'
# $wpVer    = '64-3.8.7.0dot'
# $pwsh7Ver = '7.1.1-win-x64'
# $nodeVer  = '14.15.4'
# $wpPath    = 'U:\Softwares\WinPython'
# $nodePath  = 'U:\Softwares\node'
# $pwsh7Path = 'U:\Softwares\pwsh7'

# WinPython
New-Item -Path $wpPath -ItemType Directory -Force
Invoke-WebRequest -Uri "https://github.com/winpython/winpython/releases/download/$wpTag/Winpython$wpVer.exe" -OutFile "$wpPath\Winpython.exe"
Start-Process -FilePath "$wpPath\Winpython.exe" -ArgumentList '-y' -wait
Remove-Item "$wpPath\Winpython.exe"
$wpRoot = Join-Path $wpPath "WPy$($wpVer -replace('\.|dot|cod|Ps2',''))"

# Node.js
New-Item -Path $nodePath -ItemType Directory -Force
Invoke-WebRequest -Uri "https://nodejs.org/dist/v$nodeVer/node-v$nodeVer-win-x64.zip" -OutFile "$nodePath\node.zip"
Expand-Archive -Path "$nodePath\node.zip" -DestinationPath $nodePath -Force
Remove-Item "$nodePath\node.zip"
. (join-path $nodePath "node-v$nodeVer-win-x64\nodevars.bat")
$env:Path += (';' + (join-path $nodePath "node-v$nodeVer-win-x64"))

$nodeEnvPath = join-path $nodePath "node-v$nodeVer-win-x64"
@"
set NODEPATH=$nodeEnvPath
echo ";%PATH%;" | %FINDDIR%\find.exe /C /I ";%NODEPATH%\;" >nul
if %ERRORLEVEL% NEQ 0 (
   set "PATH=%PATH%;%NODEPATH%\;"
)

"@ | Add-Content -Path "$wpRoot\scripts\env.bat"

# Jupyter
& "$wpRoot\scripts\env_for_icons.bat"
& "$wpRoot\scripts\WinPython_PS_Prompt.ps1"
pip install jupyter
pip install jupyterhub
pip install jupyterlab
pip install powershell_kernel
pip install jupyter_nbextensions_configurator 
jupyter nbextensions_configurator enable
pip install https://github.com/ipython-contrib/jupyter_contrib_nbextensions/tarball/master
jupyter contrib nbextension install --user
pip install git+https://github.com/NII-cloud-operation/Jupyter-LC_run_through
pip install git+https://github.com/NII-cloud-operation/Jupyter-LC_wrapper
pip install git+https://github.com/NII-cloud-operation/Jupyter-multi_outputs
pip install git+https://github.com/NII-cloud-operation/Jupyter-LC_index
pip install git+https://github.com/NII-cloud-operation/Jupyter-LC_notebook_diff
pip install git+https://github.com/NII-cloud-operation/sidestickies
pip install git+https://github.com/NII-cloud-operation/nbsearch
pip install git+https://github.com/NII-cloud-operation/Jupyter-LC_nblineage
jupyter nbextension install --py lc_run_through --sys-prefix
jupyter nbextension install --py lc_wrapper --sys-prefix
jupyter nbextension install --py lc_multi_outputs --sys-prefix
jupyter nbextension install --py notebook_index --sys-prefix
jupyter nbextension install --py lc_notebook_diff --sys-prefix
jupyter nbextension install --py nbtags --sys-prefix
jupyter nbextension install --py nbsearch --sys-prefix
jupyter nbextension install --py nblineage --sys-prefix
python -m powershell_kernel.install

# Code Page
@(
    "$wpRoot\scripts\env.bat"
) | ForEach-Object {
    $fileContent = Get-Content $_ -Raw
    if ($fileContent -notcontains "chcp 65001") {
        $fileContent = $filecontent -replace "^@echo off", "$&`nchcp 65001"
        $filecontent | Set-Content $_
    }
}
