# Configure PSRemoting over ssh on Powershell Core
$pwshVer = '7.0.0-rc.2'
$pwshPath = "c:\pwsh$pwshVer"

Invoke-WebRequest -Uri "https://github.com/PowerShell/PowerShell/releases/download/v$pwshVer/PowerShell-$pwshVer-win-x64.zip" -OutFile "pwsh.zip"
Expand-Archive -Path pwsh.zip -DestinationPath $pwshPath
Remove-Item "pwsh.zip"

Add-WindowsCapability -Online -Name (Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH.Server*').Name
Start-Service sshd
Stop-Service sshd
Push-Location $env:ProgramData\ssh
$fileContent = Get-Content .\sshd_config
$fileContent = $filecontent -replace '^#PubkeyAuthentication yes',"PubkeyAuthentication yes"
$fileContent = $filecontent -replace '^#PasswordAuthentication yes',"PasswordAuthentication yes"
$fileContent = $filecontent -replace "^# override default of no subsystems", "$&`nSubsystem powershell $pwshPath\pwsh.exe -sshs -NoLogo -NoProfile"
$filecontent | Set-Content .\sshd_config
Pop-Location
Set-Service -Name sshd -StartupType 'Automatic'
Start-Service sshd
