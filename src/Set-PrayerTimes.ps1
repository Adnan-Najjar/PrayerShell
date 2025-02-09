# Define Script location
$prayerShellPath = "$env:USERPROFILE\Documents\PowerShell\Scripts\PrayerShell"

# Install BurntToast library if it doesn't exist
if (-not (Get-Module -ListAvailable -Name BurntToast)) {
  Install-PackageProvider -Name NuGet
  Install-Module -Name BurntToast -Force -Scope CurrentUser
}

# Import prayer times if it exists
# Otherwise, runs Get-PrayerTimes script to get them
try {
  $prayerTimes = $(Import-Clixml -Path "$PrayerShellPath\PrayerTimes\prayerTimes$(Get-Date -Format "_%d-%M").xml")
} catch {
  if ($_.Exception.Message -like "*Could not find file*") { 
    try {
      Start-Process powershell.exe -ArgumentList "-WindowStyle Hidden -ExecutionPolicy Bypass -File `"$PrayerShellPath\src\Get-PrayerTimes.ps1`"" -Wait
    } catch {
      exit 1
    }
  } else {
    New-BurntToastNotification -Text "Something went Wrong!" -Applogo "$PrayerShellPath\assets\Athaan.png"
    exit 1
  }
}

# Unregister old notifications before adding new ones
Get-ScheduledTask | Where-Object { $_.TaskName -like "*PTNotification" } | ForEach-Object { Unregister-ScheduledTask -TaskName $_.TaskName -Confirm:$false }

# Allow the script to run on battery
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries

# Register prayer times as tasks for the day
$prayerTimes.GetEnumerator() | ForEach-Object {
  $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-WindowStyle Hidden -ExecutionPolicy Bypass -File `"$PrayerShellPath\src\Notify.ps1`" -PrayerName $_.Key"
  $trigger = New-ScheduledTaskTrigger -At $_.Value -Once
  Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "$($_.Key)PTNotification" -User $env:USERNAME -RunLevel Limited -Settings $settings
}
