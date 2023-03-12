# Script to check Windows Server Update Services status

To get all infos about WSUS

``Get-WUSettings``

To acces remote machines

``-ComputerName``

List all updates available

``Get-WindowsUpdate``

Show updates history

``Get-WUHistory``

Reset Windows Update, remove Windows Update local cache , re register libraries (DLL), remove logs, etc

``Reset-WUComponents -Verbose``

Get PS Modules path

``($env:PSModulePath -split ';')``

WinRM: To use the "-ComputerName" option, WinRM service need to be running, to check

``Get-Service WinRM``

``winrm quickconfig``

If not

``Enable-PSRemoting``

How to open a remote PS Session

``Enter-PSSession -ComputerName HOSTNAME -Credential "HOSTNAME\USERNAME"``

Check reboot status

``Get-WURebootStatus``

Install all available updates and auto reboot after

``Install-WindowsUpdate -AcceptAll -AutoReboot``
