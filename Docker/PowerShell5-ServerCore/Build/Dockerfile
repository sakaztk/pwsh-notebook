FROM mcr.microsoft.com/windows/servercore:1909

ARG pythonUri=https://www.python.org/ftp/python/3.7.6/python-3.7.6-amd64.exe

SHELL ["powershell", "-Command", "$ErrorActionPreference='Stop'; $ProgressPreference='SilentlyContinue';"]

#PowershellGet
RUN Install-PackageProvider Nuget -Force; \
    Install-Module -Name PowerShellGet -Force; \
    Update-Module -Name PowerShellGet -Force

#WinRM
RUN Set-Item WSMan:\localhost\Client\TrustedHosts -Value '*' -Force

#CodePage
RUN New-Item -Path 'HKLM:\SOFTWARE\Microsoft\Command Processor' -Force; \
    Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Command Processor' -Name AutoRun -Value '@chcp 65001>null'

#Python
RUN Invoke-WebRequest -Uri $env:pythonUri -OutFile c:\python.exe; \
    Start-Job -ScriptBlock {& 'c:\python.exe' /quiet InstallAllUsers=1 PrependPath=1 Include_test=0 Include_doc=0} | Wait-Job
RUN    Start-Sleep 5; Remove-Item c:\python.exe

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

RUN Dism /online /Cleanup-Image /StartComponentCleanup /ResetBase

EXPOSE 8888
