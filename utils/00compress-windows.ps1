# PowerShell script to compress images using Windows built-in .NET libraries
# No additional software installation required!

Add-Type -AssemblyName System.Drawing

$sourceFolder = "C:\github\sentineltile\images\fulls"
$outputFolder = "C:\github\sentineltile\images\fulls_compressed"

# Create output folder if it doesn't exist
if (!(Test-Path $outputFolder)) {
  New-Item -ItemType Directory -Path $outputFolder
}

# JPEG Encoder with quality setting
$encoderParams = New-Object System.Drawing.Imaging.EncoderParameters(1)
$encoderParams.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality, 75L)

# Get JPEG codec
$jpegCodec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq "image/jpeg" }

# Get all JPG files
$images = Get-ChildItem $sourceFolder -Filter "*.jpg"

Write-Host "Found $($images.Count) images to compress..."

foreach ($image in $images) {
  try {
    $inputPath = $image.FullName
    $outputPath = Join-Path $outputFolder $image.Name
        
    Write-Host "Processing: $($image.Name)"
        
    # Load the image
    $bitmap = [System.Drawing.Image]::FromFile($inputPath)
        
    # Resize if too large (max width 1920)
    if ($bitmap.Width -gt 1920) {
      $ratio = 1920 / $bitmap.Width
      $newWidth = 1920
      $newHeight = [int]($bitmap.Height * $ratio)
            
      $resized = New-Object System.Drawing.Bitmap($newWidth, $newHeight)
      $graphics = [System.Drawing.Graphics]::FromImage($resized)
      $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
      $graphics.DrawImage($bitmap, 0, 0, $newWidth, $newHeight)
            
      $bitmap.Dispose()
      $bitmap = $resized
      $graphics.Dispose()
    }
        
    # Save with compression
    $bitmap.Save($outputPath, $jpegCodec, $encoderParams)
    $bitmap.Dispose()
        
  }
  catch {
    Write-Host "Error processing $($image.Name): $($_.Exception.Message)" -ForegroundColor Red
  }
}

Write-Host "Compression complete! Check the 'fulls_compressed' folder." -ForegroundColor Green

# Show size comparison
$originalSize = (Get-ChildItem $sourceFolder -Filter "*.jpg" | Measure-Object -Property Length -Sum).Sum
$compressedSize = (Get-ChildItem $outputFolder -Filter "*.jpg" | Measure-Object -Property Length -Sum).Sum

Write-Host "Original size: $([math]::Round($originalSize/1MB, 2)) MB"
Write-Host "Compressed size: $([math]::Round($compressedSize/1MB, 2)) MB"
Write-Host "Savings: $([math]::Round((1 - $compressedSize/$originalSize) * 100, 1))%" -ForegroundColor Green