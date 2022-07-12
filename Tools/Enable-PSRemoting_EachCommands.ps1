Set-Service -Name WinRM -StartupType Automatic -PassThru
Start-Service -Name WinRM -PassThru
Enable-NetFirewallRule -Name WINRM-HTTP-In-TCP -PassThru
Enable-NetFirewallRule -Name WINRM-HTTP-In-TCP-NoScope -PassThru
New-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System -Name LocalAccountTokenFilterPolicy -PropertyType DWord -Value 1 -Force
