#$here = Split-Path -Parent $MyInvocation.MyCommand.Path
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

    "Restoring nuget references"
    .\tools\nuget.exe restore $solutionPath

    "Building Solution."
    Build-Solution -solutionPath $solutionPath -configuration $Configuration

    "Packaging the Logstash Forwarder Service"
    Package-ApprendaApplication -ArchivePath $archivePath -Services (@{ Name = "LogStashPublisher"; Path = "./src/Publisher/bin/$Configuration" })

    "Packaging the Logstash AddOn"
    Package-ApprendaAddOn -ArchivePath $addOnPath -AddOnPath "./src/AddOn/bin/$Configuration" -ManifestPath "./src/Manifests/AddonManifest.xml" -IconPath "./src/Icons/icon.png" -APIPath "C:\Program Files (x86)\Apprenda\SDK\API Files\SaaSGrid.API.dll"
}