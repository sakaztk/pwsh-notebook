# Miniconda
Using [Powershell](https://github.com/PowerShell/PowerShell) on [Jupyter Notebook](https://jupyter.org/) on [Miniconda](https://docs.conda.io/en/latest/miniconda.html).  

## Installing Softwares
- [Miniconda](https://docs.conda.io/en/latest/miniconda.html)
- [Jupyter-PowerShell5](https://github.com/DeepAQ/Jupyter-PowerShell5)
- [Jupyter-PowerShellSDK](https://github.com/sakaztk/Jupyter-PowerShellSDK) (Optional)
- [Jupyter Powershell Kernel](https://github.com/vors/jupyter-powershell) (Optional)
- [Node.js](https://nodejs.org/) (Use in extentions for JupyterLab)
- [PowerShell 7](https://github.com/PowerShell/PowerShell) (Optional)
- [Jupyter Nbextensions](https://github.com/ipython-contrib/jupyter_contrib_nbextensions) (Optional)
- [Jupyter Nbextensions Configurator](https://github.com/Jupyter-contrib/jupyter_nbextensions_configurator) (Optional)
- [.Net Interactive](https://github.com/dotnet/interactive) (Optional)

## Installations
.\Miniconda.ps1 [Script Option(s)]
## Script Options
 - InstallationType [Computer | User]   
Specify insatallation target to the Computer(All Users) or a User(Just Me).  
Mandatory: No  
Default: Computer  
e.g.: .\Miniconda.ps1 -InstallationType User

- UsePipKernel  
This switch option will install [Jupyter Powershell Kernel](https://github.com/vors/jupyter-powershell) instead of [Jupyter-PowerShell5](https://github.com/DeepAQ/Jupyter-PowerShell5).  
e.g.: .\WinPython.ps1 -UsePipKernel

- InstallPwsh7SDK  
This switch option will install [Jupyter-PowerShellSDK](https://github.com/sakaztk/Jupyter-PowerShellSDK).  
e.g.: .\Anaconda.ps1 -InstallPwsh7SDK

- InstallNBExtensions  
This switch option will install [Jupyter Nbextensions](https://github.com/ipython-contrib/jupyter_contrib_nbextensions) and [Jupyter Nbextensions Configurator](https://github.com/Jupyter-contrib/jupyter_nbextensions_configurator).  
[Note] It may not work export function for JupyterLab if install NBExtensions.([*](https://github.com/jupyterlab/jupyterlab-desktop/issues/465))  
e.g.: .\Miniconda.ps1 -InstallNBExtensions

- InstallDotnetInteractive  
This switch option will install latest powershell 7 and available it in Jupyter Notebook options.  
e.g.: .\Miniconda.ps1 -InstallDotnetInteractive

- CleanupDownloadFiles  
This switch option will delete downloaded files after installations.  
e.g.: .\Miniconda.ps1 -DoNotCleanupDownloadFiles

- WorkingFolder [Folder Path]  
Specify the working folder in this script.
Mandatory: No  
Default: $PSScriptRoot (Same folder as this script)  
e.g.: .\Miniconda.ps1 -WorkingFolder C:\pathto\folder

## Installation Example
``` PowerShell
Set-Location $env:HOMEPATH
Invoke-WebRequest -UseBasicParsing `
    -Uri https://github.com/sakaztk/pwsh-notebook/raw/master/Miniconda/Miniconda.ps1 `
    -OutFile .\Miniconda.ps1
Set-ExecutionPolicy Bypass -Scope Process -Force
.\Miniconda.ps1 -CleanupDownloadFiles -WorkingFolder $env:HOMEPATH -Verbose
```