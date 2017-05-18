function Build-LogStashArchives {
    [CmdletBinding()]
    param(
        $Configuration = "Debug",
        $StopAfterWarning = $true
    )
    process {
        Set-StrictMode -Version Latest
        $ErrorActionPreference = 'Stop'
        $msBuildPath = (Get-MsBuildVersion -Version Latest).GetValue("MSBuildToolsPath")
        $solutionPath = "./src/Apprenda.ClientServices.LogStashPublisher.sln"
        $archivePath = "./logstashforwarder.zip"
        $addOnPath = "./logstashAddOn.zip"
        $version = "v1"

        $addOnAlias = "logstash"
        $addOnInstanceAlias = "logstashForwarder"

        "Checking for MSBuild."
        if ($env:Path -notlike "*$msBuildPath*") {
            "Adding MSBuild to your path."
            $env:Path += ";$msBuildPath"
        }
        else {
            "Found MSBuild."
        }

        "Cleaning Solution."
        Clean-Solution -solutionPath $solutionPath -configuration $Configuration

        "Building Solution."
        Build-Solution -solutionPath $solutionPath -configuration $Configuration

        "Packaging the Logstash Forwarder Service"
        Package-ApprendaApplication -ArchivePath $archivePath -Services (@{ Name = "LogStashPublisher"; Path = "./src/Publisher/bin/$Configuration" })

        "Packaging the Logstash AddOn"
        Package-ApprendaAddOn -ArchivePath $addOnPath -AddOnPath "./src/AddOn/bin/$Configuration" -ManifestPath "./src/Manifests/AddonManifest.xml" -IconPath "./src/Icons/icon.png" -APIPath "./lib/Apprenda 6.7.0/SaaSGrid.API.dll"
    }
}