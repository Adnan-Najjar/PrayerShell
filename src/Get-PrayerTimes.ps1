$scriptDir = "$env:USERPROFILE\Documents\PowerShell\Scripts\PrayerShell"

$city =  (Invoke-RestMethod -Uri "https://ipinfo.io/json" -ErrorAction Stop).city

$userAgents = @(
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/93.0.4577.63 Safari/537.36",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:92.0) Gecko/20100101 Firefox/92.0",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/93.0.961.38 Safari/537.36 Edg/93.0.961.38",
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Safari/605.1.15",
    "Mozilla/5.0 (Linux; Android 10; Pixel 3 XL Build/QP1A.190711.020) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/93.0.4577.62 Mobile Safari/537.36",
    "Mozilla/5.0 (iPhone; CPU iPhone OS 14_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0 Mobile/15E148 Safari/604.1",
    "Mozilla/5.0 (Android 10; Mobile; LG-M255 Build/QKQ1W) Gecko/68.0 Firefox/68.0.1",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/93.0.4577.63 Opera/79.0.3945.88",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64; Trident/7.0; AS; rv:11.0) like Gecko"
)

$ddgSearch = $(Invoke-RestMethod -Uri "https://html.duckduckgo.com/html/?q=$($city)%20site:muslimpro.com%20inurl:en" -Headers @{ "User-Agent" = $(Get-Random -InputObject $userAgents) })

$countryID = $($ddgSearch | Select-String -Pattern "(?<=uddg=.*)(?<=%2D).{5,10}(?=&)" | Select-Object -ExpandProperty Matches -First 1 -Unique | Select-Object -ExpandProperty Value)

$muslimProTimes = $(Invoke-RestMethod -Uri "https://prayer-times.muslimpro.com/muslimprowidget.js?cityid=$countryID" -Headers @{ "User-Agent" = $(Get-Random -InputObject $userAgents) })

$prayerTimes = $($muslimProTimes | ForEach-Object { $_ -replace "</td><td>"," " -replace "&#39;","" } | Select-String -Pattern "(?<=<td>).{8,15}(?=</td>)" -AllMatches | ForEach-Object {
    $parts = $_.Matches.Value -split " "
    $name = $parts[0]; $time = $parts[1]
    $prayerTimes[$name] = $time
  }
)

if ($prayerTimes) {
	$prayerTimes | Export-Clixml -Path "$scriptDir\PrayerTimes\prayerTimes$(Get-Date -Format "_%d-%M").xml"
} else {
	New-BurntToastNotification -Text 'Error in getting prayer time data!' -Applogo "$scriptDir\assets\Athaan.png"
}