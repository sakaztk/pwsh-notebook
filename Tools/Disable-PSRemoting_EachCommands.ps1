Set-Item WSMan:\localhost\Client\TrustedHosts -Value '' -Force -PassThru
Stop-Service -Name WinRM -PassThru
Disable-NetFirewallRule -Name WINRM-HTTP-In-TCP -PassThru
Disable-NetFirewallRule -Name WINRM-HTTP-In-TCP-NoScope -PassThru
Remove-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System -Name LocalAccountTokenFilterPolicy -Force