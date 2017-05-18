function Promote-LogForwardingService {
    [CmdletBinding()]
    param()
    process {
        $addOnAlias = "logstash"
        $addOnInstanceAlias = "logstashForwarder"
        $applicationName = "logstashforwarder"
        $version = "v1"

        #TODO Get and or remove instance
        "Acquiring a Logstash Add-On Instnace"
        New-ApprendaAddOnInstance -Alias $addOnAlias -InstanceAlias $addOnInstanceAlias

        "Promoting to Published"
        Promote-ApprendaApplication -ApplicationAlias $applicationName -VersionAlias $version -Stage "Published"

        "Setting Registry Key"
        New-ApprendaRegistrySetting -Setting "Apprenda.Logging.ExternalServiceAppVersion" -Value "$applicationName(v1)/LogStashForwarderService" -ErrorAction SilentlyContinue
    }
}