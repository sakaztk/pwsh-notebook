# Miniconda
Using [Powershell](https://github.com/PowerShell/PowerShell) on [Jupyter Notebook](https://jupyter.org/) on [Miniconda](https://docs.conda.io/en/latest/miniconda.html).  
![notebook](https://user-images.githubusercontent.com/20841864/93240613-4ebc5100-f7bf-11ea-9ff5-586a28ab5492.png)

## Installing Softwares
- [Miniconda](https://docs.conda.io/en/latest/miniconda.html)
- [Jupyter Powershell Kernel](https://github.com/vors/jupyter-powershell)
- [Node.js](https://nodejs.org/) (Use in extentions for JupyterLab)
- [PowerShell 7](https://github.com/PowerShell/PowerShell) (Option)
- [Jupyter Nbextensions](https://github.com/ipython-contrib/jupyter_contrib_nbextensions) (Option)
- [Jupyter Nbextensions Configurator](https://github.com/Jupyter-contrib/jupyter_nbextensions_configurator) (Option)
- [NII Extensions for Jupyter Notebook](https://github.com/NII-cloud-operation) (Option)

## Installations
.\Miniconda.ps1 [Script Option(s)]
## Script Options
 - InstallationType [Computer | User]   
Specify insatallation target to the Computer(All Users) or a User(Just Me).  
Default: Computer  
e.g.: .\Miniconda.ps1 -InstallationType User

- InstallPowerShell7  
This switch option will install [latest PowerShell 7](https://github.com/PowerShell/PowerShell/releases/latest) and available it in Jupyter Notebook options.  
e.g.: .\Miniconda.ps1 -InstallPowerShell7

- InstallDotnetInteractive  
This switch option will install latest powershell 7 and available it in Jupyter Notebook options.  
e.g.: .\Miniconda.ps1 -InstallDotnetInteractive

- InstallNBExtensions  
This switch option will install [Jupyter Nbextensions](https://github.com/ipython-contrib/jupyter_contrib_nbextensions) and [Jupyter Nbextensions Configurator](https://github.com/Jupyter-contrib/jupyter_nbextensions_configurator).
e.g.: .\Miniconda.ps1 -InstallNBExtensions

- InstallNIIExtensions  
This switch option will install [NII Extensions for Jupyter Notebook](https://github.com/NII-cloud-operation).
e.g.: .\Miniconda.ps1 -InstallNIIExtensions

- CleanupDownloadFiles  
This switch option will delete downloaded files after installations.  
e.g.: .\Miniconda.ps1 -DoNotCleanupDownloadFiles

- WorkingFolder [Folder Path]  
Specify the working folder in this script.
Default: $PSScriptRoot (Same folder as this script)  
e.g.: .\Miniconda.ps1 -WorkingFolder C:\pathto\folder

Use following option if you install all softwares  
.\Miniconda.ps1 -InstallPowerShell7 -InstallDotnetInteractive -InstallNBExtensions -InstallNIIExtensions

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
