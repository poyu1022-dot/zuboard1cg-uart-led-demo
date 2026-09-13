param(
    [Parameter(Mandatory=$true)][string]$PortName,
    [int]$BaudRate = 115200,
    [int]$Seconds = 5
)

$port = New-Object System.IO.Ports.SerialPort $PortName, $BaudRate, ([System.IO.Ports.Parity]::None), 8, ([System.IO.Ports.StopBits]::One)
$port.ReadTimeout = 500
$port.Open()
$deadline = (Get-Date).AddSeconds($Seconds)
while ((Get-Date) -lt $deadline) {
    try {
        $line = $port.ReadLine()
        Write-Output $line
    } catch [System.TimeoutException] {
        # no data yet
    }
}
$port.Close()
