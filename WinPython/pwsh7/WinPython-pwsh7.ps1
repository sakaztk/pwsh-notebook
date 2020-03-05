$ErrorActionPreference = 'Stop'
. (join-path (Get-Item $PSScriptRoot).Parent.FullName 'Definition.ps1')

# WinPython
New-Item -Path $wpPath -ItemType Directory -Force
Invoke-WebRequest -Uri "https://github.com/winpython/winpython/releases/download/2.2.20191222/Winpython$wpVer.exe" -OutFile "$wpPath\Winpython.exe"
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

# PowerShell7
$pwsh7Root = Join-Path $pwsh7Path $pwsh7Ver
New-Item -Path "$pwsh7Root" -ItemType Directory -Force
Invoke-WebRequest -Uri "https://github.com/PowerShell/PowerShell/releases/download/v$($pwsh7Ver -Replace('-win.*',''))/PowerShell-$pwsh7Ver.zip" -OutFile "$pwsh7Path\pwsh7.zip"
Expand-Archive -Path "$pwsh7Path\pwsh7.zip" -DestinationPath $pwsh7Root -Force
Remove-Item "$pwsh7Path\pwsh7.zip"
Set-Content -Value "@`"$pwsh7Root\pwsh.exe`" %*" -Path "$env:WINPYDIR\pwsh-preview.cmd"
Set-Content -Value "@`"$pwsh7Root\pwsh.exe`" %*" -Path "$env:WINPYDIR\pwsh.cmd"
Copy-Item -Path "$wpRoot\settings\kernels\powershell" -Destination "$wpRoot\settings\kernels\powershell7" -Recurse
$fileContent = Get-Content "$wpRoot\settings\kernels\powershell7\kernel.json" -Raw
$fileContent = $filecontent -replace '"display_name": "[^"]*"','"display_name": "PowerShell 7"'
$fileContent = $filecontent -replace '"powershell_command": "[^"]*"',"`"powershell_command`": `"$($pwsh7Root -replace '\\','\\')\\pwsh.exe`""
$filecontent | Set-Content "$wpRoot\settings\kernels\powershell7\kernel.json"

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
