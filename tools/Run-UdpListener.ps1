[CmdletBinding()]
param(
    [int] $port
) 
{
    $address = [System.Net.IPAddress]::Any
    $endpoint = [System.Net.IPEndPoint]::new($address, $port)
    $client = [System.Net.Sockets.UdpClient]::new($endpoint)

    for($i=0; $i -lt 10; i++)
    {
        $bytes = $client.Receive([ref]$endpoint)
        $output = [System.Text.Encoding]::Unicode.GetString($bytes, 0, $bytes.Length)
        Write-Host $output
        Start-Sleep -Seconds 1
    }
}