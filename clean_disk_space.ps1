# Script untuk membersihkan disk space - menghapus cache Gradle, Pub, dll
Write-Host "=== Cleaning Disk Space ===" -ForegroundColor Cyan

$totalFreed = 0

# 1. Clean Gradle caches
Write-Host "`n[1/5] Cleaning Gradle caches..." -ForegroundColor Yellow
if (Test-Path "$env:USERPROFILE\.gradle\caches") {
    $size = (Get-ChildItem "$env:USERPROFILE\.gradle\caches" -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum / 1GB
    Remove-Item -Recurse -Force "$env:USERPROFILE\.gradle\caches" -ErrorAction SilentlyContinue
    $totalFreed += $size
    Write-Host "  Freed: $([math]::Round($size, 2)) GB" -ForegroundColor Green
}

# 2. Clean Gradle temp files
Write-Host "[2/5] Cleaning Gradle temp files..." -ForegroundColor Yellow
if (Test-Path "$env:USERPROFILE\.gradle\.tmp") {
    Remove-Item -Recurse -Force "$env:USERPROFILE\.gradle\.tmp" -ErrorAction SilentlyContinue
    Write-Host "  Gradle temp files deleted" -ForegroundColor Green
}

# 3. Clean Gradle daemon
Write-Host "[3/5] Cleaning Gradle daemon cache..." -ForegroundColor Yellow
if (Test-Path "$env:USERPROFILE\.gradle\daemon") {
    Remove-Item -Recurse -Force "$env:USERPROFILE\.gradle\daemon" -ErrorAction SilentlyContinue
    Write-Host "  Gradle daemon cache deleted" -ForegroundColor Green
}

# 4. Clean Gradle wrapper cache
Write-Host "[4/5] Cleaning Gradle wrapper cache..." -ForegroundColor Yellow
if (Test-Path "$env:USERPROFILE\.gradle\wrapper\dists") {
    $size = (Get-ChildItem "$env:USERPROFILE\.gradle\wrapper\dists" -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum / 1GB
    Remove-Item -Recurse -Force "$env:USERPROFILE\.gradle\wrapper\dists" -ErrorAction SilentlyContinue
    $totalFreed += $size
    Write-Host "  Freed: $([math]::Round($size, 2)) GB" -ForegroundColor Green
}

# 5. Clean Pub cache
Write-Host "[5/5] Cleaning Pub cache..." -ForegroundColor Yellow
if (Test-Path "$env:LOCALAPPDATA\Pub\Cache") {
    $size = (Get-ChildItem "$env:LOCALAPPDATA\Pub\Cache" -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum / 1GB
    Remove-Item -Recurse -Force "$env:LOCALAPPDATA\Pub\Cache" -ErrorAction SilentlyContinue
    $totalFreed += $size
    Write-Host "  Freed: $([math]::Round($size, 2)) GB" -ForegroundColor Green
}

# Show summary
Write-Host "`n=== Summary ===" -ForegroundColor Cyan
Write-Host "Total space freed: $([math]::Round($totalFreed, 2)) GB" -ForegroundColor Green

# Show free space
$freeSpace = (Get-PSDrive C).Free / 1GB
Write-Host "Free space on C: drive: $([math]::Round($freeSpace, 2)) GB" -ForegroundColor Cyan

Write-Host "`n=== Done! ===" -ForegroundColor Green

