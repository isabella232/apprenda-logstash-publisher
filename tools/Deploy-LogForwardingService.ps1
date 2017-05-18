function Deploy-LogForwardingService {
    [CmdletBinding()]
    param()

    Set-StrictMode -Version Latest
    $ErrorActionPreference = 'Stop'

    $applicationName = "logstashforwarder"
    $version = "v1"
    $archivePath = ".\logstashforwarder.zip"


    "Signing into Apprenda"    
    New-ApprendaSession "jvanbrackel@apprenda.com" "P@ssword1" "JvB" "https://apps.apprenda.jvb"

    "Checking for an existing application"
    if (Get-ApprendaApplication $applicationName -ErrorAction SilentlyContinue) {
        "Removing $applicationName"
        Remove-ApprendaApplication $applicationName
    }

    "Creating $applicationName"
    New-ApprendaApplication $applicationName

    "Uploading $archivePath"
    Set-ApprendaApplicationArchive $applicationName $version $archivePath

    #TODO: Get-ApprendaAddO
    #TODO: Remove-ApprendaAddOn
    #TODO: New-ApprendaAddOn

    Write-Warning "Setting Add-On Properties are not current suported by the API.  Please navigate to $($apprendaSession.url)/soc/Configuration/AddOns.aspx and set the logstash add on properties for the host."
    Write-Warning "See story APPRENDA-22542 for more details."
    Write-Warning "Once that is complete you can complete this process by running Promote-LogForwardingService, which includes the call New-ApprendaAddOnInstance -Alias `"logstash`" -InstaceAlias `"logstashForwarder`";"
}