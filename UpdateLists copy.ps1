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

$encoding = [System.Text.Encoding]::UTF8
$useBasicParsing = $true

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
    $urls = (Get-Content $filePath -ReadCount 1000) -replace '^#.*',""
    $filesize = (Measure-Object -InputObject $urls).Count

    Write-Log -Message "File $filePath hat $filesize Einträge" -Severity Information -console $true

    # Entfernen Sie doppelte URLs und speichern Sie die Ergebnisse in einer neuen Liste
    $uniqueUrls = $urls | Sort-Object -Unique
    $filesize = (Measure-Object -InputObject $uniqueUrls).Count
    Write-Log -Message "File $filePath hat nach Entfernung der Duplikate $filesize Einträge" -Severity Information -console $true

    # Überschreiben Sie die ursprüngliche Datei mit den eindeutigen URLs
    Write-Log -Message "Starte Duplikats Prüfung $filePath " -Severity Information -console $true
    $discalamer | Out-File -FilePath $filePath -Encoding utf8
    Write-Log -Message "Disclamer zu $filePath hinzugefügt" -Severity Information -console $true
    $uniqueUrls | ForEach-Object { 
        Write-Progress -Activity "Optimierung $filePath" -Status "Schreibe Einträge" -PercentComplete (($_.Index / $filesize)*100) 
        $_ | Out-File -FilePath $filePath -Encoding utf8 -Append
    }

    # Berechnen Sie die Anzahl der gelöschten URLs
    $deletedUrlsCount = $urls.Count - $uniqueUrls.Count

    # Rückgabe der Anzahl der gelöschten URLs
    Write-Log -Message "Optimisirung abgeschlossen, in $filePath es wurden $deletedUrlsCount gefunden" -Severity Information -console $true
}

Write-Log -Message "Löschen aller Listen" -Severity Information -console $true
Remove-Item ".\Listen\*"
Write-Log -Message "Starte Update" -Severity Information -console $true

# Iterieren Sie über jede Kategorie
foreach ($category in $paths.Keys) {
    Write-Log -Message "Beginne mit dem Update von $category" -Severity Information -console $true
    # Laden Sie die URLs aus der Textdatei
    $urls = Get-Content $qPaths[$category]

    $disclaimer | Out-File -FilePath $paths[$category] -Encoding $encoding
    Write-Log -Message "Disclamer zu $($paths[$category]) hinzugefügt" -Severity Information -console $true

    # Iterieren Sie über jede URL
    foreach ($url in $urls) {
        # Herunterladen des Inhalts der URL
        Write-Log -Message "Abrufen der URL: $url" -Severity Information -console $true
        $content = Invoke-WebRequest -Uri $url -UseBasicParsing
        # Speichern des Inhalts in einer Datei
        $content.Content | Out-File -FilePath $paths[$category] -Append  -Encoding $encoding
        Write-Log -Message "Inhalte von $url in $($paths[$category]) geschrieben" -Severity Information -console $true

        }
    }


Write-Log -Message "Update Abgeschlossen" -Severity Information -console $true
Write-Log -Message "Zählen der URLs" -Severity Information -console $true

Start-optimize $Shops
Start-optimize $Tracking
Start-optimize $Jugendschutz
Start-optimize $Sonstiges
Start-optimize $Werbung
Start-optimize $Malware
Start-optimize $PuDS

$CountShops = (Get-Content -Path $Shops)
Write-Log -Message "Die Liste $Shops enthält $($CountShops.Count) URLs" -Severity Information -console $true

$CountTracking = (Get-Content -Path $Tracking)
Write-Log -Message "Die Liste $Tracking enthält $($CountTracking.Count) URLs" -Severity Information -console $true

$CountJugendschutz = (Get-Content -Path $Jugendschutz)
Write-Log -Message "Die Liste $Jugendschutz enthält $($CountJugendschutz.Count) URLs" -Severity Information -console $true

$CountSonstiges = (Get-Content -Path $Sonstiges)
Write-Log -Message "Die Liste $Sonstiges enthält $($CountSonstiges.Count) URLs" -Severity Information -console $true

$CountWerbung = (Get-Content -Path $Werbung)
Write-Log -Message "Die Liste $Werbung enthält $($CountWerbung.Count) URLs" -Severity Information -console $true

$CountMalware = (Get-Content -Path $Malware)
Write-Log -Message "Die Liste $Malware enthält $($CountMalware.Count) URLs" -Severity Information -console $true

$CountPuDS = (Get-Content -Path $PuDS)
Write-Log -Message "Die Liste $PuDS enthält $($CountPuDS.Count) URLs" -Severity Information -console $true

$sum = $CountShops.Count + $CountTracking.Count + $CountJugendschutz.Count + $CountSonstiges.Count + $CountWerbung.Count + $CountMalware.Count + $CountPuDS.Count
Write-Log -Message "Alles Listen Zusammen haben $sum URLs" -Severity Information -console $true