# Find and kill openclaw gateway process
$procs = Get-Process -Name "node" -ErrorAction SilentlyContinue
if ($procs) {
    Write-Host "Found $($procs.Count) node process(es):"
    foreach ($p in $procs) {
        $cmd = (Get-CimInstance Win32_Process -Filter "ProcessId=$($p.Id)").CommandLine
        Write-Host "  PID $($p.Id): $cmd"
        if ($cmd -and ($cmd -match "openclaw" -or $cmd -match "gateway")) {
            Write-Host "  -> Killing gateway process PID $($p.Id)..."
            Stop-Process -Id $p.Id -Force
            Write-Host "  -> Killed."
        }
    }
} else {
    Write-Host "No node processes found."
}

Start-Sleep -Seconds 2

# Restart gateway
Write-Host ""
Write-Host "Starting openclaw gateway..."
Start-Process -FilePath "openclaw" -ArgumentList "gateway","run" -WindowStyle Normal
Write-Host "Gateway starting in new window."
