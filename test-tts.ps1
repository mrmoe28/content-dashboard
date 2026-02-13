# Test 1: Check ElevenLabs API key
Write-Host "=== Testing ElevenLabs API ==="
try {
    $r = Invoke-RestMethod -Uri "https://api.elevenlabs.io/v1/voices" -Headers @{
        "xi-api-key" = "sk_e92b266df3f942f72cc64f1fb24ea41c219997736f5804da"
    } -TimeoutSec 10
    Write-Host "API key valid. Voices available: $($r.voices.Count)"
    $r.voices | Select-Object -First 3 | ForEach-Object { Write-Host "  - $($_.name) ($($_.voice_id))" }
} catch {
    Write-Host "ElevenLabs API error: $($_.Exception.Message)"
}

# Test 2: Check session store for TTS overrides
Write-Host ""
Write-Host "=== Session store ==="
$sessionDirs = @(
    "C:\Users\Dell\.openclaw\agents\main\sessions",
    "C:\Users\Dell\.openclaw\settings"
)
foreach ($dir in $sessionDirs) {
    if (Test-Path $dir) {
        Write-Host "Files in ${dir}:"
        Get-ChildItem $dir -Recurse -File | ForEach-Object { Write-Host "  $($_.FullName) ($($_.Length) bytes)" }
    }
}

# Test 3: Check for session store json files with ttsAuto
Write-Host ""
Write-Host "=== Session TTS overrides ==="
$storeFiles = Get-ChildItem "C:\Users\Dell\.openclaw" -Recurse -Filter "*.json" -ErrorAction SilentlyContinue | Where-Object { $_.Name -match "session|store" }
foreach ($f in $storeFiles) {
    $content = Get-Content $f.FullName -Raw -ErrorAction SilentlyContinue
    if ($content -and $content -match "ttsAuto") {
        Write-Host "Found ttsAuto in: $($f.FullName)"
        Write-Host $content.Substring(0, [Math]::Min($content.Length, 500))
    }
}

# Test 4: Quick TTS conversion test
Write-Host ""
Write-Host "=== TTS conversion test ==="
try {
    $body = @{
        text = "Hello, this is a test of the text to speech system."
        model_id = "eleven_multilingual_v2"
        voice_settings = @{
            stability = 0.5
            similarity_boost = 0.75
        }
    } | ConvertTo-Json
    $audio = Invoke-WebRequest -Uri "https://api.elevenlabs.io/v1/text-to-speech/pMsXgVXv3BLzUgSXRplE" -Method Post -Headers @{
        "xi-api-key" = "sk_e92b266df3f942f72cc64f1fb24ea41c219997736f5804da"
        "Content-Type" = "application/json"
    } -Body $body -TimeoutSec 15
    Write-Host "TTS conversion SUCCESS - got $($audio.Content.Length) bytes of audio"
} catch {
    Write-Host "TTS conversion FAILED: $($_.Exception.Message)"
}
