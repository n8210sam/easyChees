# Context7 MCP 設置指南

## 🚀 Context7 MCP 已成功配置

Context7 MCP 服務器已經成功集成到您的開發環境中，提供最新的代碼文檔和 API 信息支持。

## 📋 配置詳情

### VSCode 設置 (.vscode/settings.json)
```json
"mcp": {
  "servers": {
    "context7": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp"]
    }
  }
}
```

### Augment 配置 (.augment/config.json)
- 添加了 Context7 MCP 項目配置
- 新增測試命令 `context7-test`
- 快捷指令 `c7` 用於測試連接

## 🎯 使用方法

### 1. 基本使用
在任何 AI 助手對話中，只需在提示末尾添加 `use context7`：

```
implement flutter provider state management. use context7
```

```
create responsive UI layout in flutter. use context7
```

```
setup flutter navigation with go_router. use context7
```

### 2. 針對特定庫的查詢
如果您知道確切的庫 ID，可以直接指定：

```
implement basic authentication with supabase. use library /supabase/supabase for api and docs
```

### 3. Flutter 開發專用示例
```
create flutter widget with provider pattern. use context7
setup flutter routing with named routes. use context7
implement flutter local storage with shared_preferences. use context7
configure flutter theme switching. use context7
```

## 🔧 測試 Context7 連接

使用快捷指令測試：
```bash
c7  # 或者 context7-test
```

## 🎨 與 Augment 協同工作

Context7 MCP 與您現有的 Augment 優化設置完美協同：

### 優勢組合
1. **Augment 優化設置**：
   - 降低本地索引頻率
   - 限制處理文件類型
   - 優化記憶體使用

2. **Context7 MCP 補充**：
   - 提供最新的庫文檔
   - 減少對本地索引的依賴
   - 獲取準確的 API 信息

### 性能提升
- ✅ 減少本地資源消耗
- ✅ 獲取最新文檔信息
- ✅ 提高代碼補全準確性
- ✅ 減少查找文檔的時間

## 📚 支持的庫和框架

Context7 支持大量流行的庫和框架，包括但不限於：
- Flutter & Dart
- React & Next.js
- Vue.js & Nuxt.js
- Node.js & Express
- Python & Django
- 以及更多...

## 🛠️ 故障排除

### 如果遇到模塊未找到錯誤
嘗試使用 `bunx` 替代 `npx`：
```json
"command": "bunx",
"args": ["-y", "@upstash/context7-mcp"]
```

### 如果遇到 ESM 解析問題
添加實驗性標誌：
```json
"args": ["-y", "--node-options=--experimental-vm-modules", "@upstash/context7-mcp"]
```

## 🎯 最佳實踐

1. **在複雜查詢中使用**：當需要最新的 API 文檔時
2. **結合具體庫名**：獲得更精確的結果
3. **定期測試連接**：確保服務正常運行
4. **與現有工作流程結合**：不改變現有開發習慣

## 📝 版本記錄

- **v1.0** - 初始 Context7 MCP 配置
- 集成到現有 Augment 優化環境
- 添加測試命令和快捷指令

---

**注意**：重啟 VSCode 以確保 MCP 配置生效。如有任何問題，請檢查 VSCode 開發者工具中的 MCP 相關日誌。
