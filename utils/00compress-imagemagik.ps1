# PowerShell script to compress images using ImageMagick
# First install ImageMagick: winget install ImageMagick.ImageMagick

$sourceFolder = "C:\github\sentineltile\images\fulls"
$outputFolder = "C:\github\sentineltile\images\fulls_compressed"

# Create output folder if it doesn't exist
if (!(Test-Path $outputFolder)) {
  New-Item -ItemType Directory -Path $outputFolder
}

# Get all JPG files
$images = Get-ChildItem $sourceFolder -Filter "*.jpg"

Write-Host "Found $($images.Count) images to compress..."

foreach ($image in $images) {
  $inputPath = $image.FullName
  $outputPath = Join-Path $outputFolder $image.Name
    
  Write-Host "Compressing: $($image.Name)"
    
  # Compress using ImageMagick
  # -quality 75 = good quality with significant compression
  # -resize 1920x1080> = resize only if larger than 1920x1080
  magick "$inputPath" -quality 75 -resize 1920x1080> "$outputPath"
}

Write-Host "Compression complete! Check the 'fulls_compressed' folder."

# Show size comparison
$originalSize = (Get-ChildItem $sourceFolder -Filter "*.jpg" | Measure-Object -Property Length -Sum).Sum
$compressedSize = (Get-ChildItem $outputFolder -Filter "*.jpg" | Measure-Object -Property Length -Sum).Sum

Write-Host "Original size: $([math]::Round($originalSize/1MB, 2)) MB"
Write-Host "Compressed size: $([math]::Round($compressedSize/1MB, 2)) MB"
Write-Host "Savings: $([math]::Round((1 - $compressedSize/$originalSize) * 100, 1))%"