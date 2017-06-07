[CmdletBinding()]
param()
process {
    Set-StrictMode -Version Latest
    $ErrorActionPreference = 'Stop'
        
    $addOnAlias = "logstash"
    $addOnInstanceAlias = "logstashForwarder"
    $applicationName = "logstashforwarder"
    $version = "v1"

    "Acquiring a Logstash Add-On Instance if needed"
    try {
        $addOnInstance = Get-ApprendaAddOnInstance -Alias $addOnAlias -InstanceAlias $addOnInstanceAlias
    } catch {
        $addOnInstance = $null
    } 

        
    if ($addOnInstance -eq $null) {
        "No instance found. Creating an instance of $addOnAlias and naming it $addOnInstanceAlias" 
        New-ApprendaAddOnInstance -Alias $addOnAlias -InstanceAlias $addOnInstanceAlias        
    }
    else {
        "Instance $addOnInstanceAlias of $addOnAlias found."
    }

    "Promoting to Published"
    Promote-ApprendaApplication -ApplicationAlias $applicationName -VersionAlias $version -Stage "Published"

    "Setting Registry Key"
    New-ApprendaRegistrySetting -Setting "Apprenda.Logging.ExternalServiceAppVersion" -Value "$applicationName(v1)/LogStashForwarderService" -ErrorAction SilentlyContinue
}
