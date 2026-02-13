try {
    $r = Invoke-RestMethod -Uri 'http://127.0.0.1:11434/api/tags' -TimeoutSec 5
    Write-Host "Ollama is running. Models:"
    foreach ($m in $r.models) {
        $sizeGB = [math]::Round($m.size / 1GB, 1)
        Write-Host "  - $($m.name) ($sizeGB GB)"
    }
} catch {
    Write-Host "Ollama not responding: $($_.Exception.Message)"
}
