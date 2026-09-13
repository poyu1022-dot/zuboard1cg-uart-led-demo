param(
    [Parameter(Mandatory=$true)][string]$PortName,
    [int]$BaudRate = 115200
)

$port = New-Object System.IO.Ports.SerialPort $PortName, $BaudRate, ([System.IO.Ports.Parity]::None), 8, ([System.IO.Ports.StopBits]::One)
$port.Open()
Write-Host "Listening on $PortName at $BaudRate 8N1. Press Ctrl+C to stop."
try {
    while ($true) {
        try {
            $line = $port.ReadLine()
            Write-Host $line
        } catch [TimeoutException] {
            # no data yet, keep polling
        }
    }
} finally {
    $port.Close()
}
