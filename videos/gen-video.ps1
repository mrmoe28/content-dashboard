$apiKey = $env:OPENAI_API_KEY  # Set this in your user env vars, not in the script

Write-Host "Submitting video generation job..."

# Use multipart/form-data as required by the API
$boundary = [System.Guid]::NewGuid().ToString()
$LF = "`r`n"
$bodyLines = @(
    "--$boundary",
    "Content-Disposition: form-data; name=`"prompt`"$LF",
    "UGC style social media video ad for a professional dry cleaning company. A young woman walks into a bright modern dry cleaning shop, picks up her freshly cleaned suit wrapped in clear plastic, holds it up and smiles genuinely at the camera. Natural lighting, casual authentic phone-shot aesthetic. Warm friendly vibe, clean professional environment with clothes on racks in background.",
    "--$boundary",
    "Content-Disposition: form-data; name=`"model`"$LF",
    "sora-2",
    "--$boundary",
    "Content-Disposition: form-data; name=`"size`"$LF",
    "720x1280",
    "--$boundary",
    "Content-Disposition: form-data; name=`"seconds`"$LF",
    "8",
    "--$boundary--$LF"
) -join $LF

try {
    $response = Invoke-RestMethod -Uri "https://api.openai.com/v1/videos" -Method Post -Headers @{
        "Authorization" = "Bearer $apiKey"
    } -ContentType "multipart/form-data; boundary=$boundary" -Body $bodyLines
    $jobId = $response.id
    $status = $response.status
    Write-Host "Job ID: $jobId"
    Write-Host "Initial status: $status"
} catch {
    $err = $_.Exception.Response
    if ($err) {
        $reader = New-Object System.IO.StreamReader($err.GetResponseStream())
        $body = $reader.ReadToEnd()
        Write-Host "Submit error: HTTP $($err.StatusCode.value__): $body"
    } else {
        Write-Host "Submit error: $_"
    }
    exit 1
}

# Poll for completion
$timeout = 300
$elapsed = 0
while ($elapsed -lt $timeout) {
    Start-Sleep -Seconds 5
    $elapsed += 5
    try {
        $poll = Invoke-RestMethod -Uri "https://api.openai.com/v1/videos/$jobId" -Method Get -Headers @{ "Authorization" = "Bearer $apiKey" }
        $status = $poll.status
        Write-Host "[$elapsed s] Status: $status"
        if ($status -eq "completed") {
            $videoUrl = $null
            if ($poll.data -and $poll.data.Count -gt 0) {
                $videoUrl = $poll.data[0].url
            }
            if (-not $videoUrl -and $poll.output -and $poll.output.url) {
                $videoUrl = $poll.output.url
            }
            if (-not $videoUrl) {
                # Download from /content endpoint
                Write-Host "Downloading from /content endpoint..."
                $outPath = "C:\Users\Dell\.openclaw\workspace\videos\drycleaning-ugc-ad.mp4"
                Invoke-WebRequest -Uri "https://api.openai.com/v1/videos/$jobId/content" -Headers @{ "Authorization" = "Bearer $apiKey" } -OutFile $outPath
                Write-Host "Saved to: $outPath"
                $size = (Get-Item $outPath).Length / 1MB
                Write-Host "File size: $([math]::Round($size, 1)) MB"
                exit 0
            }
            Write-Host "Video URL: $videoUrl"
            Write-Host "Downloading..."
            $outPath = "C:\Users\Dell\.openclaw\workspace\videos\drycleaning-ugc-ad.mp4"
            Invoke-WebRequest -Uri $videoUrl -OutFile $outPath
            Write-Host "Saved to: $outPath"
            $size = (Get-Item $outPath).Length / 1MB
            Write-Host "File size: $([math]::Round($size, 1)) MB"
            # Also copy to Downloads for easy access
            Copy-Item $outPath "C:\Users\Dell\Downloads\drycleaning-ugc-ad.mp4"
            Write-Host "Also copied to: C:\Users\Dell\Downloads\drycleaning-ugc-ad.mp4"
            exit 0
        }
        if ($status -eq "failed") {
            Write-Host "FAILED:"
            Write-Host ($poll | ConvertTo-Json -Depth 5)
            exit 1
        }
    } catch {
        Write-Host "[$elapsed s] Poll error: $_"
    }
}
Write-Host "Timed out after $timeout seconds"
exit 1
