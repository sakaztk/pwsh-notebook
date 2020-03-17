$ErrorActionPreference = 'Stop'
. (join-path (Get-Item $PSScriptRoot).Parent.FullName 'Definition.ps1')

# WinPython
New-Item -Path $wpPath -ItemType Directory -Force
Invoke-WebRequest -Uri "https://github.com/winpython/winpython/releases/download/$wpTag/Winpython$wpVer.exe" -OutFile "$wpPath\Winpython.exe"
Start-Process -FilePath "$wpPath\Winpython.exe" -ArgumentList '-y' -wait
Remove-Item "$wpPath\Winpython.exe"
$wpRoot = Join-Path $wpPath "WPy$($wpVer -replace('\.|dot|cod|Ps2',''))"

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
python -m powershell_kernel.install

$fileContent = Get-Content "$env:WINPYDIR\Lib\site-packages\powershell_kernel\powershell_proxy.py" -Raw
$fileContent = $filecontent -replace '\^','\a'
$filecontent | Set-Content "$env:WINPYDIR\Lib\site-packages\powershell_kernel\powershell_proxy.py" -Force

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
