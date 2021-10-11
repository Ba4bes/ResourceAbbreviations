# Input bindings are passed in via param block.
param($Timer)

# Get the current universal time in the default string format
$currentUTCtime = (Get-Date).ToUniversalTime()

# The 'IsPastDue' porperty is 'true' when the current function invocation is later than scheduled.
if ($Timer.IsPastDue) {
    Write-Host "PowerShell timer is running late!"
}

$URL = 'https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations'


$Content = ConvertFrom-Html -URI $URL
[System.Collections.ArrayList]$ResultingArraylist = @()
$Tables = $Content.SelectNodes('//table')
foreach ($table in $tables) {
    Write-host "Table" -ForegroundColor Yellow
    $childNotes = $table.Element('tbody').ChildNodes | where { $_.NodeType -eq 'Element' -and $_.Name -eq 'tr' }
    foreach ($childNote in $childNotes) {

        Write-Host "Childhost" -ForegroundColor Cyan
        $ChildNoteArray = ($childNote.InnerText -split '\r?\n') | where { $_ -ne '' }
        if ($ChildNoteArray[2]) {
            $newObject = [PSCustomObject]@{
                Name         = $ChildNoteArray[0]
                Type         = $ChildNoteArray[1]
                Abbreviation = $ChildNoteArray[2].Replace('-', '')
            }
        }
        $ResultingArraylist.Add($newObject)
        # ($emailList -split '\r?\n').Trim()
    }
}

#  $ResultingArraylist.ToArray() | export-csv .\abbreviations.csv
# $ResulttoGiveBack = Get-Content .\abbreviations.csv
# Write an information log with the current time.
Write-Host "PowerShell timer trigger function ran! TIME: $currentUTCtime"

Push-OutputBinding -Name outputBlob -Value  $ResultingArraylist.ToArray()