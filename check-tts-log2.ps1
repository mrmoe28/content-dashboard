# Check for TTS conversion/delivery errors
$lines = Select-String -Path 'C:\tmp\openclaw\openclaw-2026-02-11.log' -Pattern 'tts\.convert|tts.*error|tts.*fail|audio.*send|audio.*deliver|mediaUrl|voice.*message' | Select-Object -Last 15
if ($lines.Count -eq 0) {
    Write-Host "No TTS conversion/delivery log entries found today."
    Write-Host ""
    Write-Host "Checking for outbound WhatsApp messages..."
    $wa = Select-String -Path 'C:\tmp\openclaw\openclaw-2026-02-11.log' -Pattern 'whatsapp.*send|whatsapp.*deliver|outbound.*whatsapp|wa.*reply' | Select-Object -Last 10
    foreach ($line in $wa) {
        $text = $line.Line
        if ($text.Length -gt 400) { $text = $text.Substring(0, 400) + "..." }
        Write-Host $text
        Write-Host "---"
    }
} else {
    foreach ($line in $lines) {
        $text = $line.Line
        if ($text.Length -gt 400) { $text = $text.Substring(0, 400) + "..." }
        Write-Host $text
        Write-Host "---"
    }
}
