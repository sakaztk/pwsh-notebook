# WinPython
Using [Powershell](https://github.com/PowerShell/PowerShell) on [Jupyter Notebook](https://jupyter.org/) on [WinPython](https://winpython.github.io/).  

## インストールするソフトウェア
- [WinPython](https://winpython.github.io/)
- [Jupyter-PowerShell5](https://github.com/DeepAQ/Jupyter-PowerShell5)
- [Jupyter-PowerShellSDK](https://github.com/sakaztk/Jupyter-PowerShellSDK) (Optional)
- [Jupyter Powershell Kernel](https://github.com/vors/jupyter-powershell) (Optional)
- [Node.js](https://nodejs.org/) (Use in extentions for JupyterLab)
- [PowerShell 7](https://github.com/PowerShell/PowerShell) (Optional)
- [Jupyter Nbextensions](https://github.com/ipython-contrib/jupyter_contrib_nbextensions) (Optional)
- [Jupyter Nbextensions Configurator](https://github.com/Jupyter-contrib/jupyter_nbextensions_configurator) (Optional)
- [PortableGit](https://github.com/git-for-windows/git) (Optional)
- [NII Extensions for Jupyter Notebook](https://github.com/NII-cloud-operation) (Optional)
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

- UsePipKernel  
このスイッチオプションを指定すると、[Jupyter-PowerShell5](https://github.com/DeepAQ/Jupyter-PowerShell5)の代わりに[Jupyter Powershell Kernel](https://github.com/vors/jupyter-powershell)を使用します。  
例: .\WinPython.ps1 -UsePipKernel

- InstallPwsh7ForPipKernel  
このスイッチオプションを指定すると、最新版の[PowerShell 7](https://github.com/PowerShell/PowerShell/releases/latest)をインストールし、[Jupyter Powershell Kernel](https://github.com/vors/jupyter-powershell)で使用可能にします。  
例: .\WinPython.ps1 -UsePipKernel -InstallPwsh7ForPipKernel

- PowerShell7Path  
[PowerShell 7](https://github.com/PowerShell/PowerShell/releases/latest)のインストールパスを指定します。  
必須: いいえ  
デフォルト: $env:LOCALAPPDATA\Programs\WinPython\pwsh7  
例: .\WinPython.ps1 -InstallPwsh7ForPipKernel -PowerShell7Path C:\PathTo\WinPython

- InstallNBExtensions  
This switch option will install [Jupyter Nbextensions](https://github.com/ipython-contrib/jupyter_contrib_nbextensions) and [Jupyter Nbextensions Configurator](https://github.com/Jupyter-contrib/jupyter_nbextensions_configurator).  
例: .\WinPython.ps1 -InstallNBExtensions

- InstallNIIExtensions  
このスイッチオプションを指定すると、 [Jupyter Nbextensions](https://github.com/ipython-contrib/jupyter_contrib_nbextensions) と [Jupyter Nbextensions Configurator](https://github.com/Jupyter-contrib/jupyter_nbextensions_configurator)をインストールします。  
例: .\WinPython.ps1 -InstallNIIExtensions

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