# Anaconda
Using [Powershell](https://github.com/PowerShell/PowerShell) on [Jupyter Notebook](https://jupyter.org/) on [Anaconda](https://www.anaconda.com/).  

## Installing Softwares
- [Anaconda](https://www.anaconda.com/)
- [Jupyter Powershell Kernel](https://github.com/vors/jupyter-powershell)
- [Node.js](https://nodejs.org/) (Use in extentions for JupyterLab)
- [PowerShell 7](https://github.com/PowerShell/PowerShell) (Optional)
- [Jupyter Nbextensions](https://github.com/ipython-contrib/jupyter_contrib_nbextensions) (Optional)
- [Jupyter Nbextensions Configurator](https://github.com/Jupyter-contrib/jupyter_nbextensions_configurator) (Optional)
- [NII Extensions for Jupyter Notebook](https://github.com/NII-cloud-operation) (Optional)
- [.Net Interactive](https://github.com/dotnet/interactive) (Optional)
- [Jupyter-PowerShell5](https://github.com/DeepAQ/Jupyter-PowerShell5) (Optional)

## Installations
.\Anaconda.ps1 [Script Option(s)]
## Script Options
 - InstallationType [Computer | User]   
Specify insatallation target to the Computer(All Users) or a User(Just Me).  
Default: Computer  
e.g.: .\Anaconda.ps1 -InstallationType User

- InstallPowerShell7  
This switch option will install [latest PowerShell 7](https://github.com/PowerShell/PowerShell/releases/latest) and available it in Jupyter Notebook options.  
e.g.: .\Anaconda.ps1 -InstallPowerShell7

- InstallNBExtensions  
This switch option will install [Jupyter Nbextensions](https://github.com/ipython-contrib/jupyter_contrib_nbextensions) and [Jupyter Nbextensions Configurator](https://github.com/Jupyter-contrib/jupyter_nbextensions_configurator).  
e.g.: .\Anaconda.ps1 -InstallNBExtensions

- InstallNIIExtensions  
This switch option will install [NII Extensions for Jupyter Notebook](https://github.com/NII-cloud-operation).  
e.g.: .\Anaconda.ps1 -InstallNIIExtensions

- InstallDotnetInteractive  
This switch option will install [.Net Interactive](https://github.com/dotnet/interactive).  
Mandatory: No  
e.g.: .\WinPython.ps1 -InstallDotnetInteractive

- InstallDeepAQKernel
This switch option will install [Jupyter-PowerShell5](https://github.com/DeepAQ/Jupyter-PowerShell5).  
Mandatory: No  
e.g.: .\WinPython.ps1 -InstallDeepAQKernel

- CleanupDownloadFiles  
This switch option will delete downloaded files after installations.  
e.g.: .\Anaconda.ps1 -DoNotCleanupDownloadFiles

- WorkingFolder [Folder Path]  
Specify the working folder in this script.
Default: $PSScriptRoot (Same folder as this script)  
e.g.: .\Anaconda.ps1 -WorkingFolder C:\pathto\folder

Use following option if you install all softwares  
.\Anaconda.ps1 -InstallPowerShell7 -InstallDotnetInteractive -InstallNBExtensions -InstallNIIExtensions -InstallDeepAQKernel

## Run the PowerShell from Terminal
- Powershell 5 (Native)
```
$ powershell
PS >
```
- Powershell 7
```
$ pwsh
PS >
```
