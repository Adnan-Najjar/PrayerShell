$scriptDir = "$HOME\Documents\PowerShell\Scripts\PrayerShell"

# whoami
$user = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name

$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries

$prayerTimes = $(Import-Clixml -Path "$scriptDir\PrayerTimes\prayerTimes$(Get-Date -Format "_%d-%M").xml")
if (-not ($prayerTimes)) {
  Start-Process powershell.exe -ArgumentList "-WindowStyle Hidden -ExecutionPolicy Bypass -File `"$scriptDir\src\Get-PrayerTimes.ps1`""
}

$prayerTimes.GetEnumerator() | ForEach-Object {
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-WindowStyle Hidden -ExecutionPolicy Bypass -File `"$scriptDir\src\Notify.ps1`" -PrayerName $_.Key"
  $trigger = New-ScheduledTaskTrigger -At $_.Value -Once
  Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "$($_.Key)Notification" -User $user -RunLevel Limited -Settings $settings
}