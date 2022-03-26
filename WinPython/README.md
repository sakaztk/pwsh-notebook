# WinPython
Using [Powershell](https://github.com/PowerShell/PowerShell) on [Jupyter Notebook](https://jupyter.org/) on [WinPython](https://winpython.github.io/).  

## Installing
- [WinPython](https://winpython.github.io/)
- [Jupyter Powershell Kernel](https://github.com/vors/jupyter-powershell)
- [Node.js](https://nodejs.org/) (Use in extentions for JupyterLab)
- [PowerShell 7](https://github.com/PowerShell/PowerShell) (Optional)
- [Jupyter Nbextensions](https://github.com/ipython-contrib/jupyter_contrib_nbextensions) (Optional)
- [Jupyter Nbextensions Configurator](https://github.com/Jupyter-contrib/jupyter_nbextensions_configurator) (Optional)
- [PortableGit](https://github.com/git-for-windows/git) (Optional)
- [NII Extensions for Jupyter Notebook](https://github.com/NII-cloud-operation) (Optional)
- [.Net Interactive](https://github.com/dotnet/interactive) (Optional)
- [Jupyter-PowerShell5](https://github.com/DeepAQ/Jupyter-PowerShell5) (Optional)
- [Jupyter-PowerShellSDK](https://github.com/sakaztk/Jupyter-PowerShellSDK) (Optional)

## Installations
.\WinPython.ps1 [Script Option(s)]
## Script Options
- WinPythonVersion  
Specify version of the WinPython. (Version 3.8 or 3.9)  
Mandatory: No  
Default: 3.8  
e.g.: .\WinPython.ps1 -WinPythonVersion 3.9

- WinPythonType  
Specify type of the WinPython. (unmarked, dot or cod)  
Mandatory: No  
Default: dot 
e.g.: .\WinPython.ps1 -WinPythonType cod

- WinPythonPath  
Specify installation path of the WinPython.  
Mandatory: No  
Default: $env:LOCALAPPDATA\Programs\WinPython  
e.g.: .\WinPython.ps1 -WinPythonPath C:\PathTo\WinPython

- UsePipKernel  
This switch option will install [Jupyter Powershell Kernel](https://github.com/vors/jupyter-powershell) instead of [Jupyter-PowerShell5](https://github.com/DeepAQ/Jupyter-PowerShell5).  
Mandatory: No  
e.g.: .\WinPython.ps1 -UsePipKernel

- InstallPwsh7ForPipKernel  
This switch option will install [latest PowerShell 7](https://github.com/PowerShell/PowerShell/releases/latest) and available it in Jupyter Notebook options with [Jupyter Powershell Kernel](https://github.com/vors/jupyter-powershell).  
Mandatory: No  
e.g.: .\WinPython.ps1 -UsePipKernel -InstallPwsh7ForPipKernel

- PowerShell7Path  
Specify installation path of the PowerShell 7.  
Mandatory: No  
Default: $env:LOCALAPPDATA\Programs\WinPython\pwsh7  
e.g.: .\WinPython.ps1 -PowerShell7Path C:\PathTo\WinPython

- InstallNBExtensions  
This switch option will install [Jupyter Nbextensions](https://github.com/ipython-contrib/jupyter_contrib_nbextensions) and [Jupyter Nbextensions Configurator](https://github.com/Jupyter-contrib/jupyter_nbextensions_configurator).  
Mandatory: No  
e.g.: .\WinPython.ps1 -InstallNBExtensions

- InstallNIIExtensions  
This switch option will install [NII Extensions for Jupyter Notebook](https://github.com/NII-cloud-operation). then requires the git for installation or add "-InstallPortableGit" option.  
Mandatory: No  
e.g.: .\WinPython.ps1 -InstallNIIExtensions

- InstallPortableGit  
This switch option will install [PortableGit](https://github.com/git-for-windows/git).  
Mandatory: No  
e.g.: .\WinPython.ps1 -InstallPortableGit

- InstallDotnetInteractive  
This switch option will install [.Net Interactive](https://github.com/dotnet/interactive).  
Mandatory: No  
e.g.: .\WinPython.ps1 -InstallDotnetInteractive

- PortableGitPath  
Specify installation path of the PortableGit.  
Mandatory: No  
Default: $env:LOCALAPPDATA\Programs\WinPython\PortableGit  
e.g.: .\WinPython.ps1 -PortableGitPath C:\PathTo\PortableGit

- CleanupDownloadFiles  
This switch option will delete downloaded files after installations.  
Mandatory: No  
e.g.: .\WinPython.ps1 -DoNotCleanupDownloadFiles

- WorkingFolder [Folder Path]  
Specify the working folder in this script.
Default: $PSScriptRoot (Same folder as this script)  
Mandatory: No  
e.g.: .\WinPython.ps1 -WorkingFolder C:\pathto\folder

- AddStartMenu
This switch option will add WinPython binaries to Windows start menu.  
Mandatory: No  
e.g.: .\WinPython.ps1 -AddStartMenu
