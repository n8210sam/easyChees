# Android APK Build Script
# This script builds the Android APK for the Sudoku game

Write-Host "=== Android APK Build Script ===" -ForegroundColor Green

# Check if Android SDK is available
$androidSdkCheck = flutter doctor --android-licenses 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "Android SDK not found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "To build Android APK, you need to install Android SDK:" -ForegroundColor Yellow
    Write-Host "1. Download Android Studio from: https://developer.android.com/studio" -ForegroundColor Cyan
    Write-Host "2. Install Android Studio and follow the setup wizard" -ForegroundColor Cyan
    Write-Host "3. Accept Android licenses: flutter doctor --android-licenses" -ForegroundColor Cyan
    Write-Host "4. Run this script again" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Alternative: Use online build services like Codemagic or GitHub Actions" -ForegroundColor Yellow
    exit 1
}

# Check if project is ready
if (-not (Test-Path "pubspec.yaml")) {
    Write-Host "Error: Please run this script in project root directory" -ForegroundColor Red
    exit 1
}

Write-Host "Building Android APK..." -ForegroundColor Blue

# Clean previous builds
Write-Host "Cleaning previous builds..." -ForegroundColor Yellow
flutter clean

# Get dependencies
Write-Host "Getting dependencies..." -ForegroundColor Yellow
flutter pub get

# Build APK
Write-Host "Building release APK..." -ForegroundColor Yellow
flutter build apk --release

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "=== Build Successful! ===" -ForegroundColor Green
    Write-Host "APK Location: build/app/outputs/flutter-apk/app-release.apk" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "You can now:" -ForegroundColor Yellow
    Write-Host "1. Install on Android device: adb install build/app/outputs/flutter-apk/app-release.apk" -ForegroundColor Cyan
    Write-Host "2. Share the APK file with others" -ForegroundColor Cyan
    Write-Host "3. Upload to Google Play Store (after signing)" -ForegroundColor Cyan
    
    # Show file size
    $apkPath = "build/app/outputs/flutter-apk/app-release.apk"
    if (Test-Path $apkPath) {
        $fileSize = [math]::Round((Get-Item $apkPath).Length / 1MB, 2)
        Write-Host "APK Size: $fileSize MB" -ForegroundColor Green
    }
} else {
    Write-Host ""
    Write-Host "=== Build Failed! ===" -ForegroundColor Red
    Write-Host "Please check the error messages above and fix any issues." -ForegroundColor Yellow
    exit 1
}
