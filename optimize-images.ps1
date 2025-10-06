# Script para optimizar imágenes
param(
    [string]$ImagePath = "assets\images",
    [int]$Quality = 85,
    [int]$MaxWidth = 1200
)

# Función para optimizar imagen usando System.Drawing
function Optimize-Image {
    param(
        [string]$InputPath,
        [string]$OutputPath,
        [int]$Quality = 85,
        [int]$MaxWidth = 1200
    )
    
    try {
        # Cargar la imagen original
        $originalImage = [System.Drawing.Image]::FromFile($InputPath)
        
        # Calcular nuevas dimensiones manteniendo proporción
        $ratio = $originalImage.Width / $originalImage.Height
        $newWidth = [Math]::Min($MaxWidth, $originalImage.Width)
        $newHeight = [Math]::Floor($newWidth / $ratio)
        
        # Crear nueva imagen redimensionada
        $newImage = New-Object System.Drawing.Bitmap($newWidth, $newHeight)
        $graphics = [System.Drawing.Graphics]::FromImage($newImage)
        $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $graphics.DrawImage($originalImage, 0, 0, $newWidth, $newHeight)
        
        # Configurar calidad JPEG
        $jpegCodec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq "image/jpeg" }
        $encoderParams = New-Object System.Drawing.Imaging.EncoderParameters(1)
        $encoderParams.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality, $Quality)
        
        # Guardar imagen optimizada
        $newImage.Save($OutputPath, $jpegCodec, $encoderParams)
        
        # Limpiar recursos
        $graphics.Dispose()
        $newImage.Dispose()
        $originalImage.Dispose()
        
        return $true
    }
    catch {
        Write-Host "Error optimizando $InputPath : $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Cargar librerías necesarias
Add-Type -AssemblyName System.Drawing

# Lista de imágenes a optimizar (las más pesadas)
$imagesToOptimize = @(
    "castleberry-location-map.png",
    "concepto-arquitectonico.png", 
    "ejemplo5.png",
    "planta-arquitectonica.png",
    "escena-3.png",
    "escena-2.png",
    "escena-1.png"
)

Write-Host "Iniciando optimización de imágenes..." -ForegroundColor Green

foreach ($imageName in $imagesToOptimize) {
    $inputPath = Join-Path $ImagePath $imageName
    $outputPath = $inputPath -replace '\.png$', '.jpg'
    
    if (Test-Path $inputPath) {
        Write-Host "Optimizando: $imageName" -ForegroundColor Yellow
        
        # Obtener tamaño original
        $originalSize = (Get-Item $inputPath).Length
        
        if (Optimize-Image -InputPath $inputPath -OutputPath $outputPath -Quality $Quality -MaxWidth $MaxWidth) {
            # Obtener tamaño optimizado
            $optimizedSize = (Get-Item $outputPath).Length
            $reduction = [Math]::Round((($originalSize - $optimizedSize) / $originalSize) * 100, 1)
            
            Write-Host "  Original: $([Math]::Round($originalSize/1MB,2)) MB" -ForegroundColor Cyan
            Write-Host "  Optimizado: $([Math]::Round($optimizedSize/1MB,2)) MB" -ForegroundColor Cyan
            Write-Host "  Reducción: $reduction%" -ForegroundColor Green
            
            # Eliminar PNG original solo si el JPG es significativamente más pequeño
            if ($reduction -gt 30) {
                Remove-Item $inputPath
                Write-Host "  PNG original eliminado" -ForegroundColor Yellow
            }
        }
    } else {
        Write-Host "No se encontró: $imageName" -ForegroundColor Red
    }
}

Write-Host "Optimización completada!" -ForegroundColor Green