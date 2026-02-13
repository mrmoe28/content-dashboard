$lines = Select-String -Path 'C:\tmp\openclaw\openclaw-2026-02-11.log' -Pattern 'tts|TTS|elevenlabs|audio' | Select-Object -Last 15
foreach ($line in $lines) {
    $text = $line.Line
    if ($text.Length -gt 400) { $text = $text.Substring(0, 400) + "..." }
    Write-Host $text
    Write-Host "---"
}
