# 🚀 自動版本管理系統

## 快速開始

### 使用 Augment 的開發者 (推薦)

如果你使用 Augment 擴展，可以直接使用快捷指令：

```bash
# 快速更新版本號 (patch)
bv "新增自動完成功能"

# 完整版本管理
vm patch "修復錯誤"
vm minor "新增重要功能" 
vm major "重大版本更新"

# 構建並啟動服務器
bs

# 快速測試
qt
```

### 手動使用腳本

```powershell
# 快速版本更新 (patch)
.\scripts\bump-version.ps1 "功能描述"

# 完整版本管理
.\scripts\version-manager.ps1 patch "修復錯誤"
.\scripts\version-manager.ps1 minor "新增功能"
.\scripts\version-manager.ps1 major "重大更新"
```

### 使用 VSCode 任務

1. 按 `Ctrl+Shift+P` 打開命令面板
2. 輸入 "Tasks: Run Task"
3. 選擇以下任務之一：
   - **Version: Bump Patch** - 快速 patch 更新
   - **Version: Update Minor** - minor 版本更新
   - **Version: Update Major** - major 版本更新
   - **Build and Serve** - 構建並啟動服務器

## 📋 版本管理說明

### 版本號格式
- **格式**: `major.minor.patch+build`
- **當前**: `1.0.1+2`

### 版本類型
- **patch**: 錯誤修復、小改進 (1.0.0 → 1.0.1)
- **minor**: 新功能、向後兼容 (1.0.0 → 1.1.0)  
- **major**: 重大變更、可能不兼容 (1.0.0 → 2.0.0)

### 自動更新的文件
1. `pubspec.yaml` - Flutter 項目版本
2. `lib/main.dart` - 應用啟動時顯示的版本
3. `CHANGELOG.md` - 版本更新歷史

## 🛠️ 開發工作流程

### 1. 開發新功能
```bash
# 1. 開發代碼
# 2. 測試功能
# 3. 更新版本
bv "新增XXX功能"
# 4. 構建和測試
bs
```

### 2. 修復錯誤
```bash
# 1. 修復代碼
# 2. 測試修復
# 3. 更新版本
vm patch "修復XXX錯誤"
# 4. 重新構建
bs
```

## 🎯 最佳實踐

1. **每次修改都更新版本號**
2. **使用有意義的版本描述**
3. **測試後再更新版本**
4. **定期查看 CHANGELOG.md**
5. **使用快捷指令提高效率**

## 🔧 配置文件

- `.augment/config.json` - Augment 開發者指令配置
- `.vscode/tasks.json` - VSCode 任務配置
- `scripts/` - PowerShell 腳本目錄

---

**提示**: 所有指令都已經在 Augment 和 VSCode 中預配置，直接使用即可！
