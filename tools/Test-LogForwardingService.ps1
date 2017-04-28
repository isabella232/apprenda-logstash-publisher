    [CmdletBinding()]
    param($configuration = "Debug")
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
	Set-ApprendaGlobalLogLeve Debug

	"Start Listening"
	$loopCount = 0
	$workingDirectory = Get-Location
	$foundOrErrorOrTimeout = $false
	$listenerJob = Start-Job { Set-Location $args[0]; .\tools\Run-UdpListener.ps1 10000 } -ArgumentList $workingDirectory
	while(!($foundOrErrorOrTimeout)) {
		if($loopCount -ge 2)
		{
			$foundOrErrorOrTimeout = $true
		}	
		$loopCount++
		if($listenerJob.HasMoreData)
		{
			$jobOutput = $listenerJob | ReceiveJob
            Write-Host $jobOutput
            $foundOrErrorOrTimeout = $true
		}
        Start-Sleep -Seconds 1
	}   