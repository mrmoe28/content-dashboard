# Check TTS debug logs
Write-Host "=== TTS Debug Logs ==="
$lines = Select-String -Path 'C:\tmp\openclaw\openclaw-2026-02-11.log' -Pattern 'TTS-DEBUG'
foreach ($line in ($lines | Select-Object -Last 20)) {
    $text = $line.Line
    if ($text.Length -gt 400) { $text = $text.Substring(0, 400) + "..." }
    Write-Host $text
}

# Find recent TTS audio files
Write-Host ""
Write-Host "=== Recent TTS audio files ==="
$ttsFiles = Get-ChildItem "C:\Users\Dell\.openclaw" -Recurse -Include "*.mp3","*.ogg","*.wav","*.opus","*.m4a" -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 5
if ($ttsFiles) {
    foreach ($f in $ttsFiles) {
        Write-Host "  $($f.FullName) ($($f.Length) bytes, $($f.LastWriteTime))"
    }
} else {
    Write-Host "  No audio files found in .openclaw"
}

# Also check temp dir
$tmpFiles = Get-ChildItem $env:TEMP -Include "*.mp3","*.ogg","*.wav","*.opus","*.m4a" -ErrorAction SilentlyContinue | Where-Object { $_.LastWriteTime -gt (Get-Date).AddHours(-1) } | Sort-Object LastWriteTime -Descending | Select-Object -First 5
if ($tmpFiles) {
    Write-Host ""
    Write-Host "=== Recent audio in TEMP ==="
    foreach ($f in $tmpFiles) {
        Write-Host "  $($f.FullName) ($($f.Length) bytes, $($f.LastWriteTime))"
    }
}

# Check what format ElevenLabs returns
Write-Host ""
Write-Host "=== TTS output format config ==="
$lines2 = Select-String -Path 'C:\tmp\openclaw\openclaw-2026-02-11.log' -Pattern 'output.*format|audio.*format|mp3|ogg|opus|content.type.*audio'
foreach ($line in ($lines2 | Select-Object -Last 5)) {
    $text = $line.Line
    if ($text.Length -gt 400) { $text = $text.Substring(0, 400) + "..." }
    Write-Host $text
}
