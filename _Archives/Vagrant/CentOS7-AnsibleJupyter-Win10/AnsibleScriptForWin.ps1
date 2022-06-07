$workDir = 'c:\work' + (Get-Date).ToString("yyyyMMddHHmmss")
New-Item -Path $workDir -ItemType Directory
Push-Location $workDir
Get-NetConnectionProfile | Set-NetConnectionProfile -NetworkCategory Private
Invoke-WebRequest -Uri https://raw.githubusercontent.com/ansible/ansible/devel/examples/scripts/ConfigureRemotingForAnsible.ps1 -OutFile ConfigureRemotingForAnsible.ps1
powershell -ExecutionPolicy RemoteSigned .\ConfigureRemotingForAnsible.ps1
Pop-Location
Remove-Item -Path $workDir -Recurse -Force
