$scriptDir = "$HOME\Documents\PowerShell\Scripts\PrayerShell"

Get-ScheduledTask | Where-Object { $_.TaskName -like "*Notification" } | ForEach-Object { Unregister-ScheduledTask -TaskName $_.TaskName -Confirm:$false }

& "$scriptDir\src\Set-PrayerTimes.ps1"