# Anaconda
[Anaconda](https://www.anaconda.com/)を使用して[Jupyter Notebook](https://jupyter.org/)上で[Powershell](https://github.com/PowerShell/PowerShell)を使用する。  

## インストールするソフトウェア
- [Anaconda](https://www.anaconda.com/)
- [Jupyter-PowerShell5](https://github.com/DeepAQ/Jupyter-PowerShell5)
- [Jupyter-PowerShellSDK](https://github.com/sakaztk/Jupyter-PowerShellSDK) (オプション)
- [Jupyter Powershell Kernel](https://github.com/vors/jupyter-powershell) (オプション)
- [Node.js](https://nodejs.org/) (Use in extentions for JupyterLab)
- [PowerShell 7](https://github.com/PowerShell/PowerShell) (オプション)
- [Jupyter Nbextensions](https://github.com/ipython-contrib/jupyter_contrib_nbextensions) (オプション)
- [Jupyter Nbextensions Configurator](https://github.com/Jupyter-contrib/jupyter_nbextensions_configurator) (オプション)
- [NII Extensions for Jupyter Notebook](https://github.com/NII-cloud-operation) (オプション)
- [.Net Interactive](https://github.com/dotnet/interactive) (オプション)

## インストール方法
.\Anaconda.ps1 [スクリプトオプション]

## スクリプトオプション
 - InstallationType [Computer | User]   
インストールターゲットをComputer（すべてのユーザー）またはUser（実行ユーザー）に指定します。  
必須: いいえ  
デフォルト: Computer  
例: .\Anaconda.ps1 -InstallationType User

- UsePipKernel  
このスイッチオプションを指定すると、[Jupyter-PowerShell5](https://github.com/DeepAQ/Jupyter-PowerShell5)の代わりに[Jupyter Powershell Kernel](https://github.com/vors/jupyter-powershell)を使用します。  
例: .\Anaconda.ps1 -UsePipKernel

- InstallPwsh7SDK  
このスイッチオプションを指定すると、 [Jupyter-PowerShellSDK](https://github.com/sakaztk/Jupyter-PowerShellSDK)をインストールします。  
例: .\Anaconda.ps1 -InstallPwsh7SDK

- InstallPwsh7ForPipKernel  
このスイッチオプションを指定すると、最新版の[PowerShell 7](https://github.com/PowerShell/PowerShell/releases/latest)をインストールし、[Jupyter Powershell Kernel](https://github.com/vors/jupyter-powershell)で使用可能にします。  
例: .\Anaconda.ps1 -UsePipKernel -InstallPwsh7ForPipKernel

- InstallNBExtensions  
このスイッチオプションを指定すると、 [Jupyter Nbextensions](https://github.com/ipython-contrib/jupyter_contrib_nbextensions) と [Jupyter Nbextensions Configurator](https://github.com/Jupyter-contrib/jupyter_nbextensions_configurator)をインストールします。  
例: .\Anaconda.ps1 -InstallNBExtensions

- InstallNIIExtensions  
このスイッチオプションを指定すると、[NII Extensions for Jupyter Notebook](https://github.com/NII-cloud-operation)をインストールします。  
例: .\Anaconda.ps1 -InstallNIIExtensions

- InstallDotnetInteractive  
このスイッチオプションを指定すると、[.Net Interactive](https://github.com/dotnet/interactive)をインストールします。  
例: .\Anaconda.ps1 -InstallDotnetInteractive

- CleanupDownloadFiles  
このスイッチオプションを指定すると、インストール後にダウンロードしたファイルを削除します。
例: .\Anaconda.ps1 -DoNotCleanupDownloadFiles

- WorkingFolder [Folder Path]  
スクリプトで使用する作業フォルダを指定します。  
必須: いいえ  
デフォルト: $PSScriptRoot (このスクリプトと同じフォルダ)  
例: .\Anaconda.ps1 -WorkingFolder C:\pathto\folder
