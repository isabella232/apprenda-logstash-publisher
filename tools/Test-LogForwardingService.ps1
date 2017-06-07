[CmdletBinding()]
param(
    $Configuration = "Debug",
    $Step = 1,
    $PlatformUrl,    
    $Username,
    $Password,
    $Tenant
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if ($Step -eq 1) {
    "Step 1 startup ELK, Build and Deploy Archives"

    "Starting up ELK Stack"
    Get-Job -Name "ELK Job" -ErrorAction Continue | Stop-Job -ErrorAction SilentlyContinue
    Get-Job -Name "ELK Job" -ErrorAction Continue | Remove-Job -ErrorAction SilentlyContinue
    Start-Job { Set-Location $args[0]; Invoke-Expression "docker-compose.exe up" } -ArgumentList "$((Get-Location).Path)\tools\docker" -Name "ELK Job"

    .\tools\BuildAndPackage-LogForwardingComponents.ps1 -Configuration $Configuration
    .\tools\Deploy-LogForwardingComponents.ps1 -PlatformUrl $PlatformUrl -Username $Username -Password $Password -Tenant $Tenant
}

if ($Step -eq 2) {
    "Step 2 promote and test"    
    .\tools\Promote-LogForwardingComponents.ps1

    "Turn logging up to 11"
    Set-ApprendaGlobalLogLevel -LogLevel "Debug"

    "Starting to watch docker.  Press Ctrl-C to stop the test.  Remember to Stop and Remove the `"ELK Job`" job when you're done with the command `"Get-Job -Name 'ELK Job' | Stop-Job`""
    $job = Get-Job -Name "ELK Job"
    
    do {
        if ($job.HasMoreData) {
            $output = Receive-Job $job -ErrorAction Continue
            foreach ($line in $output) {
                Write-Host $line
            }
        }
        Start-Sleep -Seconds 5
    } while ($true)
}