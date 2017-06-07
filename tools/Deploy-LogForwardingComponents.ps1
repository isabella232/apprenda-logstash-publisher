[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$PlatformUrl,
    [Parameter(Mandatory = $true)]
    [string]$Username,
    [Parameter(Mandatory = $true)]
    [string]$Password,
    [Parameter(Mandatory = $true)]
    [string]$Tenant
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$applicationName = "logstashforwarder"
$version = "v1"
$archivePath = ".\logstashforwarder.zip"
$addOnArchviePath = ".\logstashAddOn.zip"
$addOnAlias = "logstash"
$addOnInstanceAlias = "logstashForwarder"


"Signing into Apprenda"    
New-ApprendaSession -Username $Username -Password $Password -Tenant $Tenant -Url $PlatformUrl

"Checking for an existing application"
if (Get-ApprendaApplication $applicationName -ErrorAction SilentlyContinue) {
    "Removing $applicationName"
    Remove-ApprendaApplication $applicationName
}

"Creating $applicationName"
New-ApprendaApplication $applicationName

"Uploading $archivePath"
Set-ApprendaApplicationArchive $applicationName $version $archivePath

"Creating the Apprenda AddOn if needed"
try {
    $currentAddOn = Get-ApprendaAddOn -Alias $addOnAlias
} catch {
    $currentAddOn = $null
}
    
if ($currentAddOn -ne $null) {
    "Add-on $addOnAlias found."
}
else {
    New-ApprendaAddOn -Alias $addOnAlias -Path $addOnArchviePath
    Write-Warning "Setting Add-On Properties are not current suported by the API.  Please navigate to $($apprendaSession.url)/soc/Configuration/AddOns.aspx and set the logstash add on properties for the host."
    Write-Warning "See story APPRENDA-22542 for more details."
    Write-Warning "Once that is complete you can complete this process by running Promote-LogForwardingService, which includes the call New-ApprendaAddOnInstance -Alias `"$addOnAlias`" -InstaceAlias `"$addOnInstanceAlias`";"
    throw "Stopping execution so the operator can adjust the add on settings in the SOC."
}   
