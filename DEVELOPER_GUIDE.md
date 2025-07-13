# 開發者指南 - 數獨遊戲項目

## ⭐ **重要開發規範** (必須遵守)

### **版本號 Log 規範** 🚨 **重要**
```dart
// 在 lib/main.dart 中，開發環境必須 log 版本號
void main() {
  // Only print in debug mode
  if (kDebugMode) {
    debugPrint('=== 數獨遊戲啟動 - 版本 v1.2.1 ===');
  }
  runApp(const SudokuApp());
}
```

### **UI 設計規範** 🎨 **固定不可更改**
- **控制按鈕順序**: 筆記 → 連續輸入 → 自動完成 → 提示 → 撤銷 → 重做
- **數字鍵佈局**:
  - 直式畫面：兩行 (1-5 / 6-9+刪除)
  - 橫式畫面：單行 (1-9+刪除)
- **響應式設計**: 手機(<600px)隱藏中文標籤，平板+顯示中文標籤
- **計時器格式**: 支援小時顯示 (HH:MM:SS 或 MM:SS)

### **功能規範**
- **自動完成**: 不可撤銷操作
- **返回首頁**: 自動暫停計時並確認
- **版本號**: 動態從 pubspec.yaml 讀取

### **響應式設計標準**
```dart
final screenWidth = MediaQuery.of(context).size.width;
final isMobile = screenWidth < 600; // 手機判斷標準
```

---

## 🚀 快速開始

### 使用 Augment 的開發者

如果你使用 Augment 擴展，所有開發指令已經預配置好了！你可以直接使用以下快捷指令：

#### 版本管理
```bash
# 快速更新版本號 (patch)
bv "新增自動完成功能"

# 完整版本管理
vm patch "修復錯誤"
vm minor "新增重要功能" 
vm major "重大版本更新"
```

#### 構建和測試
```bash
# 構建並啟動服務器
bs

# 快速測試
qt

# 構建 Android APK
ba

# 查看 Android 設置指南
as
```

### 手動使用腳本

如果你沒有使用 Augment，可以直接執行 PowerShell 腳本：

```powershell
# 快速版本更新
.\scripts\bump-version.ps1 "功能描述"

# 完整版本管理
.\scripts\version-manager.ps1 patch "修復錯誤"
.\scripts\version-manager.ps1 minor "新增功能"
.\scripts\version-manager.ps1 major "重大更新"

# 構建應用
flutter build web

# 啟動服務器
python -m http.server 3000 --directory build/web
```

## 📋 版本管理說明

### 版本號格式
- **格式**: `major.minor.patch+build`
- **例如**: `2.8.0+15`

### 版本類型
- **patch**: 錯誤修復、小改進 (2.8.0 → 2.8.1)
- **minor**: 新功能、向後兼容 (2.8.0 → 2.9.0)  
- **major**: 重大變更、可能不兼容 (2.8.0 → 3.0.0)

### 自動更新的文件
1. `pubspec.yaml` - Flutter 項目版本
2. `lib/main.dart` - 應用啟動時顯示的版本
3. `CHANGELOG.md` - 版本更新歷史

## 🛠️ 開發工作流程

### 1. 開發新功能
```bash
# 1. 開發代碼
# 2. 測試功能
qt

# 3. 更新版本
bv "新增XXX功能"

# 4. 構建和測試
bs
```

### 2. 修復錯誤
```bash
# 1. 修復代碼
# 2. 測試修復
qt

# 3. 更新版本
vm patch "修復XXX錯誤"

# 4. 重新構建
bs
```

### 3. 發布新版本
```bash
# 1. 確保所有測試通過
qt

# 2. 更新版本號
vm minor "版本 X.X.X 發布"

# 3. 構建發布版本
flutter build web --release

# 4. 提交到版本控制
git add .
git commit -m "Release version X.X.X"
git tag vX.X.X
```

## 🔧 Augment 配置說明

項目包含了完整的 Augment 配置 (`.augment/config.json`)，提供：

### 性能優化
- 降低索引頻率，減少 CPU 使用
- 限制處理文件類型
- 優化記憶體使用

### 開發者指令
- 自動版本管理
- 快速構建和測試
- 智能文件監控

### 快捷方式
- `bv` = bump-version
- `vm` = version-manager
- `bs` = build-and-serve  
- `qt` = quick-test

## 📁 項目結構

```
easyChees/
├── lib/                    # Flutter 應用代碼
├── scripts/               # 開發腳本
│   ├── version-manager.ps1 # 完整版本管理
│   └── bump-version.ps1   # 快速版本更新
├── .augment/              # Augment 配置
│   └── config.json        # 開發者指令配置
├── .vscode/               # VSCode 設置
├── CHANGELOG.md           # 版本歷史
├── DEVELOPER_GUIDE.md     # 本文件
└── README.md              # 項目說明
```

## 🎯 最佳實踐

### **開發流程規範** (必須遵守)
1. **修改代碼**
2. **測試功能**:
   - `flutter analyze` (必須 0 issues)
   - `flutter test` (必須全部通過)
   - 手動測試核心功能
3. **更新版本號**: 每次修改都必須更新
4. **構建測試**: `flutter build web`
5. **提交代碼**: 經確認後提交

### **版本管理規範**
- **使用語義化版本**: major.minor.patch+build
- **版本描述要清楚具體**
- **使用快捷指令提高效率**
- **定期查看 CHANGELOG.md**

## 🤝 團隊協作

### 新成員加入
1. 安裝 Augment 擴展
2. 克隆項目
3. 執行 `flutter pub get`
4. 開始使用 `bv` 和 `vm` 指令

### 版本衝突處理
- 使用 `vm` 指令確保版本號遞增
- 合併代碼前檢查版本號
- 遵循語義化版本規範

---

**提示**: 所有指令都已經在 Augment 中預配置，直接使用快捷方式即可！
