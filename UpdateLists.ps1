<#
.NAME
    AdGuardList Updatelist
.SYNOPSIS
    Updatet die zusammen gefasten Listen
.DESCRIPTION
    Diese Script läd sich aus div. Listen die zu Blockierenden Domains herrunter und Speichert diese in einer gorßen Liste je Kategorie.
.FUNCTIONALITY
    Nach dem Herrunterladen der Daten, werden diese in eine Datei geladen und anschliesend auf Dubletten überprüft, so kommt am ende eine große Liste die Möglichst optimiert ist raus.
.NOTES
    Author: nox309
    Email: support@inselmann.it
    Git: https://github.com/nox309
    Version: 1.0
    DateCreated: 202/05/01
.EXAMPLE
    .\UpdateLists.ps1 -Autoupdate $true -debug $true
.LINK
    https://github.com/nox309/AdGuardList
#>

#---------------------------------------------------------[Initialisations]--------------------------------------------------------

# Definition der Parameter
Param(
    [bool]$Autoupdate = $False,
    [bool]$debug = $False
)

$ErrorActionPreference = "SilentlyContinue"

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
#
# Alle Listen des Projekts AdGuardList (https://github.com/nox309/AdGuardList) dienen nur einer besseren Übersicht.
# Die Domains in diesen Listen werden nicht überprüft, sie fassen nur div. Listen aus Internet Themenbasiert zusammen 
# und stammen aus verschiedenen Quellen. Die Quell Listen die die Basis für dieses Projekt dienen finden sie unter: 
# https://github.com/nox309/AdGuardList/tree/main/Quellen
# oder 
# https://github.com/nox309/AdGuardList/blob/main/Quellen/Listenuebersicht.md
#
"

$logpath = ".\Update.log"
New-Variable -Name sum -Option AllScope -Value 0

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

Write-Log -Message "Listen Update wird gestatet mit Git Auto Update = $Autoupdate" -Severity Information -console $true
Write-Log -Message "Löschen aller Listen" -Severity Information -console $debug
Remove-Item ".\Listen\*"
Write-Log -Message "Abrufen der URLs beginnt" -Severity Information -console $debug

# Abrufen der URLs jeder Kategorie
foreach ($category in $paths.Keys) {
    Write-Log -Message "Beginne mit dem Update von $category" -Severity Information -console $true
    # Laden der URLs aus der Textdatei
    $urls = Get-Content $qPaths[$category]

    # Abrufen der Sperrlisten
    foreach ($url in $urls) {
        # Herunterladen des Inhalts der URL
        Write-Log -Message "Abrufen der URL: $url" -Severity Information -console $debug
        $content = Invoke-WebRequest -Uri $url -UseBasicParsing
        # Speichern des Inhalts in einer Datei
        $content.Content | Out-File -FilePath $paths[$category] -Append  -Encoding utf8
        Write-Log -Message "Inhalte von $url in $($paths[$category]) geschrieben" -Severity Information -console $debug
        }
    }

foreach ($sourcepath in $paths.Values) {
    Write-Log -Message "Starte Optimierung von $sourcepath " -Severity Information -console $true

    # Lesen der URLs aus der Datei in eine Liste
    $urls = (Get-Content $sourcepath) -replace '^#.*',""
    
    # Entfernen der doppelte URLs und speichern der Ergebnisse in einer neuen Liste
    $uniqueUrls = $urls | Sort-Object -Unique
   
    # Überschreiben Sie die ursprüngliche Datei mit den eindeutigen URLs
    $disclaimer | Out-File -FilePath $sourcepath -Encoding utf8
    Write-Log -Message "Disclamer zu $sourcepath hinzugefügt" -Severity Information -console $debug
    Write-Log -Message "Schreibe die Optimirten URLs in $sourcepath " -Severity Information -console $debug
    $uniqueUrls | Out-File -FilePath $sourcepath -Append -Encoding utf8

    # Berechnen der Anzahl der gelöschten URLs
    $deletedUrlsCount = $urls.Count - $uniqueUrls.Count
    $count = $uniqueUrls.Count
    $sum = $sum + $count

    # Rückgabe der Anzahl der gelöschten URLs
    Write-Log -Message "Die Liste $sourcepath enthält $($uniqueUrls.Count) URLs" -Severity Information -console $debug
    Write-Log -Message "Optimisirung abgeschlossen, in $sourcepath es wurden $deletedUrlsCount Doppelte URLs gefunden" -Severity Information -console $true
    }

Write-Log -Message "Download der Listen abgeschlossen" -Severity Information -console $true
Write-Log -Message "Alle Listen haben zusammen $sum URLs" -Severity Information -console $true

$AUT = (get-date -Format yyyyMMdd)
"| $AUT | Auto Update - Anzahl der URLs $sum|" | Out-File -FilePath ".\README.md" -Append  -Encoding utf8

if ($Autoupdate) {
    Write-Log -Message "Git Autoupdate wird ausgeführt" -Severity Information -console $true
    git add .
    git commit -m "Auto Update"
    git push
    Write-Log -Message "Git Autoupdate abgeschlossen alles auf dem aktuellen Stand" -Severity Information -console $true
}
else {
    Write-Log -Message "Autoupdate übersprungen" -Severity Warning -console $debug
}