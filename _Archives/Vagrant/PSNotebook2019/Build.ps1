New-LocalUser -Name Notebook -Password (ConvertTo-SecureString 'P@ssw0rd' -AsPlainText -Force)

invoke-WebRequest `
    -Uri https://software-download.microsoft.com/download/sg/17763.379.190312-0539.rs5_release_svc_refresh_SERVER_EVAL_x64FRE_en-us.iso `
    -OutFile C:\ISO\WindowsServer2019\17763.379.190312-0539.rs5_release_svc_refresh_SERVER_EVAL_x64FRE_en-us.iso

New-VM -Name PSNotebook2019 -MemoryStartupBytes 2048MB -Path C:\VM\Hyper-V -SwitchName 'Default Switch'
New-VHD -Path 'C:\VM\Hyper-V\PSNotebook2019\Virtual Hard Disks\PSNotebook2019.vhd' -SizeBytes 64GB -Dynamic
Add-VMHardDiskDrive PSNotebook2019 -Path 'C:\VM\Hyper-V\PSNotebook2019\Virtual Hard Disks\PSNotebook2019.vhd'
Set-VMMemory PSNotebook2019 -DynamicMemoryEnabled $true
Set-VMProcessor PSNotebook2019 -Count 1
Set-VM PSNotebook2019 -AutomaticCheckpointsEnabled $False
Set-VMDvdDrive -VMName PSNotebook2019 -ControllerNumber 1 -Path C:\ISO\WindowsServer2019\17763.379.190312-0539.rs5_release_svc_refresh_SERVER_EVAL_x64FRE_en-us.iso
Start-VM PSNotebook2019


# WinRM
winrm quickconfig -q
winrm set winrm/config/winrs @{MaxMemoryPerShellMB="512"}
winrm set winrm/config @{MaxTimeoutms="1800000"}
winrm set winrm/config/service @{AllowUnencrypted="true"}
winrm set winrm/config/service/auth @{Basic="true"}


powershell
Rename-Computer -NewName "PSNotebook2019" -Force

# '複雑さの要件を満たす必要があるパスワード' 無効化
secedit /export /cfg c:\secpol.cfg
(Get-Content C:\secpol.cfg).replace("PasswordComplexity = 1", "PasswordComplexity = 0") | Out-File C:\secpol.cfg
secedit /configure /db c:\windows\security\local.sdb /cfg c:\secpol.cfg /areas SECURITYPOLICY
Remove-Item -force c:\secpol.cfg -confirm:$false

# Vagrantユーザーを作成してAdministratorsに追加
New-LocalUser -Name Vagrant -Password (ConvertTo-SecureString 'vagrant' -AsPlainText -Force)
Add-LocalGroupMember -Group Administrators -Member Vagrant

# UAC無効化
Set-ItemProperty -Path 'REGISTRY::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System' -Name ConsentPromptBehaviorAdmin -Value 0


# RDP有効化
cscript c:\windows\system32\scregedit.wsf /ar 0

# PowershellGetのインストール
Install-PackageProvider Nuget -Force
Install-Module -Name PowerShellGet -Force
Update-Module -Name PowerShellGet

New-NetFirewallRule `
-Name 'ICMPv4' `
-DisplayName 'ICMPv4' `
-Description 'Allow ICMPv4' `
-Profile Any `
-Direction Inbound `
-Action Allow `
-Protocol ICMPv4 `
-Program Any `
-LocalAddress Any `
-RemoteAddress Any 

# Python, Jupyter, Powershell kernel のインストール
Invoke-WebRequest -Uri https://www.python.org/ftp/python/3.7.4/python-3.7.4-amd64.exe -OutFile python.exe
.\python.exe /quiet InstallAllUsers=1 PrependPath=1 Include_test=0 Include_doc=0
Get-Process -Name python
Remove-Item python.exe
Restart-Computer

[User:vagrant]
pip install -U pip 
pip install jupyter
pip install powershell_kernel
python -m powershell_kernel.install

# notebookのポート空け
powershell
New-NetFirewallRule `
    -Name PowerShellRemoting-In `
    -DisplayName JupyterNotebook-In `
    -Description 'Default Port of Jupyter Notebook' `
    -Group 'Jupyter Notebook' `
    -Enabled True `
    -Profile Any `
    -Direction Inbound `
    -Action Allow `
    -EdgeTraversalPolicy Block `
    -LooseSourceMapping $False `
    -LocalOnlyMapping $False `
    -OverrideBlockRules $False `
    -Program Any `
    -LocalAddress Any `
    -RemoteAddress Any `
    -Protocol TCP `
    -LocalPort 8888 `
    -RemotePort Any `
    -LocalUser Any `
    -RemoteUser Any

jupyter notebook --generate-config
$configFile = 'C:\Users\Vagrant\.jupyter\jupyter_notebook_config.py'
Add-Content -Value 'c.NotebookApp.notebook_dir = ''C:\\Users\\Vagrant\\Notebooks''' -Path $configFile
Add-Content -Value 'c.NotebookApp.ip = ''*''' -Path $configFile
Add-Content -Value 'c.NotebookApp.open_browser = False' -Path $configFile
Add-Content -Value 'c.NotebookApp.notebook_dir = ''C:\\Vagrant\\Notebooks''' -Path $configFile
Add-Content -Value 'c.NotebookApp.password = ''''' -Path $configFile
Add-Content -Value 'c.NotebookApp.token = ''''' -Path $configFile

Get-Content 'C:\Users\Vagrant\.jupyter\jupyter_notebook_config.py'






# WinSxSのクリーンアップ
Dism.exe /online /Cleanup-Image /StartComponentCleanup /ResetBase

Stop-Computer



Export-VM -Name PSNotebook2019 -Path C:\Vagrant\Work
Remove-Item C:\Vagrant\Work\PSNotebook2019\Snapshots

$metadata = @'
{
    "name": "Sakoda/PSNotebooks2019",
    "provider": "hyperv"
}
'@ 
$metadata | Out-File -FilePath C:\Vagrant\Work\PSNotebook2019\metadata.json -Encoding default


Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::CreateFromDirectory('C:\Vagrant\Work\PSNotebook2019', 'C:\Vagrant\Work\PSNotebook2019.zip')
Remove-Item C:\Vagrant\Work\PSNotebook2019 -Recurse
Rename-Item -Path C:\Vagrant\Work\PSNotebook2019.zip -NewName PSNotebook2019.box
New-Item -Path C:\Vagrant\PSNotebook2019 -ItemType Directory
Move-Item -Path C:\Vagrant\Work\PSNotebook2019.box -Destination C:\Vagrant\PSNotebook2019\PSNotebook2019.box


Set-Location C:\Vagrant\PSNotebook2019
vagrant box add --name Sakoda/PSNotebook2019 PSNotebook2019.box

$vagrantfile = @'
Vagrant.configure("2") do |config|
    Encoding.default_external = 'UTF-8'
    config.vm.box = "Sakoda/PSNotebook2019"
    config.vm.guest = :windows
    config.vm.communicator = "winrm"
    config.vm.network :forwarded_port, guest: 3389, host: 13389
    config.vm.network :forwarded_port, guest: 5985, host: 15985, id: "winrm", auto_correct: true
    config.vm.synced_folder ".", "/Vagrant", type: "smb", smb_password: "P@ssw0rd", smb_username: "Notebook"
    config.vm.provision "shell", inline: <<-SHELL
        slmgr /rearm
    SHELL
    config.vm.provision "shell", run: "always", inline: <<-SHELL
        chcp 65001
        $jup = (cmd /c where jupyter-notebook)
        Invoke-Item $jup
    SHELL
end
'@
$vagrantfile | Out-File -FilePath C:\Vagrant\PSNotebook2019\Vagrantfile -Encoding utf8
vagrant up --provider=hyperv
