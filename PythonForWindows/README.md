# PythonForWindows
Using [Powershell](https://github.com/PowerShell/PowerShell) on [Jupyter Notebook](https://jupyter.org/) on [Python](https://www.python.org/).

## Installing on this script
- [Python for Windows](https://www.python.org/)
- [Jupyter Powershell Kernel](https://github.com/vors/jupyter-powershell)
- [Node.js](https://nodejs.org/) (Use in extentions for JupyterLab)
- [PowerShell 7](https://github.com/PowerShell/PowerShell) (Optional)
- [Jupyter Nbextensions](https://github.com/ipython-contrib/jupyter_contrib_nbextensions) (Optional)
- [Jupyter Nbextensions Configurator](https://github.com/Jupyter-contrib/jupyter_nbextensions_configurator) (Optional)
- [Git for Windows](https://gitforwindows.org/) (Optional)
- [NII Extensions for Jupyter Notebook](https://github.com/NII-cloud-operation) (Optional)
- [.Net Interactive](https://github.com/dotnet/interactive) (Optional)
- [Jupyter-PowerShell5](https://github.com/DeepAQ/Jupyter-PowerShell5) (Optional)
- [Jupyter-PowerShellSDK](https://github.com/sakaztk/Jupyter-PowerShellSDK) (Optional)

## Installations
.\WinPython.ps1 [Script Option(s)]

### Script Options
- PythonVersion  
Specify version of the Python for Windows.  
Mandatory: No  
Default: 3.9  
e.g.: .\WinPython.ps1 -PythonVersion 3.10

- UsePipKernel  
This switch option will install [Jupyter Powershell Kernel](https://github.com/vors/jupyter-powershell) instead of [Jupyter-PowerShell5](https://github.com/DeepAQ/Jupyter-PowerShell5).  
Mandatory: No  
e.g.: .\WinPython.ps1 -UsePipKernel

- InstallNBExtensions  
This switch option will install [Jupyter Nbextensions](https://github.com/ipython-contrib/jupyter_contrib_nbextensions) and [Jupyter Nbextensions Configurator](https://github.com/Jupyter-contrib/jupyter_nbextensions_configurator).  
Mandatory: No  
e.g.: .\WinPython.ps1 -InstallNBExtensions

- InstallNIIExtensions  
This switch option will install [NII Extensions for Jupyter Notebook](https://github.com/NII-cloud-operation). then requires the git for installation or add "-InstallGit" option.  
Mandatory: No  
e.g.: .\WinPython.ps1 -InstallNIIExtensions

- InstallGit  
This switch option will install [Git for Windows](https://gitforwindows.org/).  
Mandatory: No  
e.g.: .\WinPython.ps1 -InstallGit

- InstallDotnetInteractive  
This switch option will install [.Net Interactive](https://github.com/dotnet/interactive).  
Mandatory: No  
e.g.: .\WinPython.ps1 -InstallDotnetInteractive

- CleanupDownloadFiles  
This switch option will delete downloaded files after installations.  
Mandatory: No  
e.g.: .\WinPython.ps1 -DoNotCleanupDownloadFiles

- WorkingFolder [Folder Path]  
Specify the working folder in this script.
Default: $PSScriptRoot (Same folder as this script)  
Mandatory: No  
e.g.: .\WinPython.ps1 -WorkingFolder C:\pathto\folder