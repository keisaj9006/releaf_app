param(
    [switch]$SkipTests
)

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $PSScriptRoot
Push-Location $repoRoot

try {
    $keyProperties = Join-Path $repoRoot "android\key.properties"
    if (-not (Test-Path $keyProperties)) {
        throw "Production signing is not configured. Copy android/key.properties.example to android/key.properties and point it at the private upload keystore."
    }

    $revenueCatKey = $env:REVENUECAT_ANDROID_API_KEY
    if ([string]::IsNullOrWhiteSpace($revenueCatKey)) {
        throw "REVENUECAT_ANDROID_API_KEY is required for a Play release build."
    }

    if ($revenueCatKey.StartsWith("REVENUECAT_") -or $revenueCatKey -match "CHANGE_ME|smoke|dummy|example") {
        throw "REVENUECAT_ANDROID_API_KEY looks like a placeholder. Refusing to build a production bundle."
    }

    $versionMatch = Select-String -Path "pubspec.yaml" -Pattern '^version:\s*([^\s]+)\s*$' | Select-Object -First 1
    if ($null -eq $versionMatch) {
        throw "Unable to read the Flutter version from pubspec.yaml."
    }

    $version = $versionMatch.Matches[0].Groups[1].Value
    if (-not $version.StartsWith("1.0.0+")) {
        throw "Play release gate requires a final 1.0.0+<build> version. Current version: $version"
    }

    Write-Host "=== Releaf 1.0 production gate ==="
    Write-Host "Version: $version"
    Write-Host "Package: app.releaf.mobile"
    Write-Host "Target: Android 16 / API 36"

    flutter pub get
    if ($LASTEXITCODE -ne 0) { throw "flutter pub get failed." }

    flutter analyze
    if ($LASTEXITCODE -ne 0) { throw "flutter analyze failed." }

    if (-not $SkipTests) {
        flutter test
        if ($LASTEXITCODE -ne 0) { throw "flutter test failed." }
    }

    flutter build appbundle --release --dart-define=REVENUECAT_ANDROID_API_KEY="$revenueCatKey"
    if ($LASTEXITCODE -ne 0) { throw "Production Android App Bundle build failed." }

    $bundle = Join-Path $repoRoot "build\app\outputs\bundle\release\app-release.aab"
    if (-not (Test-Path $bundle)) {
        throw "Expected release bundle was not produced: $bundle"
    }

    $item = Get-Item $bundle
    Write-Host ""
    Write-Host "SUCCESS: Releaf Play release bundle created."
    Write-Host "AAB: $($item.FullName)"
    Write-Host "Size: $([math]::Round($item.Length / 1MB, 2)) MB"
} finally {
    Pop-Location
}
