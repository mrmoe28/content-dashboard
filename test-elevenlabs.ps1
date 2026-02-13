Write-Host "Testing ElevenLabs connectivity..."
try {
    $r = Invoke-WebRequest -Uri "https://api.elevenlabs.io/v1/voices" -Headers @{
        "xi-api-key" = "sk_e92b266df3f942f72cc64f1fb24ea41c219997736f5804da"
    } -TimeoutSec 20 -UseBasicParsing
    Write-Host "Status: $($r.StatusCode)"
    Write-Host "Content length: $($r.Content.Length)"
} catch {
    Write-Host "Error: $($_.Exception.Message)"
    Write-Host ""
    Write-Host "Testing basic HTTPS connectivity..."
    try {
        $t = Invoke-WebRequest -Uri "https://www.google.com" -TimeoutSec 5 -UseBasicParsing
        Write-Host "Google reachable: $($t.StatusCode)"
    } catch {
        Write-Host "Google also failed: $($_.Exception.Message)"
    }
    Write-Host ""
    Write-Host "DNS test..."
    try {
        $dns = Resolve-DnsName "api.elevenlabs.io" -ErrorAction Stop
        Write-Host "DNS resolved: $($dns[0].IPAddress)"
    } catch {
        Write-Host "DNS failed: $($_.Exception.Message)"
    }
}
