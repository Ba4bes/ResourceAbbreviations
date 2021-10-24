<#
.SYNOPSIS
    Function gives the abbreviation of the given Azure Resource
.DESCRIPTION
    Function collects the reccomended abbreviation of the given Azure Resource.
    The Microsoft docs are used as a reference.
    Can work with the name of the resource or the resource type
    Wildcards are supported.
.INPUTS
    User input through an http request
    Storage Account input
.OUTPUTS
    HTTP response
.NOTES
    Uses the PowerHTML module
    Written by Barbara Forbes
    @Ba4bes
    https://4bes.nl
#>
using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $InputBlob, $TriggerMetadata)

# The input parameters that are approved for use.
$ApprovedParameters = @(
    'resourcename'
    'resourcenamespace'
    'resourceabbreviation'
    'wildcard'
)

# Set the default result to success.
$HttpResult = [HttpStatusCode]::OK

"Requestbody"
$request.body.Keys

$RequestParameters = $Request.Query.Keys | Where-Object { $_ -ne 'wildcard' }
$RequestSource = 'Query'
if ($null -eq $RequestParameters){
    $RequestParameters = $Request.Body.Keys | Where-Object { $_ -ne 'wildcard' }
    $RequestSource = 'Body'
}

Write-Host "Request Parameters:"
$RequestParameters

# First check for invalid parameters.
if ($RequestParameters | Where-Object { $ApprovedParameters -notcontains $_ }) {
    $HttpResult = [HttpStatusCode]::BadRequest
    $Body = "Invalid parameters have been used. Approved Parameters: $ApprovedParameters"

}
else {
    foreach ($RequestParameter in $RequestParameters) {
        Write-Host "Request parameter: $RequestParameter"
        Write-Host "Request parameter value: $($Request.$RequestSource.$RequestParameter)"
        if ($Request.Query.wildcard -eq 'true') {
            Write-Host 'working with a wildcard'
            $Resource = $InputBlob | Where-Object { $_.$RequestParameter -like "*$($Request.$RequestSource.$RequestParameter)*" }
            Write-Host "$($Resource.Count) resources found"
            $Resource
        }
        else {
            Write-Host "no wildcard defined"
            $Resource = $InputBlob | Where-Object { $_.$RequestParameter -eq $Request.$RequestSource.$RequestParameter }
            Write-Host "$($Resource.Count) resources found"
            $Resource
        }
        $Body += $Resource
    }
}

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = $HttpResult
        Body       = $Body
    })
