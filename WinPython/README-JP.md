# WinPython
Using [Powershell](https://github.com/PowerShell/PowerShell) on [Jupyter Notebook](https://jupyter.org/) on [WinPython](https://winpython.github.io/).  

## インストールするソフトウェア
- [WinPython](https://winpython.github.io/)
- [Node.js](https://nodejs.org/) (Use in extentions for JupyterLab)
- [Jupyter-PowerShell5](https://github.com/sakaztk/Jupyter-PowerShellSDK/tree/powershellsdk/Jupyter-PowerShell5) ([DeepAQ](https://github.com/DeepAQ/Jupyter-PowerShell5)からフォーク)
- [Jupyter-PowerShellSDK](https://github.com/sakaztk/Jupyter-PowerShellSDK) (Optional)
- [PortableGit](https://github.com/git-for-windows/git) (Optional)
- [.Net Interactive](https://github.com/dotnet/interactive) (Optional)

## インストール方法
.\WinPython.ps1 [スクリプトオプション]

## スクリプトオプション
- WinPythonVersion  
[WinPython](https://winpython.github.io/)のバージョンを指定します。  
必須: いいえ  
デフォルト: 3.9  
例: .\WinPython.ps1 -WinPythonVersion 3.10  

- WinPythonType  
[WinPython](https://winpython.github.io/)タイプを指定します。  
必須: いいえ  
デフォルト: dot 
例: .\WinPython.ps1 -WinPythonType cod

- WinPythonPath  
[WinPython](https://winpython.github.io/)のインストールパスを指定します。  
必須: いいえ  
デフォルト: $env:LOCALAPPDATA\Programs\WinPython  
例: .\WinPython.ps1 -WinPythonPath C:\PathTo\WinPython

- InstallPwsh7SDK  
このスイッチオプションを指定すると、 [Jupyter-PowerShellSDK](https://github.com/sakaztk/Jupyter-PowerShellSDK)をインストールします。  
例: .\Anaconda.ps1 -InstallPwsh7SDK

- InstallPortableGit  
このスイッチオプションを指定すると、 [PortableGit](https://github.com/git-for-windows/git)をインストールします。  
例: .\WinPython.ps1 -InstallPortableGit

- InstallDotnetInteractive  
このスイッチオプションを指定すると、 [.Net Interactive](https://github.com/dotnet/interactive)をインストールします。  
例: .\WinPython.ps1 -InstallDotnetInteractive

- PortableGitPath  
[PortableGit](https://github.com/git-for-windows/git)のインストールパスを指定します。  
必須: いいえ  
デフォルト: $env:LOCALAPPDATA\Programs\WinPython\PortableGit  
例: .\WinPython.ps1 -InstallPortableGit -PortableGitPath C:\PathTo\PortableGit

- CleanupDownloadFiles  
このスイッチオプションを指定すると、インストール後にダウンロードしたファイルを削除します。
例: .\WinPython.ps1 -DoNotCleanupDownloadFiles

- WorkingFolder [Folder Path]  
スクリプトで使用する作業フォルダを指定します。  
デフォルト: $PSScriptRoot (このスクリプトと同じフォルダ)  
必須: いいえ  
例: .\WinPython.ps1 -WorkingFolder C:\pathto\folder

- AddStartMenu
このスイッチオプションを指定すると、WinPythonバイナリをWindowsスタートメニューに追加します。  
例: .\WinPython.ps1 -AddStartMenu

## インストール例
``` PowerShell
Set-Location $env:HOMEPATH
Invoke-WebRequest -UseBasicParsing `
    -Uri https://github.com/sakaztk/pwsh-notebook/raw/master/WinPython/WinPython.ps1 `
    -OutFile .\WinPython.ps1
Set-ExecutionPolicy Bypass -Scope Process -Force
.\WinPython.ps1 -CleanupDownloadFiles -WorkingFolder $env:HOMEPATH -AddStartMenu -Verbose
pip install jupyterlab-language-pack-ja-JP
```