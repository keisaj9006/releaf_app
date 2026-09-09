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

    $revenueCatKey = ([string]$env:REVENUECAT_ANDROID_API_KEY).Trim()
    dart run tool/release/revenuecat_key_policy.dart "$revenueCatKey"
    if ($LASTEXITCODE -ne 0) {
        throw "REVENUECAT_ANDROID_API_KEY is not a valid production Google Play RevenueCat SDK key."
    }

    $dataController = $env:RELEAF_DATA_CONTROLLER_NAME
    $privacyEmail = $env:RELEAF_PRIVACY_CONTACT_EMAIL
    $privacyUrl = $env:RELEAF_PRIVACY_POLICY_URL
    $deletionUrl = $env:RELEAF_ACCOUNT_DELETION_URL
    $privacyUpdated = $env:RELEAF_PRIVACY_LAST_UPDATED

    foreach ($entry in @{
        RELEAF_DATA_CONTROLLER_NAME = $dataController
        RELEAF_PRIVACY_CONTACT_EMAIL = $privacyEmail
        RELEAF_PRIVACY_POLICY_URL = $privacyUrl
        RELEAF_ACCOUNT_DELETION_URL = $deletionUrl
        RELEAF_PRIVACY_LAST_UPDATED = $privacyUpdated
    }.GetEnumerator()) {
        if ([string]::IsNullOrWhiteSpace([string]$entry.Value)) {
            throw "$($entry.Key) is required for a Play release build."
        }
    }

    if ($privacyEmail -notmatch '^[^@\s]+@[^@\s]+\.[^@\s]+$') {
        throw "RELEAF_PRIVACY_CONTACT_EMAIL must be a valid email address."
    }

    foreach ($urlEntry in @{
        RELEAF_PRIVACY_POLICY_URL = $privacyUrl
        RELEAF_ACCOUNT_DELETION_URL = $deletionUrl
    }.GetEnumerator()) {
        $parsed = $null
        $valid = [System.Uri]::TryCreate(
            [string]$urlEntry.Value,
            [System.UriKind]::Absolute,
            [ref]$parsed
        )
        if (-not $valid -or $parsed.Scheme -ne "https") {
            throw "$($urlEntry.Key) must be an absolute HTTPS URL."
        }
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

    flutter build appbundle --release `
        --dart-define=REVENUECAT_ANDROID_API_KEY="$revenueCatKey" `
        --dart-define=RELEAF_DATA_CONTROLLER_NAME="$dataController" `
        --dart-define=RELEAF_PRIVACY_CONTACT_EMAIL="$privacyEmail" `
        --dart-define=RELEAF_PRIVACY_POLICY_URL="$privacyUrl" `
        --dart-define=RELEAF_ACCOUNT_DELETION_URL="$deletionUrl" `
        --dart-define=RELEAF_PRIVACY_LAST_UPDATED="$privacyUpdated"
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
