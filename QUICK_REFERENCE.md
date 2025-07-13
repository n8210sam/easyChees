# 🚀 快速參考指南

## ⭐ **開發者必知**

### **版本號 Log 規範** (重要！)
```dart
// lib/main.dart 中必須有此代碼
void main() {
  if (kDebugMode) {
    debugPrint('=== 數獨遊戲啟動 - 版本 v1.2.1 ===');
  }
  runApp(const SudokuApp());
}
```

### **UI 設計規範** (固定不可更改)
- **按鈕順序**: 筆記 → 連續輸入 → 自動完成 → 提示 → 撤銷 → 重做
- **數字鍵**: 直式兩行，橫式單行
- **響應式**: 手機(<600px)隱藏中文，平板+顯示中文

### **開發流程** (必須遵守)
```bash
# 1. 修改代碼
# 2. 測試
flutter analyze  # 必須 0 issues
flutter test     # 必須全部通過

# 3. 更新版本
vm patch "功能描述"

# 4. 構建測試
flutter build web
```

---

## 📋 **重要文檔**
- [📋 完整開發規範](DEVELOPMENT_STANDARDS.md) ⭐ **必讀**
- [🚀 版本管理](VERSION_MANAGEMENT.md)
- [👨‍💻 開發指南](DEVELOPER_GUIDE.md)
- [🔧 項目配置](.augment/project-info.md)

---

## 🎯 **給 AI 助手的提醒**
1. 每次協助開發時，先查看 `DEVELOPMENT_STANDARDS.md`
2. 遵守既定的 UI 設計規範
3. 修改前後都要測試
4. 重要決定要更新文檔

---

**最後更新**: 2025-07-13
