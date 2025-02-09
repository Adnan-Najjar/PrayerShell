# Takes prayer name as an argument for sending notification
param ([string]$PrayerName)

# Define Script location
$prayerShellPath = "$env:USERPROFILE\Documents\PowerShell\Scripts\PrayerShell"

# Import prayer times if it exists
# Otherwise, runs Get-PrayerTimes script to get them
try {
  $prayerTimes = $(Import-Clixml -Path "$PrayerShellPath\PrayerTimes\prayerTimes$(Get-Date -Format "_%d-%M").xml")
} catch {
  if ($_.Exception.Message -like "*Could not find file*") { 
    Start-Process powershell.exe -ArgumentList "-WindowStyle Hidden -ExecutionPolicy Bypass -File `"$PrayerShellPath\src\Get-PrayerTimes.ps1`""
  } else {
    New-BurntToastNotification -Text "Something went Wrong!" -Applogo "$PrayerShellPath\assets\Athaan.png"
    exit 1
  }
}

# Play Athaan Sound and Send a notification
(New-Object Media.SoundPlayer "$PrayerShellPath\assets\Athaan.wav").Play();
New-BurntToastNotification -Text "It is $PrayerName time" -Applogo "$PrayerShellPath\assets\Athaan.png"
# Wait for the sound to finish, then stop it
Start-Sleep -Seconds 6.5
(New-Object Media.SoundPlayer "$PrayerShellPath\assets\Athaan.wav").Stop();

# Unregister the prayer notification
Unregister-ScheduledTask -TaskName "$($PrayerName)PTNotification" -Confirm:$false
