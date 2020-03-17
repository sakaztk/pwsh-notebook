FROM jupyter/minimal-notebook

USER root

RUN apt-get update && apt-get install -y --no-install-recommends \
    software-properties-common \
    wget \
    openssl \
    ssh \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Powershell 6,7 / OMI / .Net SDK / .NET Interactive
RUN wget -q https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb \
 && dpkg -i packages-microsoft-prod.deb \
 && rm packages-microsoft-prod.deb

RUN add-apt-repository universe \
 && apt-get update \
 && apt-get install -y --no-install-recommends apt-transport-https \
 && apt-get update \
 && apt-get install -y --no-install-recommends \
    powershell \
    omi \
    dotnet-sdk-3.1 \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

RUN wget -q https://github.com/PowerShell/PowerShell/releases/download/v6.2.4/powershell_6.2.4-1.ubuntu.18.04_amd64.deb \
 && dpkg-deb -x powershell_6.2.4-1.ubuntu.18.04_amd64.deb / \
 && ln -s /opt/microsoft/powershell/6/pwsh /usr/bin/pwsh6 \
 && rm powershell_6.2.4-1.ubuntu.18.04_amd64.deb

RUN dotnet tool install --global Microsoft.dotnet-interactive
ENV PATH $PATH:~/.dotnet/tools
RUN dotnet interactive jupyter install

# Powershell DSC Core
RUN wget https://github.com/microsoft/PowerShell-DSC-for-Linux/releases/download/v1.1.1-926/dsc-1.1.1-926.ssl_110.x64.deb --no-check-certificate \
 && dpkg -i dsc-1.1.1-926.ssl_110.x64.deb \
 && rm dsc-1.1.1-926.ssl_110.x64.deb

# Configure SSH
RUN ssh-keygen -A \
 && mkdir -p /run/sshd \
 && sed -i 's/^#PubkeyAuthentication yes/PubkeyAuthentication yes/g' /etc/ssh/sshd_config \
 && sed -i 's/^PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config \
 && sed -i '/# override default of no subsystems/a Subsystem powershell /usr/bin/pwsh -sshs -NoLogo -NoProfile' /etc/ssh/sshd_config

# Jupyter Notebook
RUN pip install powershell_kernel && python -m powershell_kernel.install --powershell-command pwsh \
 && pip install bash_kernel && python -m bash_kernel.install \
 && pip install jupyter_nbextensions_configurator && jupyter nbextensions_configurator enable \
 && pip install https://github.com/ipython-contrib/jupyter_contrib_nbextensions/tarball/master && jupyter contrib nbextension install

RUN fix-permissions /home/$NB_USER

RUN mkdir -p /usr/local/bin/start-notebook.d
COPY start.sh /usr/local/bin/start-notebook.d
RUN mkdir -p /usr/local/share/jupyter/kernels/powershell6
COPY kernel-pwsh6.json /usr/local/share/jupyter/kernels/powershell6/kernel.json

USER $NB_USER
