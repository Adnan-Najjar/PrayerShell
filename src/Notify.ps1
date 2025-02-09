param (
[string]$PrayerName
)

$scriptDir = "$env:USERPROFILE\Documents\PowerShell\Scripts\PrayerShell"

$prayerTimes = $(Import-Clixml -Path "$scriptDir\PrayerTimes\prayerTimes$(Get-Date -Format "_%d-%M").xml")
if (-not ($prayerTimes)) {
  Start-Process powershell.exe -ArgumentList "-WindowStyle Hidden -ExecutionPolicy Bypass -File `"$scriptDir\src\Get-PrayerTimes.ps1`""
}

if (-not (Get-Module -ListAvailable -Name BurntToast)) {
  Install-PackageProvider -Name NuGet
  Install-Module -Name BurntToast -Force -Scope CurrentUser
}

(New-Object Media.SoundPlayer "$scriptDir\Athaan.wav").Play();
New-BurntToastNotification -Text "It is $PrayerName time" -Applogo "$scriptDir\assets\Athaan.png"
Start-Sleep -Seconds 6.5
(New-Object Media.SoundPlayer "$scriptDir\assets\Athaan.wav").Stop();

Unregister-ScheduledTask -TaskName "$($PrayerName)Notification" -Confirm:$false
