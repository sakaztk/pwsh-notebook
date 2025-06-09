# WinPython
Using [Powershell](https://github.com/PowerShell/PowerShell) on [Jupyter Notebook](https://jupyter.org/) on [WinPython](https://winpython.github.io/).  

## Installing
- [WinPython](https://winpython.github.io/)
- [Node.js](https://nodejs.org/) (Use in extentions for JupyterLab)
- [Jupyter-PowerShell5](https://github.com/sakaztk/Jupyter-PowerShellSDK/tree/powershellsdk/Jupyter-PowerShell5) (forked from [DeepAQ](https://github.com/DeepAQ/Jupyter-PowerShell5))
- [Jupyter-PowerShellSDK](https://github.com/sakaztk/Jupyter-PowerShellSDK) (Optional)
- [PortableGit](https://github.com/git-for-windows/git) (Optional)
- [.Net Interactive](https://github.com/dotnet/interactive) (Optional)

## Installations
.\WinPython.ps1 [Script Option(s)]
## Script Options
- WinPythonVersion  
Specify version of the [WinPython](https://winpython.github.io/).  
Mandatory: No  
Default: 3.9  
e.g.: .\WinPython.ps1 -WinPythonVersion 3.10  

- WinPythonType  
Specify type of the [WinPython](https://winpython.github.io/).   
Mandatory: No  
Default: dot 
e.g.: .\WinPython.ps1 -WinPythonType cod

- WinPythonPath  
Specify installation path of the [WinPython](https://winpython.github.io/).  
Mandatory: No  
Default: $env:LOCALAPPDATA\Programs\WinPython  
e.g.: .\WinPython.ps1 -WinPythonPath C:\PathTo\WinPython

- InstallPwsh7SDK  
This switch option will install [Jupyter-PowerShellSDK](https://github.com/sakaztk/Jupyter-PowerShellSDK).  
e.g.: .\Anaconda.ps1 -InstallPwsh7SDK

- InstallPortableGit  
This switch option will install [PortableGit](https://github.com/git-for-windows/git).  
e.g.: .\WinPython.ps1 -InstallPortableGit

- InstallDotnetInteractive  
This switch option will install [.Net Interactive](https://github.com/dotnet/interactive).  
e.g.: .\WinPython.ps1 -InstallDotnetInteractive

- PortableGitPath  
Specify installation path of the [PortableGit](https://github.com/git-for-windows/git).  
Mandatory: No  
Default: $env:LOCALAPPDATA\Programs\WinPython\PortableGit  
e.g.: .\WinPython.ps1 -InstallPortableGit -PortableGitPath C:\PathTo\PortableGit

- CleanupDownloadFiles  
This switch option will delete downloaded files after installations.  
e.g.: .\WinPython.ps1 -DoNotCleanupDownloadFiles

- WorkingFolder [Folder Path]  
Specify the working folder in this script.
Default: $PSScriptRoot (Same folder as this script)  
Mandatory: No  
e.g.: .\WinPython.ps1 -WorkingFolder C:\pathto\folder

- AddStartMenu
This switch option will add WinPython binaries to Windows start menu.  
e.g.: .\WinPython.ps1 -AddStartMenu

## Installation Example
``` PowerShell
Set-Location $env:HOMEPATH
Invoke-WebRequest -UseBasicParsing `
    -Uri https://github.com/sakaztk/pwsh-notebook/raw/master/WinPython/WinPython.ps1 `
    -OutFile .\WinPython.ps1
Set-ExecutionPolicy Bypass -Scope Process -Force
.\WinPython.ps1 -CleanupDownloadFiles -WorkingFolder $env:HOMEPATH -AddStartMenu -Verbose
```