# Script untuk fix Gradle lock file error
Write-Host "=== Fixing Gradle Lock File Error ===" -ForegroundColor Cyan

# 1. Stop all Java/Gradle processes
Write-Host "`n[1/4] Stopping Java/Gradle processes..." -ForegroundColor Yellow
Get-Process | Where-Object {$_.ProcessName -match "java|gradle|dart|flutter"} | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

# 2. Stop Gradle daemon
Write-Host "[2/4] Stopping Gradle daemon..." -ForegroundColor Yellow
if (Test-Path "android\gradlew.bat") {
    Push-Location android
    .\gradlew.bat --stop 2>&1 | Out-Null
    Pop-Location
    Start-Sleep -Seconds 1
}

# 3. Remove Gradle cache
Write-Host "[3/4] Removing Gradle cache..." -ForegroundColor Yellow
if (Test-Path "android\.gradle") {
    Remove-Item -Recurse -Force "android\.gradle" -ErrorAction SilentlyContinue
}
if (Test-Path "android\build") {
    Remove-Item -Recurse -Force "android\build" -ErrorAction SilentlyContinue
}
if (Test-Path "android\app\build") {
    Remove-Item -Recurse -Force "android\app\build" -ErrorAction SilentlyContinue
}

# 4. Flutter clean
Write-Host "[4/4] Running Flutter clean..." -ForegroundColor Yellow
flutter clean | Out-Null
flutter pub get | Out-Null

Write-Host "`n=== Done! ===" -ForegroundColor Green
Write-Host "Sekarang coba jalankan: flutter run" -ForegroundColor Green

