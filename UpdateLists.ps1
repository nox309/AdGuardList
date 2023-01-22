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
#Listen Kategorien Output
$Shops = ".\Listen\Fakeshops_AboFallen.txt"
$Tracking = ".\Listen\Tracking.txt"
$Jugendschutz = ".\Listen\Jugendschutz.txt"
$Sonstiges = ".\Listen\Sonstiges.txt"
$Werbung = ".\Listen\Werbung.txt"
$Malware = ".\Listen\Malware.txt"
$PuDS = ".\Listen\Phishing_Domain-Squatting.txt"


#Quellen
$qShops = ".\Quellen\Fakeshops_AboFallen.txt"
$qTracking = ".\Quellen\Tracking.txt"
$qJugendschutz = ".\Quellen\Jugendschutz.txt"
$qSonstiges = ".\Quellen\Sonstiges.txt"
$qWerbung = ".\Quellen\Werbung.txt"
$qMalware = ".\Quellen\Malware.txt"
$qPuDS = ".\Quellen\Fakeshops_AboFallen.txt"

$discalamer = "
#. Alle Listen des Projekts AdGuardList sind selbst erstellte Listen, basierend auf Grunddaten 
#. aus verschiedenen Quellen. Hier werden div. Listen in einer Großen zusammen gefast um diese besser
#. in Adgurard pflegen zu können. Die Quell Listen finden sie unter: 
#.
#.
#. 
"
$logpath = ".\Update.log"
#---------------------------------------------------------[Config]-----------------------------------------------------------------

#---------------------------------------------------------[Functions]--------------------------------------------------------------
function Get-Shops {

    Write-Log -Message "Beginne mit dem Update von Shops" -Severity Information -console $true
    # Laden Sie die URLs aus der Textdatei
    $urls = Get-Content $qShops
    $discalamer | Out-File -FilePath $Shops -Append  -Encoding utf8
    Write-Log -Message "Disclamer zu $Shops hinzugefügt" -Severity Information -console $true

    # Iterieren Sie über jede URL
    foreach ($url in $urls) {
        # Herunterladen des Inhalts der URL
        Write-Log -Message "Abrufen der URL: $url" -Severity Information -console $true
        $content = Invoke-WebRequest -Uri $url -UseBasicParsing

        # Speichern des Inhalts in einer Datei
        $content.Content | Out-File -FilePath $Shops -Append  -Encoding utf8
        Write-Log -Message "Inhalte von $url in $Shops geschrieben" -Severity Information -console $true
    }
}

function Get-Jungendschutz {
    Write-Log -Message "Beginne mit dem Update für Jugenschutz" -Severity Information -console $true
    # Laden Sie die URLs aus der Textdatei
    $urls = Get-Content $qJugendschutz
    $discalamer | Out-File -FilePath $Jugendschutz -Append  -Encoding utf8
    Write-Log -Message "Disclamer zu $Jugendschutz hinzugefügt" -Severity Information -console $true

    # Iterieren Sie über jede URL
    foreach ($url in $urls) {
        # Herunterladen des Inhalts der URL
        Write-Log -Message "Abrufen der URL: $url" -Severity Information -console $true
        $content = Invoke-WebRequest -Uri $url -UseBasicParsing
                    
        # Speichern des Inhalts in einer Datei
        Write-Log -Message "Inhalte von $url in $Jugendschutz geschrieben" -Severity Information -console $true
        $content.Content | Out-File -FilePath $Jugendschutz -Append  -Encoding utf8
    }
}

function Get-Malware {
    Write-Log -Message "Beginne das Update von Malware" -Severity Information -console $true
    # Laden Sie die URLs aus der Textdatei
    $urls = Get-Content $qMalware
    $discalamer | Out-File -FilePath $Malware -Append  -Encoding utf8
    Write-Log -Message "Disclamer zu $Malware hinzugefügt" -Severity Information -console $true
    
    # Iterieren Sie über jede URL
    foreach ($url in $urls) {
        Write-Log -Message "Abrufen der URL: $url" -Severity Information -console $true
        # Herunterladen des Inhalts der URL
        $content = Invoke-WebRequest -Uri $url -UseBasicParsing

        # Speichern des Inhalts in einer Datei
        $content.Content | Out-File -FilePath $Malware -Append  -Encoding utf8
        Write-Log -Message "Inhalte von $url in $Malware geschrieben" -Severity Information -console $true
    }
}

function Get-PuDS {
    Write-Log -Message "Beginnde mit dem Update von Phishing Scam Domians" -Severity Information -console $true
    # Laden Sie die URLs aus der Textdatei
    $urls = Get-Content $qPuDS
    $discalamer | Out-File -FilePath $PuDS -Append  -Encoding utf8
    Write-Log -Message "Disclamer zu $PuDS hinzugefügt" -Severity Information -console $true
    
    # Iterieren Sie über jede URL
    foreach ($url in $urls) {
        Write-Log -Message "Abrufen der URL: $url" -Severity Information -console $true
        # Herunterladen des Inhalts der URL
        $content = Invoke-WebRequest -Uri $url -UseBasicParsing

        # Speichern des Inhalts in einer Datei
        $content.Content | Out-File -FilePath $PuDS -Append  -Encoding utf8
        Write-Log -Message "Inhalte von $url in $PuDS geschrieben" -Severity Information -console $true
    }
}

function Get-Sonstiges {
    Write-Log -Message "Beginne mit dem Update von Sonstiges" -Severity Information -console $true
    # Laden Sie die URLs aus der Textdatei
    $urls = Get-Content $qSonstiges
    $discalamer | Out-File -FilePath $Sonstiges -Append  -Encoding utf8
    Write-Log -Message "Disclamer zu $Sonstiges hinzugefügt" -Severity Information -console $true
    
    # Iterieren Sie über jede URL
    foreach ($url in $urls) {
        Write-Log -Message "Abrufen der URL: $url" -Severity Information -console $true
        # Herunterladen des Inhalts der URL
        $content = Invoke-WebRequest -Uri $url -UseBasicParsing

        # Speichern des Inhalts in einer Datei
        $content.Content | Out-File -FilePath $Sonstiges -Append  -Encoding utf8
        Write-Log -Message "Inhalte von $url in $Sonstiges geschrieben" -Severity Information -console $true
    }
}
function Get-Tracking {
    Write-Log -Message "Beginne mit dem Update von Traking" -Severity Information -console $true
    # Laden Sie die URLs aus der Textdatei
    $urls = Get-Content $qTracking
    $discalamer | Out-File -FilePath $Tracking -Append  -Encoding utf8
    Write-Log -Message "Disclamer zu $Tracking hinzugefügt" -Severity Information -console $true
    
    # Iterieren Sie über jede URL
    foreach ($url in $urls) {
        Write-Log -Message "Abrufen der URL: $url" -Severity Information -console $true
        # Herunterladen des Inhalts der URL
        $content = Invoke-WebRequest -Uri $url -UseBasicParsing

        # Speichern des Inhalts in einer Datei
        $content.Content | Out-File -FilePath $Tracking -Append  -Encoding utf8
        Write-Log -Message "Inhalte von $url in $Tracking geschrieben" -Severity Information -console $true
    }
}

function Get-Werbung {
    Write-Log -Message "Beginne mit dem Update von Werbung" -Severity Information -console $true
    # Laden Sie die URLs aus der Textdatei
    $urls = Get-Content $qWerbung
    $discalamer | Out-File -FilePath $Werbung -Append  -Encoding utf8
    Write-Log -Message "Disclamer zu $Werbung hinzugefügt" -Severity Information -console $true
    
    # Iterieren Sie über jede URL
    foreach ($url in $urls) {
        Write-Log -Message "Abrufen der URL: $url" -Severity Information -console $true
        # Herunterladen des Inhalts der URL
        $content = Invoke-WebRequest -Uri $url -UseBasicParsing

        # Speichern des Inhalts in einer Datei
        $content.Content | Out-File -FilePath $Werbung -Append  -Encoding utf8
        Write-Log -Message "Inhalte von $url in $Werbung geschrieben" -Severity Information -console $true
    }
}


Function Start-optimize {
    param($filePath)
    
    Write-Log -Message "Starte Optimirung von $filePath " -Severity Information -console $true

    # Lesen Sie die URLs aus der Datei in eine Liste
    $urls = (Get-Content $filePath) -replace '^#.*',""

    # Entfernen Sie doppelte URLs und speichern Sie die Ergebnisse in einer neuen Liste
    $uniqueUrls = $urls | sort-object | Get-Unique
    Where-Object {$_ -ne ""}| Set-Content ".\Listen\Fakeshops_AboFallen.txt"
    Write-Log -Message "Löschen von # in $filePath fertig " -Severity Information -console $true

    # Überschreiben Sie die ursprüngliche Datei mit den eindeutigen URLs
    Write-Log -Message "Starte Duplicats Prüfung $filePath " -Severity Information -console $true
    $discalamer | Out-File -FilePath $filePath -Encoding utf8
    Write-Log -Message "Disclamer zu $filePath hinzugefügt" -Severity Information -console $true
    $uniqueUrls | Where-Object {$_ -ne ""} | Out-File -FilePath $filePath -Append  -Encoding utf8

    # Berechnen Sie die Anzahl der gelöschten URLs
    $deletedUrlsCount = $urls.Count - $uniqueUrls.Count

    # Rückgabe der Anzahl der gelöschten URLs
    Write-Log -Message "Optimisirung abgeschlossen, in $filePath es wurden $deletedUrlsCount gefunden" -Severity Information -console $true
}

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

#---------------------------------------------------------[Logic]-------------------------------------------------------------------
Write-Log -Message "Löschen aller Listen" -Severity Information -console $true
Remove-Item ".\Listen\*"
Write-Log -Message "Starte Update" -Severity Information -console $true
Get-Shops
Get-Jungendschutz
Get-Malware
Get-PuDS
Get-Sonstiges
Get-Tracking
Get-Werbung
Write-Log -Message "Update Abgeschlossen" -Severity Information -console $true
Write-Log -Message "Zählen der URLs" -Severity Information -console $true

Start-optimize $Shops
Start-optimize $Tracking
#Remove-DuplicateUrls $Jugendschutz
Start-optimize $Sonstiges
#Start-optimize $Werbung
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
