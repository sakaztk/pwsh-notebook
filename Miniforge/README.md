# Miniforge
Using [Powershell](https://github.com/PowerShell/PowerShell) on [Jupyter Notebook](https://jupyter.org/) on [Miniforge](https://github.com/conda-forge/miniforge).  

## Installing Softwares
- [Miniforge](https://github.com/conda-forge/miniforge)
- [Jupyter-PowerShell5](https://github.com/DeepAQ/Jupyter-PowerShell5)
- [Jupyter-PowerShellSDK](https://github.com/sakaztk/Jupyter-PowerShellSDK) (Optional)
- [Jupyter Powershell Kernel](https://github.com/vors/jupyter-powershell) (Optional)
- [Node.js](https://nodejs.org/) (Use in extentions for JupyterLab)
- [PowerShell 7](https://github.com/PowerShell/PowerShell) (Optional)
- [Jupyter Nbextensions](https://github.com/ipython-contrib/jupyter_contrib_nbextensions) (Optional)
- [Jupyter Nbextensions Configurator](https://github.com/Jupyter-contrib/jupyter_nbextensions_configurator) (Optional)
- [NII Extensions for Jupyter Notebook](https://github.com/NII-cloud-operation) (Optional)
- [.Net Interactive](https://github.com/dotnet/interactive) (Optional)

## Installations
.\Miniforge.ps1 [Script Option(s)]
## Script Options
 - InstallationType [Computer | User]   
Specify insatallation target to the Computer(All Users) or a User(Just Me).  
Mandatory: No  
Default: Computer  
e.g.: .\Miniforge.ps1 -InstallationType User

- UsePipKernel  
This switch option will install [Jupyter Powershell Kernel](https://github.com/vors/jupyter-powershell) instead of [Jupyter-PowerShell5](https://github.com/DeepAQ/Jupyter-PowerShell5).  
e.g.: .\WinPython.ps1 -UsePipKernel

- InstallNBExtensions  
This switch option will install [Jupyter Nbextensions](https://github.com/ipython-contrib/jupyter_contrib_nbextensions) and [Jupyter Nbextensions Configurator](https://github.com/Jupyter-contrib/jupyter_nbextensions_configurator).  
e.g.: .\Miniforge.ps1 -InstallNBExtensions

- InstallNIIExtensions  
This switch option will install [NII Extensions for Jupyter Notebook](https://github.com/NII-cloud-operation).  
e.g.: .\Miniforge.ps1 -InstallNIIExtensions

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
