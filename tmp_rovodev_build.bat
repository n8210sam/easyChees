@echo off
chcp 65001 >nul
echo Building Flutter web app...
flutter clean
flutter pub get
flutter build web --release
echo Build completed successfully!