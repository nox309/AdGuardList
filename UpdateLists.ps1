<#
.NAME
    PS Data Template
.SYNOPSIS
    Short description what does the script exactly.
.DESCRIPTION
    Detailed description of the script, with everything that belongs to it
.FUNCTIONALITY
    how does the script work
.NOTES
    Author: nox309
    Email: support@inselmann.it
    Git: https://github.com/nox309
    Version: 1.0
    DateCreated: 2022/05/01
.EXAMPLE
    Get-Something -UserPrincipalName "username@thesysadminchannel.com"
.LINK
    https://github.com/nox309/Projekt-Template/
#>

#---------------------------------------------------------[Initialisations]--------------------------------------------------------

# Definition der Parameter
Param(
    [bool]$Autoupdate = $False
)

$paths = @{
    "Tracking" = ".\Listen\Tracking.txt"
    "Shops" = ".\Listen\FakeshopsAboFallen.txt"
    "Jugendschutz" = ".\Listen\Jugendschutz.txt"
    "Sonstiges" = ".\Listen\Sonstiges.txt"
    "Werbung" = ".\Listen\Werbung.txt"
    "Malware" = ".\Listen\Malware.txt"
    "PuDS" = ".\Listen\Phishing_Domain-Squatting.txt"
    }

$qPaths = @{
    "Shops" = ".\Quellen\Fakeshops_AboFallen.txt"
    "Tracking" = ".\Quellen\Tracking.txt"
    "Jugendschutz" = ".\Quellen\Jugendschutz.txt"
    "Sonstiges" = ".\Quellen\Sonstiges.txt"
    "Werbung" = ".\Quellen\Werbung.txt"
    "Malware" = ".\Quellen\Malware.txt"
    "PuDS" = ".\Quellen\Fakeshops_AboFallen.txt"
    }
    
$disclaimer = "
#. Alle Listen des Projekts AdGuardList sind selbst erstellte Listen, basierend auf Grunddaten 
#. aus verschiedenen Quellen. Hier werden div. Listen in einer Großen zusammen gefast um diese besser
#. in Adgurard pflegen zu können. Die Quell Listen finden sie unter: 
#.
#.
#. 
"

$logpath = ".\Update.log"



function Write-Log {
    [CmdletBinding()]
    param(
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Message,

        [parameter(Mandatory=$false)]
        [bool]$console, 

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Information','Warning','Error','Debug')]
        [string]$Severity = 'Information'
    )

    $time = (get-date -Format yyyyMMdd-HH:mm:ss)

    if (!(Test-Path $logpath)) {
        "Timestamp | Severity | Message" | Out-File -FilePath $logpath -Append  -Encoding utf8
        "$Time | Information | Log started" | Out-File -FilePath $logpath -Append  -Encoding utf8
    }

    if ($console) {
        if ($Severity -eq "Information") {
            $color = "Gray"
        }

        if ($Severity -eq "Warning") {
            $color = "Yellow"
        }

        if ($Severity -eq "Error") {
            $color = "Red"
        }

        if ($Severity -eq "Debug") {
            $color = "Green"
        }

        Write-Host -ForegroundColor $color "$Time | $Severity | $Message"
    }

    "$Time | $Severity | $Message" | Out-File -FilePath $logpath -Append  -Encoding utf8

}

Function Start-optimize {
    param($filePath)
    
    Write-Log -Message "Starte Optimierung von $filePath " -Severity Information -console $true

    # Lesen Sie die URLs aus der Datei in eine Liste
    $urls = (Get-Content $filePath) -replace '^#.*',""
    #$filesize = (Measure-Object -InputObject $urls).Count

    # Entfernen Sie doppelte URLs und speichern Sie die Ergebnisse in einer neuen Liste
    $uniqueUrls = $urls | Sort-Object -Unique
    #$filesize = (Measure-Object -InputObject $uniqueUrls).Count

    # Überschreiben Sie die ursprüngliche Datei mit den eindeutigen URLs
    $disclaimer | Out-File -FilePath $filePath -Encoding utf8
    Write-Log -Message "Disclamer zu $filePath hinzugefügt" -Severity Information -console $true
    Write-Log -Message "Schreibe die Optimirten URLs in $filePath " -Severity Information -console $true
    $uniqueUrls | Out-File -FilePath $filePath -Append -Encoding utf8

    # Berechnen Sie die Anzahl der gelöschten URLs
    $deletedUrlsCount = $urls.Count - $uniqueUrls.Count
    $count = $uniqueUrls.Count
    $sum += $count

    # Rückgabe der Anzahl der gelöschten URLs
    Write-Log -Message "Die Liste $filePath enthält $($uniqueUrls.Count) URLs" -Severity Information -console $true
    Write-Log -Message "Optimisirung abgeschlossen, in $filePath es wurden $deletedUrlsCount Doppelte URLs gefunden" -Severity Information -console $true
}

Write-Log -Message "Listen Update wird gestatet mit Git Auto Update = $Autoupdate" -Severity Information -console $true
Write-Log -Message "Löschen aller Listen" -Severity Information -console $true
Remove-Item ".\Listen\*"
Write-Log -Message "Starte Update" -Severity Information -console $true

# Iterieren Sie über jede Kategorie
foreach ($category in $paths.Keys) {
    Write-Log -Message "Beginne mit dem Update von $category" -Severity Information -console $true
    # Laden Sie die URLs aus der Textdatei
    $urls = Get-Content $qPaths[$category]

    #$disclaimer | Out-File -FilePath $paths[$category] -Encoding utf8
    #Write-Log -Message "Disclamer zu $($paths[$category]) hinzugefügt" -Severity Information -console $true

    # Iterieren Sie über jede URL
    foreach ($url in $urls) {
        # Herunterladen des Inhalts der URL
        Write-Log -Message "Abrufen der URL: $url" -Severity Information -console $true
        $content = Invoke-WebRequest -Uri $url -UseBasicParsing
        # Speichern des Inhalts in einer Datei
        $content.Content | Out-File -FilePath $paths[$category] -Append  -Encoding utf8
        Write-Log -Message "Inhalte von $url in $($paths[$category]) geschrieben" -Severity Information -console $true

        }
    }

foreach ($sourcepath in $paths.Values) {
        Start-optimize $sourcepath
    }


Write-Log -Message "Update Abgeschlossen" -Severity Information -console $true
Write-Log -Message "Zählen aller URLs" -Severity Information -console $true
Write-Log -Message "Alles Listen Zusammen haben $sum URLs" -Severity Information -console $true

<#
$CountShops = (Get-Content -Path $paths.Shops)
Write-Log -Message "Die Liste $($paths.Shops) enthält $($CountShops.Count) URLs" -Severity Information -console $true

$CountTracking = (Get-Content -Path $paths.Tracking)
Write-Log -Message "Die Liste $($paths.Tracking) enthält $($CountTracking.Count) URLs" -Severity Information -console $true

$CountJugendschutz = (Get-Content -Path $paths.Jugendschutz)
Write-Log -Message "Die Liste $($paths.Jugendschutz) enthält $($CountJugendschutz.Count) URLs" -Severity Information -console $true

$CountSonstiges = (Get-Content -Path $paths.Sonstiges)
Write-Log -Message "Die Liste $($paths.Sonstiges) enthält $($CountSonstiges.Count) URLs" -Severity Information -console $true

$CountWerbung = (Get-Content -Path $paths.Werbung)
Write-Log -Message "Die Liste $($paths.Werbung) enthält $($CountWerbung.Count) URLs" -Severity Information -console $true

$CountMalware = (Get-Content -Path $paths.Malware)
Write-Log -Message "Die Liste $($paths.Malware) enthält $($CountMalware.Count) URLs" -Severity Information -console $true

$CountPuDS = (Get-Content -Path $paths.PuDS)
Write-Log -Message "Die Liste $($paths.PuDS) enthält $($CountPuDS.Count) URLs" -Severity Information -console $true

$sum = $CountShops.Count + $CountTracking.Count + $CountJugendschutz.Count + $CountSonstiges.Count + $CountWerbung.Count + $CountMalware.Count + $CountPuDS.Count
Write-Log -Message "Alles Listen Zusammen haben $sum URLs" -Severity Information -console $true




$filePaths = @("$($paths.Shops)", "$($paths.Tracking)", "$($paths.Jugendschutz)", "$($paths.Sonstiges)", "$($paths.Werbung)", "$($paths.Malware)", "$($paths.PuDS)")

$sum = 0

foreach ($filePath in $filePaths) {
    $count = (Get-Content -Path $filePath).Count
    $sum += $count
    Write-Log -Message "Die Liste $filePath enthält $count URLs" -Severity Information -console $true
}

Write-Log -Message "Alles Listen Zusammen haben $sum URLs" -Severity Information -console $true
#>


if ($Autoupdate) {
    Write-Log -Message "Git Autoupdate wird ausgeführt" -Severity Information -console $true
    git add .
    git commit -m "Auto Update"
    git push
    Write-Log -Message "Git Autoupdate abgeschlossen alles auf dem Aktuellen Stand" -Severity Information -console $true

}
else {
    Write-Log -Message "Autoupdate übersprungen" -Severity Warning -console $true
}