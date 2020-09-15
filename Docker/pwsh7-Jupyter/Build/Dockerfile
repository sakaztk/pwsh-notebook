FROM jupyter/minimal-notebook:dd2087c75645

USER root

RUN apt-get update && apt-get install -y --no-install-recommends \
    software-properties-common \
    wget \
    openssl \
    ssh \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Powershell Core / OMI / .Net Core Runtime
RUN wget -q https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb \
 && dpkg -i packages-microsoft-prod.deb \
 && rm packages-microsoft-prod.deb

RUN add-apt-repository universe \
 && apt-get update \
 && apt-get install -y --no-install-recommends \
   apt-transport-https \
 && apt-get install -y --no-install-recommends \
    powershell \
    omi \
    dotnet-runtime-3.1 \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*
 
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
RUN apt-get update && apt-get install -y --no-install-recommends \
    nodejs \
    npm \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*
RUN pip install powershell_kernel && python -m powershell_kernel.install --powershell-command pwsh \
 && pip install bash_kernel && python -m bash_kernel.install \
 && pip install jupyter_nbextensions_configurator && jupyter nbextensions_configurator enable \
 && pip install https://github.com/ipython-contrib/jupyter_contrib_nbextensions/tarball/master && jupyter contrib nbextension install

RUN fix-permissions /home/$NB_USER

RUN mkdir -p /usr/local/bin/start-notebook.d
ADD start.sh /usr/local/bin/start-notebook.d

USER $NB_USER
