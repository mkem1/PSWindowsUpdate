# This script is to export WSUS infos using PSRemoting and PsWindowsUpdate module and export it to a CSV file

# Check if the current user has administrative privileges
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    # If not, launch a new instance of PowerShell with elevated privileges
    Start-Process PowerShell.exe "-File `"$PSCommandPath`"" -Verb runAs
    # Exit the script
    exit
}

# Import the required modules
Import-Module PSWindowsUpdate

# Define the list of remote computers
$computers = "COMPUTER1", "COMPUTER2", "COMPUTER3"

# Define the output file path
$outputFile = "C:\scripts\powershell\wsus\result1.csv"

# Create an empty array to store the output
$output = @()

# Loop through each remote computer
foreach ($computer in $computers) {
  # Try to establish a remote session with the computer
  Try {
    $session = New-PSSession -ComputerName $computer
  }
  Catch {
    Write-Error "Failed to establish a session with $computer. Error: $_"
    continue
  }
  # Get the Windows Update settings for the remote computer
  $settings = Invoke-Command -Session $session -ScriptBlock { Get-WUSettings }

  # Get the list of available updates for the remote computer
  $updates = Invoke-Command -Session $session -ScriptBlock { Get-WindowsUpdate }  

  # Check if there are updates in the history
  if ($updates) {
   # Add the output for the current computer to the overall output array
  foreach ($update in $updates) {
    $output += New-Object PSObject -Property @{
    ComputerName = $computer
    WUServer = $settings.WUServer
    WUStatusServer = $settings.WUStatusServer
    UpdateServiceUrlAlternate = $settings.UpdateServiceUrlAlternate
    SetProxyBehaviorForUpdateDetection = $settings.SetProxyBehaviorForUpdateDetection
    NoAutoUpdate = $settings.NoAutoUpdate
    AUOptions = $settings.AUOptions
    ScheduledInstallDay = $settings.ScheduledInstallDay
    ScheduledInstallTime = $settings.ScheduledInstallTime
    DetectionFrequencyEnabled = $settings.DetectionFrequencyEnabled
    DetectionFrequency = $settings.DetectionFrequency
    UseWUServer = $settings.UseWUServer
    NoAutoRebootWithLoggedOnUsers = $settings.NoAutoRebootWithLoggedOnUsers
    Updates = $update.Title
    Size = $update.Size 
    KB = $update.KBArticleIDs
      }
    }
  } else {
    # Add a row to the overall output array indicating that there are no updates for the current computer
    $output += New-Object PSObject -Property @{
      ComputerName = $computer
      WUServer = $settings.WUServer
      WUStatusServer = $settings.WUStatusServer
      UpdateServiceUrlAlternate = $settings.UpdateServiceUrlAlternate
      SetProxyBehaviorForUpdateDetection = $settings.SetProxyBehaviorForUpdateDetection
      NoAutoUpdate = $settings.NoAutoUpdate
      AUOptions = $settings.AUOptions
      ScheduledInstallDay = $settings.ScheduledInstallDay
      ScheduledInstallTime = $settings.ScheduledInstallTime
      DetectionFrequencyEnabled = $settings.DetectionFrequencyEnabled
      DetectionFrequency = $settings.DetectionFrequency
      UseWUServer = $settings.UseWUServer
      NoAutoRebootWithLoggedOnUsers = $settings.NoAutoRebootWithLoggedOnUsers
      Updates = "No updates available"
      Size = "" 
      KB = ""
    }
  }

  # Remove the remote session
Remove-PSSession $session
}

# Select the properties to display
$output | Select-Object ComputerName, WUServer, WUStatusServer, UpdateServiceUrlAlternate, SetProxyBehaviorForUpdateDetection, NoAutoUpdate, AUOptions, ScheduledInstallDay, ScheduledInstallTime, DetectionFrequencyEnabled, DetectionFrequency, UseWUServer, NoAutoRebootWithLoggedOnUsers, Updates, Size, KB |

# Export the output to a CSV file
Export-Csv $outputFile -NoTypeInformation | Out-Null
