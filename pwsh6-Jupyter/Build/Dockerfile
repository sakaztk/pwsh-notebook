FROM jupyter/minimal-notebook

USER root

RUN apt-get update && apt-get install -y --no-install-recommends \
    software-properties-common \
    curl \
    wget \
    openssl \
    ssh \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Powershell Core & OMI
RUN wget -q https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb \
 && dpkg -i packages-microsoft-prod.deb \
 && add-apt-repository universe \
 && rm packages-microsoft-prod.deb

RUN apt-get update && apt-get install -y --no-install-recommends \
    powershell \
    omi \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Powershell DSC Core
RUN wget https://github.com/microsoft/PowerShell-DSC-for-Linux/releases/download/v1.1.1-926/dsc-1.1.1-926.ssl_110.x64.deb --no-check-certificate \
 && dpkg -i dsc-1.1.1-926.ssl_110.x64.deb \
 && rm dsc-1.1.1-926.ssl_110.x64.deb

# .Net Core Runtime
ENV DOTNET_VERSION 3.0.1
RUN curl -SL --output dotnet.tar.gz https://dotnetcli.azureedge.net/dotnet/Runtime/$DOTNET_VERSION/dotnet-runtime-$DOTNET_VERSION-linux-x64.tar.gz \
 && dotnet_sha512='d84192fd20ff09e6bc00eca37c6e5d2c5025c7a0fd93644a1dc4e4f0fc7322689dd8ee7b331352c568b999a7ebcd909c0893abf455da354b23119334378615ca' \
 && echo "$dotnet_sha512 dotnet.tar.gz" | sha512sum -c - \
 && mkdir -p /usr/share/dotnet \
 && tar -zxf dotnet.tar.gz -C /usr/share/dotnet \
 && rm dotnet.tar.gz \
 && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet

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
ADD start.sh /usr/local/bin/start-notebook.d

USER $NB_USER
