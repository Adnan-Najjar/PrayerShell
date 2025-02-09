# PrayerShell

# Installation
Run these in PowerShell as Administrator
```powershell
git clone https://github.com/Adnan-Najjar/PrayerShell "$env:USERPROFILE\Documents\PowerShell\Scripts\PrayerShell"

# Get prayer times at startup
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-WindowStyle Hidden -ExecutionPolicy Bypass -File `"$env:USERPROFILE\Documents\PowerShell\Scripts\PrayerShell\src\Set-PrayerTimes.ps1`""
$trigger = New-ScheduledTaskTrigger -AtStartup
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "PrayerShell" -User "$env:USERNAME" -Description "Gets prayer times on startup" -RunLevel Limited -Settings $settings
."$env:USERPROFILE\Documents\PowerShell\Scripts\PrayerShell\src\Set-PrayerTimes.ps1"

```
