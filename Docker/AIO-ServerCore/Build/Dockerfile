FROM mcr.microsoft.com/windows/servercore:1909-KB4528760
SHELL ["powershell", "-Command", "$ErrorActionPreference='Stop'; $ProgressPreference='SilentlyContinue';"]

#WinRM
RUN Set-Item WSMan:\localhost\Client\TrustedHosts -Value '*' -Force

#CodePage
RUN New-Item -Path 'HKLM:\SOFTWARE\Microsoft\Command Processor' -Force; \
    Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Command Processor' -Name AutoRun -Value '@chcp 65001>null'

#PowershellGet
RUN Install-PackageProvider Nuget -Force; \
    Install-Module -Name PowerShellGet -Force; \
    Update-Module -Name PowerShellGet -Force

#ChocolateyGet
RUN Install-PackageProvider -Name ChocolateyGet -Force
RUN @( \
    'python', \
    'powershell-core', \
    'powershell-preview', \
    'dotnetcore-sdk' \
    ) | Foreach-Object {Install-Package -Provider ChocolateyGet -Name $_ -Force}

#Jupyter
USER ContainerAdministrator

RUN pip install jupyter; \
    pip install jupyterhub; \
    pip install jupyterlab; \
    pip install powershell_kernel; \
    pip install jupyter_nbextensions_configurator; \
    jupyter nbextensions_configurator enable; \
    pip install https://github.com/ipython-contrib/jupyter_contrib_nbextensions/tarball/master; \
    jupyter contrib nbextension install; \
    python -m powershell_kernel.install

RUN dotnet tool install --global Microsoft.dotnet-interactive
RUN $env:Path += ';C:\Users\ContainerAdministrator\.dotnet\tools'
RUN dotnet interactive jupyter install

RUN New-Item C:\Users\ContainerAdministrator\AppData\Roaming\jupyter\kernels\powershell6/ -ItemType Directory -Force; \
    New-Item C:\Users\ContainerAdministrator\AppData\Roaming\jupyter\kernels\powershell7/ -ItemType Directory -Force
COPY kernel-pwsh6.json C:\\Users\\ContainerAdministrator\\AppData\\Roaming\\jupyter\\kernels\\powershell6\\kernel.json
COPY kernel-pwsh7.json C:\\Users\\ContainerAdministrator\\AppData\\Roaming\\jupyter\\kernels\\powershell7\\kernel.json
RUN Copy-Item -Path 'C:\Program Files\PowerShell\7-preview\preview\pwsh-preview.cmd' -Destination 'C:\Program Files\PowerShell\7-preview\preview\pwsh7.cmd' -Force

EXPOSE 8888
