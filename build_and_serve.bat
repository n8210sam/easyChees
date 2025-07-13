@echo off
chcp 65001
echo Building Flutter web app...
flutter build web --release
echo Build completed!
echo Starting server...
python serve.py