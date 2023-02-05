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
    [bool]$Autoupdate = $False,
    [bool]$debug = $False,
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

    # Lesen der URLs aus der Datei in eine Liste
    $urls = (Get-Content $filePath) -replace '^#.*',""
    
    # Entfernen der doppelte URLs und speichern der Ergebnisse in einer neuen Liste
    $uniqueUrls = $urls | Sort-Object -Unique
   
    # Überschreiben Sie die ursprüngliche Datei mit den eindeutigen URLs
    $disclaimer | Out-File -FilePath $filePath -Encoding utf8
    Write-Log -Message "Disclamer zu $filePath hinzugefügt" -Severity Information -console $debug
    Write-Log -Message "Schreibe die Optimirten URLs in $filePath " -Severity Information -console $debug
    $uniqueUrls | Out-File -FilePath $filePath -Append -Encoding utf8

    # Berechnen der Anzahl der gelöschten URLs
    $deletedUrlsCount = $urls.Count - $uniqueUrls.Count
    $count = $uniqueUrls.Count
    $sum += $count

    # Rückgabe der Anzahl der gelöschten URLs
    Write-Log -Message "Die Liste $filePath enthält $($uniqueUrls.Count) URLs" -Severity Information -console $debug
    Write-Log -Message "Optimisirung abgeschlossen, in $filePath es wurden $deletedUrlsCount Doppelte URLs gefunden" -Severity Information -console $true
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
        Start-optimize $sourcepath
    }

Write-Log -Message "Download der Listen abgeschlossen" -Severity Information -console $true
Write-Log -Message "Alle Listen haben zusammen $sum URLs" -Severity Information -console $true

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