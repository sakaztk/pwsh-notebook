# Anaconda
[Anaconda](https://www.anaconda.com/)を使用して[Jupyter Notebook](https://jupyter.org/)上で[Powershell](https://github.com/PowerShell/PowerShell)を使用する。  

## インストールするソフトウェア
- [Anaconda](https://www.anaconda.com/)
- [Node.js](https://nodejs.org/) (JupyterLab拡張機能の要件)
- [Jupyter-PowerShell5](https://github.com/DeepAQ/Jupyter-PowerShell5)
- [Jupyter-PowerShellSDK](https://github.com/sakaztk/Jupyter-PowerShellSDK) (オプション)
- [.Net Interactive](https://github.com/dotnet/interactive) (オプション)

## インストール方法
.\Anaconda.ps1 [スクリプトオプション]

## スクリプトオプション
 - InstallationType [Computer | User]   
インストールターゲットをComputer（すべてのユーザー）またはUser（実行ユーザー）に指定します。  
必須: いいえ  
デフォルト: Computer  
例: .\Anaconda.ps1 -InstallationType User

- InstallPwsh7SDK  
このスイッチオプションを指定すると、 [Jupyter-PowerShellSDK](https://github.com/sakaztk/Jupyter-PowerShellSDK)をインストールします。  
例: .\Anaconda.ps1 -InstallPwsh7SDK

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

## インストール例
``` PowerShell
Set-Location $env:HOMEPATH
Invoke-WebRequest -UseBasicParsing `
    -Uri https://github.com/sakaztk/pwsh-notebook/raw/master/Anaconda/Anaconda.ps1 `
    -OutFile .\Anaconda.ps1
Set-ExecutionPolicy Bypass -Scope Process -Force
.\Anaconda.ps1 -CleanupDownloadFiles -WorkingFolder $env:HOMEPATH -Verbose
pip install jupyterlab-language-pack-ja-JP
```