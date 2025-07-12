# 數獨遊戲 (Sudoku App)

一個使用 Flutter 開發的精美數獨手機應用程序，支持 Android 和 iOS 平台。

## 功能特色

### ✅ 已實現功能

- **數獨盤面 UI**: 精美的 9x9 網格界面，支持觸摸交互
- **數獨邏輯引擎**: 完整的數獨生成、驗證和求解算法
- **遊戲狀態管理**: 使用 Provider 進行狀態管理
- **基礎互動功能**:
  - 填入數字 (1-9)
  - 刪除數字
  - 筆記模式 (在格子中添加小數字提示)
  - 提示功能 (獲取正確答案)
  - 撤銷/重做功能 (支持操作歷史管理)
- **儲存/讀取功能**: 自動保存遊戲進度
- **UI 美化**: 
  - 現代化的 Material Design 3 設計
  - 流暢的動畫效果
  - 深色/淺色主題支持
  - 完成遊戲慶祝動畫

### 🎮 遊戲難度

- **簡單**: 46 個預填數字 (移除 35 個)
- **中等**: 36 個預填數字 (移除 45 個)  
- **困難**: 26 個預填數字 (移除 55 個)

### 🎨 UI 特色

- 響應式設計，適配不同屏幕尺寸
- 平滑的動畫過渡效果
- 直觀的用戶界面
- 高亮顯示相關行、列和 3x3 宮格
- **新功能 v2.8.0**: 選中數字鍵時，筆記中相同數字變為藍色高亮
- 錯誤檢測和視覺反饋

## 🎮 遊戲流程圖

### 整體遊戲流程

```diagram
flowchart TD
    A[啟動應用] --> B[主頁面]
    B --> C{選擇操作}

    C -->|新遊戲| D[選擇難度]
    C -->|繼續遊戲| E[載入保存的遊戲]
    C -->|遊戲記錄| F[查看歷史記錄]

    D --> G[生成數獨謎題]
    E --> H[遊戲畫面]
    G --> H

    H --> I{遊戲操作}

    I -->|選擇格子| J[格子選擇邏輯]
    I -->|點擊數字鍵| K[數字輸入邏輯]
    I -->|切換筆記模式| L[筆記模式切換]
    I -->|使用提示| M[提示功能]
    I -->|撤銷操作| N[撤銷邏輯]
    I -->|重做操作| NN[重做邏輯]
    I -->|擦除功能| O[擦除邏輯]
    I -->|暫停遊戲| P[暫停畫面]

    J --> Q[更新UI]
    K --> R{填入模式 or 筆記模式}
    L --> Q
    M --> S[顯示正確答案]
    N --> T[恢復上一步]
    O --> U[清除錯誤/筆記]
    P --> V[隱藏盤面]

    R -->|填入模式| W[填入數字]
    R -->|筆記模式| X[切換筆記]

    W --> Y{檢查遊戲狀態}
    X --> Q
    S --> Q
    T --> Q
    NN --> TT[重新執行操作]
    TT --> Q
    U --> Q
    V --> H

    Y -->|遊戲完成| Z[顯示完成對話框]
    Y -->|遊戲失敗| AA[顯示失敗對話框]
    Y -->|繼續遊戲| Q

    Z --> BB[保存記錄]
    AA --> CC[重新開始選項]

    BB --> B
    CC --> B
    Q --> H

    style A fill:#e1f5fe
    style H fill:#f3e5f5
    style Y fill:#fff3e0
    style Z fill:#e8f5e8
    style AA fill:#ffebee
```

### 數字輸入詳細流程

```diagram
flowchart TD
    A[用戶點擊數字鍵] --> B[inputNumber]
    B --> C[設置_lastSelectedNumber]
    B --> D[設置醒目數字]
    B --> E[調用_tryFillNumber]

    E --> F{hasSelectedCell && _lastSelectedNumber != null}
    F -->|No| G[return 結束]
    F -->|Yes| H{cell.isFixed}

    H -->|Yes 固定格子| G
    H -->|No| I{_isNotesMode}

    I -->|Yes 筆記模式| J[筆記模式邏輯]
    I -->|No 填入模式| K[填入模式邏輯]

    J --> L{cell.value != 0 && !isCellError}
    L -->|Yes| G
    L -->|No| M[_toggleNote]

    K --> N{cell.value != 0 && !isCellError}
    N -->|Yes| G
    N -->|No| O[_fillNumber]

    M --> P[切換筆記數字]
    O --> Q[填入數字到格子]

    P --> R{連續輸入模式}
    Q --> S{檢查答案正確性}

    S -->|錯誤| T[增加錯誤計數]
    S -->|正確| U[檢查遊戲完成]

    T --> V{達到錯誤限制}
    V -->|Yes| W[遊戲失敗]
    V -->|No| R

    U --> X{遊戲完成}
    X -->|Yes| Y[遊戲勝利]
    X -->|No| R

    R -->|非連續輸入| Z[清除數字鍵選擇]
    R -->|連續輸入| AA[保持數字鍵選擇]

    Z --> BB[notifyListeners]
    AA --> BB
    W --> BB
    Y --> BB

    BB --> CC[結束]

    style A fill:#e1f5fe
    style M fill:#fff3e0
    style O fill:#fff3e0
    style W fill:#ffebee
    style Y fill:#e8f5e8
```

### 格子選擇詳細流程

```diagram
flowchart TD
    A[用戶點擊格子] --> B[selectCell]

    B --> C{_isNotesMode && _lastSelectedNumber != null}
    C -->|Yes| D[筆記模式直接切換]
    C -->|No| E[正常選格子邏輯]

    D --> F[設置臨時選中位置]
    D --> G[調用_toggleNote]
    D --> H{連續輸入模式}
    H -->|No| I[清除數字鍵選擇]
    H -->|Yes| J[保持數字鍵選擇]
    I --> K[notifyListeners]
    J --> K

    E --> L{點擊已選中格子}
    L -->|Yes| M[取消選擇]
    L -->|No| N[選中新格子]

    M --> O[清空選中位置]
    M --> P[清空醒目數字]
    M --> Q[清除高亮]

    N --> R[設置新選中位置]
    N --> S[高亮相關格子]
    N --> T{格子有數字}
    T -->|Yes| U[設置醒目數字]
    T -->|No| V[清空醒目數字]

    U --> W[調用_tryFillNumber]
    V --> W
    Q --> K
    W --> K

    K --> X[結束]

    style A fill:#e1f5fe
    style D fill:#ffeb3b
    style M fill:#ffebee
    style N fill:#e8f5e8
```

## 技術架構

### 開發環境
- **語言**: Dart
- **框架**: Flutter
- **版本控制**: Git
- **開發工具**: VS Code + Flutter plugin

### 項目結構
```
lib/
├── main.dart                 # 應用入口
├── models/                   # 數據模型
│   ├── sudoku_board.dart    # 數獨盤面模型
│   └── sudoku_cell.dart     # 數獨單元格模型
├── providers/               # 狀態管理
│   └── game_provider.dart   # 遊戲狀態提供者
├── screens/                 # 頁面
│   ├── home_screen.dart     # 主頁面
│   └── game_screen.dart     # 遊戲頁面
├── services/                # 服務層
│   ├── sudoku_generator.dart # 數獨生成器
│   └── storage_service.dart  # 存儲服務
├── utils/                   # 工具類
│   └── theme.dart           # 主題配置
└── widgets/                 # UI 組件
    ├── sudoku_board_widget.dart    # 數獨盤面組件
    ├── number_input_widget.dart    # 數字輸入組件
    ├── game_controls_widget.dart   # 遊戲控制組件
    ├── game_info_widget.dart       # 遊戲信息組件
    └── completion_dialog.dart      # 完成對話框
```

### 核心算法

1. **數獨生成算法**:
   - 使用回溯算法生成完整的數獨解
   - 根據難度級別移除相應數量的數字
   - 確保生成的謎題有唯一解

2. **數獨驗證算法**:
   - 檢查行、列、3x3 宮格的數字唯一性
   - 實時驗證用戶輸入的有效性

3. **數獨求解算法**:
   - 使用回溯算法求解數獨謎題
   - 用於提示功能和驗證謎題的可解性

### 依賴包

```yaml
dependencies:
  flutter: sdk
  provider: ^6.1.1          # 狀態管理
  shared_preferences: ^2.2.2 # 本地存儲
  sqflite: ^2.3.0           # SQLite 數據庫
  cupertino_icons: ^1.0.2   # iOS 風格圖標
```

## 安裝和運行

### 前置要求
- Flutter SDK (>=3.10.0)
- Dart SDK (>=3.0.0)
- Android Studio / VS Code
- Android SDK / Xcode (用於設備調試)

### 運行步驟

1. 克隆項目
```bash
git clone <repository-url>
cd sudoku_app
```

2. 安裝依賴
```bash
flutter pub get
```

3. 運行應用
```bash
flutter run
```

### 構建發布版本

```bash
# Android APK
flutter build apk --release

# iOS IPA (需要 macOS 和 Xcode)
flutter build ios --release
```

## 未來計劃

- [ ] 遊戲統計功能
- [ ] 更多主題選項
- [ ] 在線排行榜
- [ ] 每日挑戰
- [ ] 多語言支持

## 貢獻

不歡迎提交 Issue 和 Pull Request 來改進這個項目！XD
您的提交我有空才會改

## 許可證

MIT License
