# Miniforge
[Miniforge](https://github.com/conda-forge/miniforge)を使用して[Jupyter Notebook](https://jupyter.org/)上で[Powershell](https://github.com/PowerShell/PowerShell)を使用する。  

## インストールするソフトウェア
- [Miniforge](https://github.com/conda-forge/miniforge)
- [Node.js](https://nodejs.org/) (Use in extentions for JupyterLab)
- [Jupyter-PowerShell5](https://github.com/DeepAQ/Jupyter-PowerShell5)
- [Jupyter-PowerShellSDK](https://github.com/sakaztk/Jupyter-PowerShellSDK) (オプション)
- [.Net Interactive](https://github.com/dotnet/interactive) (オプション)

## インストール方法
.\Miniforge.ps1 [スクリプトオプション]

## スクリプトオプション
 - InstallationType [Computer | User]   
インストールターゲットをComputer（すべてのユーザー）またはUser（実行ユーザー）に指定します。  
必須: いいえ  
デフォルト: Computer  
例: .\Miniforge.ps1 -InstallationType User

- InstallPwsh7SDK  
このスイッチオプションを指定すると、 [Jupyter-PowerShellSDK](https://github.com/sakaztk/Jupyter-PowerShellSDK)をインストールします。  
例: .\Anaconda.ps1 -InstallPwsh7SDK

- InstallDotnetInteractive  
このスイッチオプションを指定すると、[.Net Interactive](https://github.com/dotnet/interactive)をインストールします。  
例: .\Miniforge.ps1 -InstallDotnetInteractive

- CleanupDownloadFiles  
このスイッチオプションを指定すると、インストール後にダウンロードしたファイルを削除します。
例: .\Miniforge.ps1 -DoNotCleanupDownloadFiles

- WorkingFolder [Folder Path]  
スクリプトで使用する作業フォルダを指定します。  
必須: いいえ  
デフォルト: $PSScriptRoot (このスクリプトと同じフォルダ)  
例: .\Miniforge.ps1 -WorkingFolder C:\pathto\folder

## インストール例
``` PowerShell
Set-Location $env:HOMEPATH
Invoke-WebRequest -UseBasicParsing `
    -Uri https://github.com/sakaztk/pwsh-notebook/raw/master/Miniforge/Miniforge.ps1 `
    -OutFile .\Miniforge.ps1
Set-ExecutionPolicy Bypass -Scope Process -Force
.\Miniforge.ps1 -CleanupDownloadFiles -WorkingFolder $env:HOMEPATH -Verbose
pip install jupyterlab-language-pack-ja-JP
```