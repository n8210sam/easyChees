# 📱 如何構建 Android APK

## 🚀 快速方法

### 使用 Augment 快捷指令
```bash
ba  # 構建 Android APK
as  # 查看 Android 設置指南
```

### 使用 VSCode 任務
1. 按 `Ctrl+Shift+P`
2. 輸入 "Tasks: Run Task"
3. 選擇 "Build Android APK"

### 使用腳本
```powershell
.\scripts\build-android.ps1
```

## 📋 前置要求

### 方法一：本地構建
1. **安裝 Android Studio**
   - 下載：https://developer.android.com/studio
   - 安裝並跟隨設置向導

2. **配置 Flutter**
   ```bash
   flutter doctor --android-licenses
   flutter doctor
   ```

### 方法二：GitHub Actions（推薦）
1. 將代碼推送到 GitHub
2. GitHub Actions 會自動構建 APK
3. 在 Actions 頁面下載構建好的 APK

## 📦 APK 信息

- **應用名稱**: 數獨遊戲
- **包名**: com.easychees.sudoku
- **版本**: 1.1.0+4
- **目標 SDK**: Android 5.0+ (API 21+)

## 📁 輸出位置

構建完成後，APK 位於：
```
build/app/outputs/flutter-apk/app-release.apk
```

## 🔧 故障排除

### Android SDK 未找到
```bash
# 檢查 Flutter 配置
flutter doctor

# 如果需要，設置 Android SDK 路徑
flutter config --android-sdk /path/to/android/sdk
```

### 許可證問題
```bash
flutter doctor --android-licenses
```

### 構建失敗
```bash
flutter clean
flutter pub get
flutter build apk --release
```

## 📱 安裝 APK

### 在 Android 設備上
1. 啟用"未知來源"安裝
2. 將 APK 傳輸到設備
3. 點擊安裝

### 使用 ADB
```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

## 🎯 建議

1. **首次構建**: 建議使用 GitHub Actions
2. **開發測試**: 安裝 Android Studio 進行本地構建
3. **發布**: 使用簽名密鑰構建正式版本

---

**提示**: 如果本地構建有困難，GitHub Actions 是最簡單的方法！
