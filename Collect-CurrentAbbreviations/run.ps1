<#
.SYNOPSIS
    Collects resource abbreviations from the Microsoft Docs and stores them in a storage account.
.DESCRIPTION
    This function will collect all the reccomended resource abbreviations from the Microsoft Docs.
    They are stored as a json file in a storage account.
.INPUTS
    Timer trigger, reccomended to run once a day
.OUTPUTS
    A JSON file that is written to a storage account
.NOTES
    Uses the PowerHTML module
    Written by Barbara Forbes
    @Ba4bes
    https://4bes.nl
#>
# Input bindings are passed in via param block.
param($Timer)

# Get the current universal time in the default string format
$currentUTCtime = (Get-Date).ToUniversalTime()
Write-Host "Current UTC time is: $currentUTCtime"

# The URL is where the resource abbreviations are found to work with
$URL = 'https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations'


$SourceContent = ConvertFrom-Html -URI $URL
[System.Collections.ArrayList]$ResultArraylist = @()

$TablesInSource = $SourceContent.SelectNodes('//table')
foreach ($Table in $TablesInSource) {
    Write-host "Starting with Table" -ForegroundColor Yellow
    $childNotes = $Table.Element('tbody').ChildNodes | Where-Object { $_.NodeType -eq 'Element' -and $_.Name -eq 'tr' }
    foreach ($childNote in $childNotes) {
        Write-Host "Starting with Childhost" -ForegroundColor Cyan
        $ChildNoteArray = ($childNote.InnerText -split '\r?\n') | Where-Object { $_ -ne '' }
        if ($ChildNoteArray[2]) {
            $newObject = [PSCustomObject]@{
                resourcename         = $ChildNoteArray[0]
                resourcenamespace    = $ChildNoteArray[1]
                resourceabbreviation = $ChildNoteArray[2].Replace('-', '')
            }
        }
        $ResultArraylist.Add($newObject)
    }
}

Write-Host "Number of elements in the arraylist: $($ResultArraylist.Count)"

Push-OutputBinding -Name outputBlob -Value  $ResultArraylist.ToArray()