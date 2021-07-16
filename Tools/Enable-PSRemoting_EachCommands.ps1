Set-Item WSMan:\localhost\Client\TrustedHosts -Value '' -Force -PassThru
Start-Service -Name WinRM -PassThru
Disable-NetFirewallRule -Name WINRM-HTTP-In-TCP -PassThru
Disable-NetFirewallRule -Name WINRM-HTTP-In-TCP-NoScope -PassThru
Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System -Name LocalAccountTokenFilterPolicy -Value 1 -PassThru
