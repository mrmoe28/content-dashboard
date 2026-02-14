$apiKey = $env:OPENAI_API_KEY  # Set this in your user env vars, not in the script

# Test 1: Check if videos endpoint exists
Write-Host "=== Testing Sora video endpoint ==="
try {
    $response = Invoke-WebRequest -Uri "https://api.openai.com/v1/videos/generations" -Method Post -Headers @{
        "Authorization" = "Bearer $apiKey"
        "Content-Type" = "application/json"
    } -Body '{"model":"sora-2","prompt":"test","size":"720x1280","duration":4,"n":1}' -UseBasicParsing
    Write-Host "Status: $($response.StatusCode)"
    Write-Host "Body: $($response.Content)"
} catch {
    $err = $_.Exception.Response
    $reader = New-Object System.IO.StreamReader($err.GetResponseStream())
    $body = $reader.ReadToEnd()
    Write-Host "HTTP $($err.StatusCode.value__): $body"
}

# Test 2: Check available models
Write-Host ""
Write-Host "=== Checking available models ==="
try {
    $models = Invoke-RestMethod -Uri "https://api.openai.com/v1/models" -Headers @{ "Authorization" = "Bearer $apiKey" }
    $sora = $models.data | Where-Object { $_.id -like "*sora*" -or $_.id -like "*video*" }
    if ($sora) {
        Write-Host "Sora/video models found:"
        $sora | ForEach-Object { Write-Host "  - $($_.id)" }
    } else {
        Write-Host "No sora/video models found in your account."
        Write-Host "Available model prefixes:"
        $models.data | ForEach-Object { $_.id.Split("-")[0] } | Sort-Object -Unique | ForEach-Object { Write-Host "  - $_" }
    }
} catch {
    Write-Host "Failed to list models: $_"
}
