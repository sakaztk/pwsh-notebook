FROM jupyter/minimal-notebook:ubuntu-20.04

USER root

RUN apt-get update && apt-get install -y --no-install-recommends \
    software-properties-common \
    wget \
    git \
    openssl \
    ssh \
    supervisor \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Powershell / OMI / .Net SDK / .NET Interactive
RUN wget -q https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb \
 && dpkg -i packages-microsoft-prod.deb \
 && rm packages-microsoft-prod.deb

RUN add-apt-repository universe \
 && apt-get update \
 && apt-get install -y --no-install-recommends \
    apt-transport-https \
 && apt-get install -y --no-install-recommends \
    powershell \
    omi \
    dotnet-sdk-7.0 \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

RUN wget -q https://github.com/PowerShell/psl-omi-provider/releases/download/v1.4.2-2/psrp-1.4.2-2.universal.x64.deb \
 && dpkg -i psrp-1.4.2-2.universal.x64.deb \
 && rm psrp-1.4.2-2.universal.x64.deb

RUN dotnet tool install --global --add-source 'https://pkgs.dev.azure.com/dnceng/public/_packaging/dotnet-tools/nuget/v3/index.json' Microsoft.dotnet-interactive
ENV PATH $PATH:~/.dotnet/tools
RUN dotnet interactive jupyter install

# Powershell DSC Core
RUN wget https://github.com/microsoft/PowerShell-DSC-for-Linux/releases/download/v1.2.4-0/dsc-1.2.4-0.ssl_110.x64.deb --no-check-certificate \
 && dpkg -i dsc-1.2.4-0.ssl_110.x64.deb \
 && rm dsc-1.2.4-0.ssl_110.x64.deb

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

RUN pip --no-cache-dir install powershell_kernel && python -m powershell_kernel.install --powershell-command pwsh \
 && pip --no-cache-dir install bash_kernel && python -m bash_kernel.install --sys-prefix \
 && pip --no-cache-dir install -U traitlets \
 && pip --no-cache-dir install -U jupyter-client \ 
 && pip --no-cache-dir install jupyter_nbextensions_configurator && jupyter nbextensions_configurator enable \
 && pip --no-cache-dir install https://github.com/ipython-contrib/jupyter_contrib_nbextensions/tarball/master && jupyter contrib nbextension install

RUN pip --no-cache-dir install \
    https://github.com/ipython-contrib/jupyter_contrib_nbextensions/tarball/master \
    https://github.com/NII-cloud-operation/Jupyter-LC_nblineage/tarball/master \
    https://github.com/NII-cloud-operation/Jupyter-LC_run_through/tarball/master \
    https://github.com/NII-cloud-operation/Jupyter-LC_wrapper/tarball/master \
    git+https://github.com/NII-cloud-operation/Jupyter-multi_outputs \
    git+https://github.com/NII-cloud-operation/Jupyter-LC_index.git \
    git+https://github.com/NII-cloud-operation/Jupyter-LC_notebook_diff.git \
    git+https://github.com/NII-cloud-operation/sidestickies.git \
    git+https://github.com/NII-cloud-operation/nbsearch.git

RUN jupyter nbextension install --py lc_run_through --sys-prefix \
 && jupyter nbextension install --py lc_wrapper --sys-prefix \
 && jupyter nbextension install --py lc_multi_outputs --sys-prefix \
 && jupyter nbextension install --py notebook_index --sys-prefix \
 && jupyter nbextension install --py lc_notebook_diff --sys-prefix \
 && jupyter nbextension install --py nbtags --sys-prefix \
 && jupyter nbextension install --py nbsearch --sys-prefix \
 && jupyter nbextension install --py nblineage --sys-prefix

RUN echo '[supervisord]' >> /etc/supervisord.conf && \
    echo 'nodaemon=true' >> /etc/supervisord.conf && \
    echo '[program:sshd]' >> /etc/supervisord.conf && \
    echo 'command=/usr/sbin/sshd -D' >> /etc/supervisord.conf && \
    echo '[program:omid]' >> /etc/supervisord.conf && \
    echo 'command=/opt/omi/bin/omiserver' >> /etc/supervisord.conf && \
    echo '[program:notebook]' >> /etc/supervisord.conf && \
    echo "command=/opt/conda/bin/jupyter-notebook  --NotebookApp.token='' --allow-root" >> /etc/supervisord.conf

USER $NB_USER
