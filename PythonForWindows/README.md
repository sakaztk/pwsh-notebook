# PythonForWindows
Using [Powershell](https://github.com/PowerShell/PowerShell) on [Jupyter Notebook](https://jupyter.org/) on [Python for Windows](https://www.python.org/).

## Installing on this script
- [Python for Windows](https://www.python.org/)
- [Node.js](https://nodejs.org/) (Use in extentions for JupyterLab)
- [Jupyter-PowerShell5](https://github.com/sakaztk/Jupyter-PowerShellSDK/tree/powershellsdk/Jupyter-PowerShell5) (forked from [DeepAQ](https://github.com/DeepAQ/Jupyter-PowerShell5))
- [Jupyter-PowerShellSDK](https://github.com/sakaztk/Jupyter-PowerShellSDK) (Optional)
- [.Net Interactive](https://github.com/dotnet/interactive) (Optional)

## Installations
.\WinPython.ps1 [Script Option(s)]

### Script Options
- PythonVersion  
Specify version of the [Python for Windows](https://www.python.org/).  
Mandatory: No  
Default: 3.13  
e.g.: .\WinPython.ps1 -PythonVersion 3.12

- InstallPwsh7SDK  
This switch option will install [Jupyter-PowerShellSDK](https://github.com/sakaztk/Jupyter-PowerShellSDK).  
e.g.: .\Anaconda.ps1 -InstallPwsh7SDK

- InstallDotnetInteractive  
This switch option will install [.Net Interactive](https://github.com/dotnet/interactive).  
e.g.: .\WinPython.ps1 -InstallDotnetInteractive

- CleanupDownloadFiles  
This switch option will delete downloaded files after installations.  
e.g.: .\WinPython.ps1 -DoNotCleanupDownloadFiles

- WorkingFolder [Folder Path]  
Specify the working folder in this script.
Default: $PSScriptRoot (Same folder as this script)  
Mandatory: No  
e.g.: .\WinPython.ps1 -WorkingFolder C:\pathto\folder

## Installation Example
``` PowerShell
Set-Location $env:HOMEPATH
Invoke-WebRequest -UseBasicParsing `
    -Uri https://github.com/sakaztk/pwsh-notebook/raw/master/PythonForWindows/PythonForWindows.ps1 `
    -OutFile .\PythonForWindows.ps1
Set-ExecutionPolicy Bypass -Scope Process -Force
.\PythonForWindows.ps1 -CleanupDownloadFiles -WorkingFolder $env:HOMEPATH -Verbose
```