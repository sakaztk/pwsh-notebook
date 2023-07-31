# PythonForWindows
[Python](https://www.python.org/)を使用して[Jupyter Notebook](https://jupyter.org/)上で[Powershell](https://github.com/PowerShell/PowerShell)を使用する。  

## Installing on this script
- [Python for Windows](https://www.python.org/)
- [Jupyter-PowerShell5](https://github.com/DeepAQ/Jupyter-PowerShell5)
- [Jupyter-PowerShellSDK](https://github.com/sakaztk/Jupyter-PowerShellSDK) (オプション)
- [Jupyter Powershell Kernel](https://github.com/vors/jupyter-powershell) (オプション)
- [Node.js](https://nodejs.org/) (Use in extentions for JupyterLab)
- [PowerShell 7](https://github.com/PowerShell/PowerShell) (オプション)
- [Jupyter Nbextensions](https://github.com/ipython-contrib/jupyter_contrib_nbextensions) (オプション)
- [Jupyter Nbextensions Configurator](https://github.com/Jupyter-contrib/jupyter_nbextensions_configurator) (オプション)
- [Git for Windows](https://gitforwindows.org/) (オプション)
- [NII Extensions for Jupyter Notebook](https://github.com/NII-cloud-operation) (オプション)
- [.Net Interactive](https://github.com/dotnet/interactive) (オプション)

## インストール方法
.\WinPython.ps1 [スクリプトオプション]

### スクリプトオプション
- PythonVersion  
Python for Windowsのバージョンを指定します。  
必須: いいえ  
デフォルト: 3.11  
例: .\WinPython.ps1 -PythonVersion 3.10

- UsePipKernel  
このスイッチオプションを指定すると、[Jupyter-PowerShell5](https://github.com/DeepAQ/Jupyter-PowerShell5)の代わりに[Jupyter Powershell Kernel](https://github.com/vors/jupyter-powershell)を使用します。  
例: .\WinPython.ps1 -UsePipKernel

- InstallNBExtensions  
このスイッチオプションを指定すると、 [Jupyter Nbextensions](https://github.com/ipython-contrib/jupyter_contrib_nbextensions) と [Jupyter Nbextensions Configurator](https://github.com/Jupyter-contrib/jupyter_nbextensions_configurator)をインストールします。  
例: .\WinPython.ps1 -InstallNBExtensions

- InstallNIIExtensions  
このスイッチオプションを指定すると、[NII Extensions for Jupyter Notebook](https://github.com/NII-cloud-operation)をインストールします。  
例: .\WinPython.ps1 -InstallNIIExtensions

- InstallGit  
このスイッチオプションを指定すると、[Git for Windows](https://gitforwindows.org/)をインストールします。  
例: .\WinPython.ps1 -InstallGit

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
