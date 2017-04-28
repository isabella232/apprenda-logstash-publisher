[CmdletBinding()]
param(
    $configuration = "Debug",
    $timeout = 10
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$msBuildPath = (Get-MsBuildVersion -Version Latest).GetValue("MSBuildToolsPath")
$solutionPath = "./src/Apprenda.ClientServices.LogStashPublisher.sln"
$applicationName = "logstashforwarder"
$archivePath = "./logstashforwarder.zip"
$version = "v1"

"Checking for MSBuild."
if($env:Path -notlike "*$msBuildPath*") {
    "Adding MSBuild to your path."
    $env:Path += ";$msBuildPath"
} else {
    "Found MSBuild."
}

"Cleaning Solution."
Clean-Solution $solutionPath

"Building Solution."
Build-Solution $solutionPath

Package-ApprendaApplication -ArchivePath $archivePath -Services (@{ Name = "LogStashPublisher"; Path ="./src/Publisher/bin/$configuration" })

"Signing into Apprenda"    
New-ApprendaSession "jvanbrackel@apprenda.com" "password" "JvB" "https://apps.apprenda.jvb"

"Checking for an existing application"
if(Get-ApprendaApplication $applicationName -ErrorAction SilentlyContinue) {
    "Removing $applicationName"
    Remove-ApprendaApplication $applicationName
}

"Creating $applicationName"
New-ApprendaApplication $applicationName

"Uploading $archivePath"
Set-ApprendaApplicationArchive $applicationName $version $archivePath

"Promoting to Published"
Promote-ApprendaApplication -ApplicationAlias $applicationName -VersionAlias $version -Stage "Published"

"Setting Registry Key"
New-ApprendaRegistrySetting -Setting "Apprenda.Logging.ExternalServiceAppVersion" -Value "$applicationName(v1)/LogStashForwarderService" -ErrorAction SilentlyContinue

"Turn the log level up to 11"
Set-ApprendaGlobalLogLevel "Debug"

"Start Listening"
$loopCount = 0
$workingDirectory = Get-Location
$foundOrErrorOrTimeout = $false
$listenerJob = Start-Job { Set-Location $args[0]; .\tools\Run-UdpListener.ps1 10000 } -ArgumentList $workingDirectory
while(!($foundOrErrorOrTimeout)) {
    if($loopCount -ge $timeout)
    {
        $foundOrErrorOrTimeout = $true
    }	
    $loopCount++
    if($listenerJob.HasMoreData)
    {
        $jobOutput = $listenerJob | Receive-Job
        Write-Host $jobOutput
    }
    Start-Sleep -Seconds 1
}

$listenerJob.StopJob()

while($listenerJob.PSEndTime -eq $null)
{
    "Waiting for the listener to stop."
    Start-Sleep -Seconds 2
}

"Turn the log level back down."
Set-ApprendaGlobalLogLevel "Error"

"Cleaning up the listener job."
$listenerJob | Remove-Job
