# Kill all node processes
$procs = Get-Process -Name "node" -ErrorAction SilentlyContinue
if ($procs) {
    Write-Host "Killing $($procs.Count) node process(es)..."
    foreach ($p in $procs) {
        Write-Host "  Killing PID $($p.Id)"
        Stop-Process -Id $p.Id -Force -ErrorAction SilentlyContinue
    }
    Start-Sleep -Seconds 3
} else {
    Write-Host "No node processes found."
}

# Verify killed
$remaining = Get-Process -Name "node" -ErrorAction SilentlyContinue
if ($remaining) {
    Write-Host "WARNING: $($remaining.Count) node process(es) still running!"
    foreach ($p in $remaining) {
        Write-Host "  PID $($p.Id) still alive - force killing..."
        cmd /c "taskkill /F /PID $($p.Id)" 2>&1 | Out-Null
    }
    Start-Sleep -Seconds 2
}

# Final check
$final = Get-Process -Name "node" -ErrorAction SilentlyContinue
if ($final) {
    Write-Host "ERROR: Could not kill all node processes"
} else {
    Write-Host "All node processes killed."
}

# Restart gateway
Write-Host ""
Write-Host "Starting openclaw gateway run..."
# Use & to run in background without blocking, give it time to start
$proc = Start-Process -FilePath "openclaw" -ArgumentList "gateway","run" -NoNewWindow -PassThru
Write-Host "Gateway starting (PID $($proc.Id))..."
Start-Sleep -Seconds 10

# Verify started
$newProcs = Get-Process -Name "node" -ErrorAction SilentlyContinue
if ($newProcs) {
    Write-Host "✓ Gateway started - $($newProcs.Count) node process(es) running."
} else {
    Write-Host "⚠ Give it a moment... Checking again in 3 seconds."
    Start-Sleep -Seconds 3
    $newProcs = Get-Process -Name "node" -ErrorAction SilentlyContinue
    if ($newProcs) {
        Write-Host "✓ Gateway now running."
    } else {
        Write-Host "✗ No node processes. Try running 'openclaw gateway run' manually."
    }
}
