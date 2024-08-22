# Anaconda
Using [Powershell](https://github.com/PowerShell/PowerShell) on [Jupyter Notebook](https://jupyter.org/) on [Anaconda](https://www.anaconda.com/).  

## Installing Softwares
- [Anaconda](https://www.anaconda.com/)
- [Jupyter-PowerShell5](https://github.com/DeepAQ/Jupyter-PowerShell5)
- [Jupyter-PowerShellSDK](https://github.com/sakaztk/Jupyter-PowerShellSDK) (Optional)
- [Jupyter Powershell Kernel](https://github.com/vors/jupyter-powershell) (Optional)
- [Node.js](https://nodejs.org/) (Use in extentions for JupyterLab)
- [PowerShell 7](https://github.com/PowerShell/PowerShell) (Optional)
- [Jupyter Nbextensions](https://github.com/ipython-contrib/jupyter_contrib_nbextensions) (Optional)
- [Jupyter Nbextensions Configurator](https://github.com/Jupyter-contrib/jupyter_nbextensions_configurator) (Optional)
- [.Net Interactive](https://github.com/dotnet/interactive) (Optional)

## Installations
.\Anaconda.ps1 [Script Option(s)]
## Script Options
 - InstallationType [Computer | User]   
Specify insatallation target to the Computer(All Users) or a User(Just Me).  
Mandatory: No  
Default: Computer  
e.g.: .\Anaconda.ps1 -InstallationType User

- UsePipKernel  
This switch option will install [Jupyter Powershell Kernel](https://github.com/vors/jupyter-powershell) instead of [Jupyter-PowerShell5](https://github.com/DeepAQ/Jupyter-PowerShell5).  
e.g.: .\Anaconda.ps1 -UsePipKernel

- InstallPwsh7SDK  
This switch option will install [Jupyter-PowerShellSDK](https://github.com/sakaztk/Jupyter-PowerShellSDK).  
e.g.: .\Anaconda.ps1 -InstallPwsh7SDK

- InstallPwsh7ForPipKernel  
This switch option will install [latest PowerShell 7](https://github.com/PowerShell/PowerShell/releases/latest) and available it in Jupyter Notebook options with [Jupyter Powershell Kernel](https://github.com/vors/jupyter-powershell).  
e.g.: .\Anaconda.ps1 -UsePipKernel -InstallPwsh7ForPipKernel

- InstallNBExtensions  
This switch option will install [Jupyter Nbextensions](https://github.com/ipython-contrib/jupyter_contrib_nbextensions) and [Jupyter Nbextensions Configurator](https://github.com/Jupyter-contrib/jupyter_nbextensions_configurator).  
e.g.: .\Anaconda.ps1 -InstallNBExtensions

- InstallDotnetInteractive  
This switch option will install [.Net Interactive](https://github.com/dotnet/interactive).  
e.g.: .\Anaconda.ps1 -InstallDotnetInteractive

- CleanupDownloadFiles  
This switch option will delete downloaded files after installations.  
e.g.: .\Anaconda.ps1 -DoNotCleanupDownloadFiles

- WorkingFolder [Folder Path]  
Specify the working folder in this script.
Mandatory: No  
Default: $PSScriptRoot (Same folder as this script)  
e.g.: .\Anaconda.ps1 -WorkingFolder C:\pathto\folder

## Installation Example
``` PowerShell
Set-Location $env:HOMEPATH
Invoke-WebRequest -UseBasicParsing `
    -Uri https://github.com/sakaztk/pwsh-notebook/raw/master/Anaconda/Anaconda.ps1 `
    -OutFile .\Anaconda.ps1
Set-ExecutionPolicy Bypass -Scope Process -Force
.\Anaconda.ps1 -CleanupDownloadFiles -WorkingFolder $env:HOMEPATH -Verbose
```