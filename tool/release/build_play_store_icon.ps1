param(
    [string]$Root = (Split-Path -Parent (Split-Path -Parent $PSScriptRoot))
)

$ErrorActionPreference = "Stop"
$source = Join-Path $Root "assets\icon\app_icon.png"
$targetDirectory = Join-Path $Root "store\google-play"
$target = Join-Path $targetDirectory "app-icon.png"
$expectedSourceSha256 = "9D44B42A62268FA2B9ED79C92C3F245A5DC451F1B8DFAFC1BD3648D77029CAB2"

if (-not (Test-Path -LiteralPath $source)) {
    throw "Releaf launcher source was not found: $source"
}

$sourceSha256 = (Get-FileHash -LiteralPath $source -Algorithm SHA256).Hash
if ($sourceSha256 -ne $expectedSourceSha256) {
    throw "Releaf launcher source changed. Review the mark and update the expected hash deliberately."
}

Add-Type -AssemblyName System.Drawing
New-Item -ItemType Directory -Force -Path $targetDirectory | Out-Null

$input = [System.Drawing.Image]::FromFile($source)
$output = [System.Drawing.Bitmap]::new(
    512,
    512,
    [System.Drawing.Imaging.PixelFormat]::Format32bppArgb
)

try {
    $output.SetResolution(72, 72)
    $graphics = [System.Drawing.Graphics]::FromImage($output)
    try {
        $graphics.CompositingMode = [System.Drawing.Drawing2D.CompositingMode]::SourceCopy
        $graphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
        $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
        $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
        $graphics.DrawImage($input, 0, 0, 512, 512)
    } finally {
        $graphics.Dispose()
    }
    $output.Save($target, [System.Drawing.Imaging.ImageFormat]::Png)
} finally {
    $output.Dispose()
    $input.Dispose()
}

Write-Host "Google Play icon created: $target"
Write-Host "SHA-256: $((Get-FileHash -LiteralPath $target -Algorithm SHA256).Hash)"
