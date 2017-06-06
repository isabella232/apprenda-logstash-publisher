[CmdletBinding()]
param(
    $Configuration = "Debug",
    $Step = 1
)

$here = Split-Path -Parent $MyInvocation.MyCommand.Path


Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if ($Step -eq 1) {
    "Step 1 startup ELK, Build and Deploy Archives"

    "Starting up ELK Stack"
    Get-Job -Name "ELK Job" -ErrorAction Continue | Stop-Job -ErrorAction Continue
    Get-Job -Name "ELK Job" -ErrorAction Continue | Remove-Job -ErrorAction Continue
    Start-Job { Set-Location $args[0]; Invoke-Expression "docker-compose.exe up" } -ArgumentList "$here\docker" -Name "ELK Job"

    .\tools\Build-LogstashArchives.ps1 -Configuration $Configuration
    .\tools\Deploy-LogForwardingService.ps1 -PlatformUrl $PlatformUrl -Username $Username -Password $Password -Tenant $Tenant
}

if ($Step -eq 2) {
    "Step 2 promote and test"    
    Promote-LogForwardingService

    "Turn logging up to 11"
    Set-ApprendaGlobalLogLevel -LogLevel "Debug"

    "Starting to watch docker.  Press Ctrl-C to stop the test.  Rember to Stop and Remove the `"ELK Job`" job when it's completed."
    $job = Get-Job -Name "ELK Job"
    
    do {
        if ($job.HasMoreData) {
            $output = Receive-Job $job -ErrorAction Continue
            foreach ($line in $output) {
                Write-Host $line
            }
        }
        Start-Sleep -Seconds 1
    } while ($true)
}