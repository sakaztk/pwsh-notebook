# Miniforge
Using [Powershell](https://github.com/PowerShell/PowerShell) on [Jupyter Notebook](https://jupyter.org/) on [Miniforge](https://github.com/conda-forge/miniforge).  

## Installing Softwares
- [Miniforge](https://github.com/conda-forge/miniforge)
- [Node.js](https://nodejs.org/) (Use in extentions for JupyterLab)
- [Jupyter-PowerShell5](https://github.com/sakaztk/Jupyter-PowerShellSDK/tree/powershellsdk/Jupyter-PowerShell5) (forked from [DeepAQ](https://github.com/DeepAQ/Jupyter-PowerShell5))
- [Jupyter-PowerShellSDK](https://github.com/sakaztk/Jupyter-PowerShellSDK) (Optional)
- [.Net Interactive](https://github.com/dotnet/interactive) (Optional)

## Installations
.\Miniforge.ps1 [Script Option(s)]

## Script Options
 - InstallationType [Computer | User]   
Specify insatallation target to the Computer(All Users) or a User(Just Me).  
Mandatory: No  
Default: Computer  
e.g.: .\Miniforge.ps1 -InstallationType User

- InstallPwsh7SDK  
This switch option will install [Jupyter-PowerShellSDK](https://github.com/sakaztk/Jupyter-PowerShellSDK).  
e.g.: .\Anaconda.ps1 -InstallPwsh7SDK

- InstallDotnetInteractive  
This switch option will install latest powershell 7 and available it in Jupyter Notebook options.  
e.g.: .\Miniforge.ps1 -InstallDotnetInteractive

- CleanupDownloadFiles  
This switch option will delete downloaded files after installations.  
e.g.: .\Miniforge.ps1 -DoNotCleanupDownloadFiles

- WorkingFolder [Folder Path]  
Specify the working folder in this script.
Mandatory: No  
Default: $PSScriptRoot (Same folder as this script)  
e.g.: .\Miniforge.ps1 -WorkingFolder C:\pathto\folder

## Installation Example
``` PowerShell
Set-Location $env:HOMEPATH
Invoke-WebRequest -UseBasicParsing `
    -Uri https://github.com/sakaztk/pwsh-notebook/raw/master/Miniforge/Miniforge.ps1 `
    -OutFile .\Miniforge.ps1
Set-ExecutionPolicy Bypass -Scope Process -Force
.\Miniforge.ps1 -CleanupDownloadFiles -WorkingFolder $env:HOMEPATH -Verbose
```