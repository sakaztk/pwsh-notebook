# escape=`

FROM mcr.microsoft.com/windows/servercore:ltsc2022
SHELL ["powershell", "-Command", "$ErrorActionPreference='Stop'; $ProgressPreference='SilentlyContinue';"]

#WinRM
RUN Set-Item WSMan:\localhost\Client\TrustedHosts -Value '*' -Force

#CodePage
RUN New-Item -Path 'HKLM:\SOFTWARE\Microsoft\Command Processor' -Force; `
    Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Command Processor' -Name AutoRun -Value '@chcp 65001>null; [System.Console]::OutputEncoding = [System.Text.Encoding]::GetEncoding("utf-8")'

#PowershellGet
RUN Install-PackageProvider Nuget -Force; `
    Install-Module -Name PowerShellGet -Force; `
    Update-Module -Name PowerShellGet -Force

#ChocolateyGet
RUN Install-PackageProvider -Name ChocolateyGet -Force; `
    Register-PackageSource -Name Chocolatey -ProviderName Chocolatey  -Location https://chocolatey.org/api/v2/ -Force
RUN @( `
    'python', `
    'nodejs', `
    'powershell-core', `
    'dotnet-sdk' `
    ) | Foreach-Object {Install-Package -Provider ChocolateyGet -Name $_ -Force}

#Jupyter
USER ContainerAdministrator

RUN pip install jupyter; `
    pip install jupyterlab;

RUN dotnet tool install -g --add-source "https://pkgs.dev.azure.com/dnceng/public/_packaging/dotnet-tools/nuget/v3/index.json" Microsoft.dotnet-interactive; `
    dotnet interactive jupyter install;

RUN (Invoke-WebRequest -Uri 'https://github.com/sakaztk/Jupyter-PowerShellSDK/releases/latest' -UseBasicParsing -Headers @{'Accept'='application/json'}| ConvertFrom-Json).update_url -replace '.*tag/(.*)', '$1' | `
    ForEach-Object{(Invoke-WebRequest -Uri "https://github.com/sakaztk/Jupyter-PowerShellSDK/releases/expanded_assets/$($_)" -UseBasicParsing).Links.href} | `
    Select-String -Pattern '.*PowerShell5.zip' | Get-Unique -AsString | ForEach-Object{Invoke-WebRequest -Uri "https://github.com$_" -UseBasicParsing -OutFile 'PowerShell5.zip'}
RUN Expand-Archive 'PowerShell5.zip' -DestinationPath (Join-Path (Split-Path (python -c 'import sys; print(sys.executable)') -Parent) '\Lib\site-packages\powershell5_kernel')
RUN New-Item -ItemType Directory -Path (Join-Path (Split-Path (python -c 'import sys; print(sys.executable)') -Parent) '\share\jupyter\kernels\powershell5')
RUN Split-Path (python -c 'import sys; print(sys.executable)') -Parent | Foreach-Object { `
    Write-Output ('{"""argv""":["""' + (Join-Path $_ '\Lib\site-packages\powershell5_kernel').replace('\','/') + '/Jupyter_PowerShell5.exe""","""{connection_file}"""], """display_name""": """PowerShell 5""","""language""": """Powershell"""}') | `
    Set-Content -Path (Join-Path $_ '\share\jupyter\kernels\powershell5\kernel.json') }
RUN Remove-Item 'PowerShell5.zip' -Force

RUN (Invoke-WebRequest -Uri 'https://github.com/sakaztk/Jupyter-PowerShellSDK/releases/latest' -UseBasicParsing -Headers @{'Accept'='application/json'}| ConvertFrom-Json).update_url -replace '.*tag/(.*)', '$1' | `
    ForEach-Object{(Invoke-WebRequest -Uri "https://github.com/sakaztk/Jupyter-PowerShellSDK/releases/expanded_assets/$($_)" -UseBasicParsing).Links.href} | `
    Select-String -Pattern '.*PowerShellSDK-.*.zip' | Get-Unique -AsString | ForEach-Object{Invoke-WebRequest -Uri "https://github.com$_" -UseBasicParsing -OutFile 'PowerShellSDK.zip'}
RUN Expand-Archive 'PowerShellSDK.zip' -DestinationPath (Join-Path (Split-Path (python -c 'import sys; print(sys.executable)') -Parent) '\Lib\site-packages\powershellSDK_kernel')
RUN New-Item -ItemType Directory -Path (Join-Path (Split-Path (python -c 'import sys; print(sys.executable)') -Parent) '\share\jupyter\kernels\powershellSDK')
RUN Split-Path (python -c 'import sys; print(sys.executable)') -Parent | Foreach-Object { `
    Write-Output ('{"""argv""":["""' + (Join-Path $_ '\Lib\site-packages\powershellSDK_kernel').replace('\','/') + '/Jupyter_PowerShellSDK.exe""","""{connection_file}"""], """display_name""": """PowerShell 7 (SDK)""","""language""": """Powershell"""}') | `
    Set-Content -Path (Join-Path $_ '\share\jupyter\kernels\powershellSDK\kernel.json') }
RUN Remove-Item 'PowerShellSDK.zip' -Force

EXPOSE 8888