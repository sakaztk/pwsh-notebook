Set-Service -Name WinRM -StartupType Manual -PassThru
Stop-Service -Name WinRM -PassThru
Disable-NetFirewallRule -Name WINRM-HTTP-In-TCP -PassThru
Disable-NetFirewallRule -Name WINRM-HTTP-In-TCP-NoScope -PassThru
Remove-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System -Name LocalAccountTokenFilterPolicy -Force