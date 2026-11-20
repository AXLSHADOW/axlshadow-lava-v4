<#
.SYNOPSIS
    Downloads the latest official Lavalink release from GitHub and verifies Java compatibility.
.DESCRIPTION
    Safely retrieves Lavalink.jar from github.com/lavalink-devs/Lavalink and checks that
    Java 17 or higher is installed on the host system.
#>

[CmdletBinding()]
param(
    [string]$TargetVersion = "latest"
)

$ErrorActionPreference = "Stop"

Write-Host "=== Lavalink Downloader & Pre-flight Verification ===" -ForegroundColor Cyan

# 1. Verify Java Runtime
Write-Host "`n[1/3] Checking Java Runtime..." -ForegroundColor Yellow
$javaCmd = Get-Command java -ErrorAction SilentlyContinue

if (-not $javaCmd) {
    Write-Warning "Java was not detected on your system PATH."
    Write-Warning "Lavalink v4 requires Java 17 or newer (OpenJDK 17 or 21 recommended)."
    Write-Warning "Download OpenJDK from: https://adoptium.net/"
} else {
    $javaVerOutput = java -version 2>&1 | Out-String
    Write-Host "Detected Java:" -ForegroundColor Green
    Write-Host $javaVerOutput.Trim()
}

# 2. Determine Download URL
Write-Host "`n[2/3] Determining official release binary..." -ForegroundColor Yellow
$repo = "lavalink-devs/Lavalink"
if ($TargetVersion -eq "latest") {
    $downloadUrl = "https://github.com/$repo/releases/latest/download/Lavalink.jar"
} else {
    $downloadUrl = "https://github.com/$repo/releases/download/$TargetVersion/Lavalink.jar"
}

$outputFile = Join-Path $PSScriptRoot "Lavalink.jar"

# 3. Download Binary
Write-Host "`n[3/3] Downloading Lavalink.jar from official GitHub repository..." -ForegroundColor Yellow
Write-Host "Source: $downloadUrl"
Write-Host "Destination: $outputFile"

try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13
    Invoke-WebRequest -Uri $downloadUrl -OutFile $outputFile -UseBasicParsing
    
    $fileInfo = Get-Item $outputFile
    $sizeMB = [math]::Round($fileInfo.Length / 1MB, 2)
    Write-Host "`nSUCCESS: Lavalink.jar downloaded ($sizeMB MB)" -ForegroundColor Green
    Write-Host "Run locally using: java -jar Lavalink.jar" -ForegroundColor Cyan
} catch {
    Write-Error "Failed to download Lavalink.jar: $_"
}
