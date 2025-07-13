# 📱 Android APK 構建指南

## 🚀 快速開始

### 方法一：本地構建（推薦）

#### 1. 安裝 Android Studio
1. 下載 Android Studio：https://developer.android.com/studio
2. 安裝並啟動 Android Studio
3. 跟隨設置向導安裝 Android SDK

#### 2. 配置 Flutter
```bash
# 接受 Android 許可證
flutter doctor --android-licenses

# 檢查配置
flutter doctor
```

#### 3. 構建 APK
```bash
# 使用我們的腳本
.\scripts\build-android.ps1

# 或手動構建
flutter build apk --release
```

### 方法二：線上構建服務

如果不想安裝 Android Studio，可以使用線上服務：

#### GitHub Actions（免費）
1. 將代碼推送到 GitHub
2. 使用 GitHub Actions 自動構建
3. 下載構建好的 APK

#### Codemagic（免費額度）
1. 連接 GitHub 倉庫到 Codemagic
2. 配置構建流程
3. 自動構建並下載 APK

## 📋 項目配置

### 應用信息
- **應用名稱**: 數獨遊戲
- **包名**: com.easychees.sudoku
- **版本**: 1.1.0+4

### 文件結構
```
android/
├── app/
│   ├── build.gradle.kts          # 構建配置
│   └── src/main/
│       ├── AndroidManifest.xml   # 應用清單
│       └── kotlin/com/easychees/sudoku/
│           └── MainActivity.kt    # 主活動
└── build.gradle.kts              # 項目配置
```

## 🛠️ 構建選項

### Debug APK（開發用）
```bash
flutter build apk --debug
```

### Release APK（發布用）
```bash
flutter build apk --release
```

### App Bundle（Google Play）
```bash
flutter build appbundle --release
```

## 📦 APK 位置

構建完成後，APK 文件位於：
```
build/app/outputs/flutter-apk/app-release.apk
```

## 🔧 故障排除

### 常見問題

#### 1. Android SDK 未找到
```bash
# 設置 Android SDK 路徑
flutter config --android-sdk /path/to/android/sdk
```

#### 2. 許可證未接受
```bash
flutter doctor --android-licenses
```

#### 3. Gradle 構建失敗
```bash
# 清理並重新構建
flutter clean
flutter pub get
flutter build apk --release
```

### 檢查系統要求
```bash
flutter doctor -v
```

## 📱 安裝 APK

### 在 Android 設備上安裝
1. 啟用"未知來源"安裝
2. 將 APK 文件傳輸到設備
3. 點擊 APK 文件安裝

### 使用 ADB 安裝
```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

## 🚀 發布到 Google Play

### 1. 生成簽名密鑰
```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

### 2. 配置簽名
在 `android/key.properties` 中配置密鑰信息

### 3. 構建簽名 APK
```bash
flutter build appbundle --release
```

### 4. 上傳到 Google Play Console

## 🎯 最佳實踐

1. **測試**: 在多個設備上測試 APK
2. **優化**: 使用 `--split-per-abi` 減小 APK 大小
3. **簽名**: 發布前使用正式簽名
4. **版本**: 每次發布更新版本號

## 📞 支援

如果遇到問題：
1. 檢查 `flutter doctor` 輸出
2. 查看構建日誌
3. 參考 Flutter 官方文檔
4. 使用線上構建服務作為替代方案

---

**提示**: 如果本地構建有困難，建議使用 GitHub Actions 進行自動化構建！
