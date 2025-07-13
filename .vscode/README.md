# VSCode Augment 擴展性能優化配置

本配置文件夾包含了針對 VSCode 中 Augment 擴展的性能優化設置，旨在解決擴展變慢的問題。

## 主要優化措施

### 1. 降低索引頻率
- `augment.indexing.frequency`: 設置為 "low"
- `augment.indexing.throttle`: 5000ms 延遲
- `augment.indexing.batchSize`: 每批處理 50 個文件
- `augment.indexing.maxConcurrency`: 最多 2 個並發索引任務

### 2. 限制處理的文件類型
只處理重要的代碼文件：
- Dart 文件 (*.dart)
- JavaScript/TypeScript 文件 (*.js, *.ts, *.jsx, *.tsx)
- Python 文件 (*.py)
- Java/Kotlin 文件 (*.java, *.kt)
- Swift 文件 (*.swift)
- C/C++ 文件 (*.c, *.cpp, *.h, *.hpp)
- C# 文件 (*.cs)
- Go 文件 (*.go)
- Rust 文件 (*.rs)
- PHP 文件 (*.php)
- Ruby 文件 (*.rb)
- Scala 文件 (*.scala)
- Shell 腳本 (*.sh)
- 配置文件 (*.yaml, *.yml, *.json, *.xml)
- 文檔文件 (*.md)

### 3. 排除不必要的文件和目錄
排除以下目錄和文件類型：
- 構建輸出目錄 (build/, dist/, out/, target/)
- 依賴目錄 (node_modules/, .dart_tool/, .pub-cache/)
- 平台特定構建目錄 (android/build/, ios/build/, 等)
- 版本控制目錄 (.git/, .svn/, .hg/)
- 臨時文件和緩存文件
- 二進制文件 (*.exe, *.dll, *.so, *.jar, 等)

### 4. 增加 VSCode 記憶體限制
- `augment.memory.maxHeapSize`: 2048MB
- `augment.memory.initialHeapSize`: 512MB
- `augment.memory.cacheSize`: 256MB

### 5. 性能優化設置
- 禁用實時分析，改為保存時分析
- 增加防抖延遲到 1000ms
- 限制同時處理的文件數量為 100
- 設置文件大小限制為 1MB
- 啟用懶加載和緩存

## 文件說明

### settings.json
包含 VSCode 和 Augment 擴展的主要配置設置。

### launch.json
Flutter 應用的調試配置，包含性能優化參數。

### tasks.json
常用的 Flutter 和 Dart 任務配置。

### extensions.json
推薦和不推薦的擴展列表。

## 使用方法

1. 重啟 VSCode 以應用新的設置
2. 如果 Augment 擴展仍然很慢，可以進一步調整以下參數：
   - 減少 `augment.indexing.batchSize` (例如改為 25)
   - 增加 `augment.indexing.throttle` (例如改為 10000)
   - 設置 `augment.analysis.realTime` 為 false

## 監控性能

可以通過以下方式監控 Augment 擴展的性能：
1. 打開 VSCode 開發者工具 (Ctrl+Shift+I)
2. 查看 Console 標籤中的 Augment 相關日誌
3. 監控 CPU 和記憶體使用情況

## 進一步優化

如果性能問題仍然存在，可以考慮：
1. 進一步減少包含的文件類型
2. 增加更多排除目錄
3. 調整記憶體設置
4. 禁用某些 Augment 功能

## 注意事項

- 這些設置可能會影響 Augment 擴展的某些功能
- 建議根據實際使用情況調整配置
- 定期檢查和更新配置以獲得最佳性能
