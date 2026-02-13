# Search for any TTS-related activity in today's log
Write-Host "=== TTS activity ==="
$tts = Select-String -Path 'C:\tmp\openclaw\openclaw-2026-02-11.log' -Pattern 'tts|TTS|elevenlabs|text.*speech|speech.*text' -SimpleMatch:$false
Write-Host "Total TTS log lines: $($tts.Count)"
Write-Host ""

# Check for ElevenLabs API calls
Write-Host "=== ElevenLabs API calls ==="
$el = Select-String -Path 'C:\tmp\openclaw\openclaw-2026-02-11.log' -Pattern 'elevenlabs|xi-api|eleven'
Write-Host "ElevenLabs log lines: $($el.Count)"
if ($el.Count -gt 0) {
    foreach ($line in ($el | Select-Object -Last 5)) {
        $text = $line.Line
        if ($text.Length -gt 300) { $text = $text.Substring(0, 300) + "..." }
        Write-Host $text
        Write-Host "---"
    }
}

# Check for verbose TTS lines
Write-Host ""
Write-Host "=== TTS verbose ==="
$verbose = Select-String -Path 'C:\tmp\openclaw\openclaw-2026-02-11.log' -Pattern 'TTS:'
Write-Host "TTS verbose lines: $($verbose.Count)"
if ($verbose.Count -gt 0) {
    foreach ($line in ($verbose | Select-Object -Last 5)) {
        $text = $line.Line
        if ($text.Length -gt 300) { $text = $text.Substring(0, 300) + "..." }
        Write-Host $text
        Write-Host "---"
    }
}

# Check tts prefs file
Write-Host ""
Write-Host "=== TTS prefs file ==="
$prefsPath = "C:\Users\Dell\.openclaw\settings\tts.json"
if (Test-Path $prefsPath) {
    Write-Host (Get-Content $prefsPath -Raw)
} else {
    Write-Host "No tts.json prefs file found at $prefsPath"
}
