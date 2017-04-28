[CmdletBinding()]
param(
    [int] $port = 10000,
    [int] $timeout = 10
)
process 
{
    Set-StrictMode -Version Latest
    $ErrorActionPreference = 'Stop'

     $job = Start-Job {
                $address = [System.Net.IPAddress]::Any
                $endPoint = [System.Net.IPEndPoint]::new($address, $args[0])
                $client = [System.Net.Sockets.UdpClient]::new($endPoint)
                while($true) {
                    Write-Host "Listening..."
                    $bytes = $client.Receive([ref]$endPoint)
                    $output = [System.Text.Encoding]::Unicode.GetString($bytes, 0, $bytes.Length)
                    Write-Host $output
                    Start-Sleep -seconds 2
                }
        } -ArgumentList $port
    
    $dontStop = $true
    $loop = 0
    while($dontStop) {
        if($job.HasMoreData) {
            $job | Receive-Job
        }
        Start-Sleep -seconds 1
        $loop++

        if($loop -gt $timeout -and $timeout -ne 0) {
            $dontStop = $true
            $job.StopJob()
        }
    }

    while($job.PSEndTime -eq  $null) {
        "Waiting receiver job to finish"
        Start-Sleep -seconds 1
    }

    $job | Remove-Job
}