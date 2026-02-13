$lines = Get-Content 'C:\tmp\openclaw\openclaw-2026-02-11.log' -Tail 30
foreach ($line in $lines) {
    if ($line.Length -gt 300) { $line = $line.Substring(0, 300) + "..." }
    Write-Host $line
    Write-Host ""
}
