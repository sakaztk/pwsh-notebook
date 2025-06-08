# PythonForWindows
[Python for Windows](https://www.python.org/)を使用して[Jupyter Notebook](https://jupyter.org/)上で[Powershell](https://github.com/PowerShell/PowerShell)を使用する。  

## Installing on this script
- [Python for Windows](https://www.python.org/)
- [Node.js](https://nodejs.org/) (Use in extentions for JupyterLab)
- [Jupyter-PowerShell5](https://github.com/sakaztk/Jupyter-PowerShellSDK/tree/powershellsdk/Jupyter-PowerShell5) ([DeepAQ](https://github.com/DeepAQ/Jupyter-PowerShell5)からフォーク)
- [Jupyter-PowerShellSDK](https://github.com/sakaztk/Jupyter-PowerShellSDK) (オプション)
- [.Net Interactive](https://github.com/dotnet/interactive) (オプション)

## インストール方法
.\WinPython.ps1 [スクリプトオプション]

### スクリプトオプション
- PythonVersion  
Python for Windowsのバージョンを指定します。  
必須: いいえ  
デフォルト: 3.13  
例: .\WinPython.ps1 -PythonVersion 3.12

- InstallPwsh7SDK  
このスイッチオプションを指定すると、 [Jupyter-PowerShellSDK](https://github.com/sakaztk/Jupyter-PowerShellSDK)をインストールします。  
例: .\Anaconda.ps1 -InstallPwsh7SDK

- InstallDotnetInteractive  
このスイッチオプションを指定すると、[.Net Interactive](https://github.com/dotnet/interactive)をインストールします。  
例: .\WinPython.ps1 -InstallDotnetInteractive

- CleanupDownloadFiles  
このスイッチオプションを指定すると、インストール後にダウンロードしたファイルを削除します。  
例: .\WinPython.ps1 -DoNotCleanupDownloadFiles

- WorkingFolder [Folder Path]  
スクリプトで使用する作業フォルダを指定します。  
デフォルト: $PSScriptRoot (このスクリプトと同じフォルダ)  
必須: いいえ  
例: .\WinPython.ps1 -WorkingFolder C:\pathto\folder

## インストール例
``` PowerShell
Set-Location $env:HOMEPATH
Invoke-WebRequest -UseBasicParsing `
    -Uri https://github.com/sakaztk/pwsh-notebook/raw/master/PythonForWindows/PythonForWindows.ps1 `
    -OutFile .\PythonForWindows.ps1
Set-ExecutionPolicy Bypass -Scope Process -Force
.\PythonForWindows.ps1 -CleanupDownloadFiles -WorkingFolder $env:HOMEPATH -Verbose
pip install jupyterlab-language-pack-ja-JP
```