import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:sudoku_app/models/sudoku_board.dart';
import 'package:sudoku_app/models/sudoku_cell.dart';
import 'package:sudoku_app/models/game_record.dart';
import 'package:sudoku_app/services/sudoku_generator.dart';
import 'package:sudoku_app/services/storage_service.dart';
import 'package:sudoku_app/services/game_record_service.dart';
import 'settings_provider.dart';

// 遊戲操作類型
enum ActionType {
  setValue,
  deleteValue,
  addNote,
  removeNote,
  clearNotes,
  hint,
}

// 遊戲操作記錄
class GameAction {
  final ActionType type;
  final int row;
  final int col;
  final int? oldValue;
  final int? newValue;
  final Set<int>? oldNotes;
  final Set<int>? newNotes;
  final DateTime timestamp;

  GameAction({
    required this.type,
    required this.row,
    required this.col,
    this.oldValue,
    this.newValue,
    this.oldNotes,
    this.newNotes,
    required this.timestamp,
  });
}

class GameProvider extends ChangeNotifier {
  SudokuBoard? _currentBoard;
  int? _selectedRow;
  int? _selectedCol;
  bool _isNotesMode = false;
  bool _isGamePaused = false;
  bool _isContinuousInputEnabled = false; // 連續輸入開關，預設關閉
  bool _isGameOver = false; // 遊戲是否結束（失敗）
  bool _showLifeLostDialog = false; // 是否顯示失去生命對話框
  int? _lastSelectedNumber; // 記住上次選擇的數字
  int? _highlightedNumber; // 醒目顯示的數字

  SettingsProvider? _settingsProvider; // 設置提供者

  // 操作歷史記錄
  final List<GameAction> _actionHistory = [];
  final List<GameAction> _redoHistory = [];
  static const int _maxHistorySize = 20;

  final SudokuGenerator _generator = SudokuGenerator();
  final StorageService _storage = StorageService();
  final GameRecordService _recordService = GameRecordService();

  // 生命恢復相關
  DateTime? _lastLifeRestoreCheck;

  // 構造函數，初始化時檢查生命恢復
  GameProvider() {
    _initializeProvider();
  }

  // 設置 SettingsProvider
  void setSettingsProvider(SettingsProvider settingsProvider) {
    _settingsProvider = settingsProvider;
  }

  // 檢查是否應該設置醒目數字
  bool get _shouldHighlightNumbers => _settingsProvider?.highlightSameNumbers ?? true;

  // 安全設置醒目數字
  void _setHighlightedNumber(int? number) {
    if (_shouldHighlightNumbers) {
      _highlightedNumber = number;
    } else {
      _highlightedNumber = null;
    }
  }

  // 當醒目設置改變時更新當前醒目狀態
  void updateHighlightSettings() {
    if (!_shouldHighlightNumbers && _highlightedNumber != null) {
      // 如果醒目功能被關閉且當前有醒目數字，清除它
      _highlightedNumber = null;
      notifyListeners();
    }
  }

  // 播放錯誤回饋（音效和震動）
  void _playErrorFeedback() {
    if (_settingsProvider?.soundEnabled ?? false) {
      SystemSound.play(SystemSoundType.alert);
    }
    if (_settingsProvider?.vibrationEnabled ?? false) {
      HapticFeedback.mediumImpact();
    }
  }

  // 清除相關位置的指定數字筆記
  void _clearRelatedNotes(int number, int filledRow, int filledCol) {
    if (_currentBoard == null) return;

    // 調試輸出
    if (kDebugMode) {
      debugPrint('🔍 開始清除筆記: 數字=$number, 位置=($filledRow,$filledCol)');
    }
    int clearedCount = 0;

    // 清除同行的筆記
    for (int col = 0; col < 9; col++) {
      if (col != filledCol) {
        final cell = _currentBoard!.getCell(filledRow, col);
        if (cell.notes.contains(number)) {
          cell.notes.remove(number);
          clearedCount++;
          if (kDebugMode) {
            debugPrint('  清除同行筆記: ($filledRow,$col)');
          }
        }
      }
    }

    // 清除同列的筆記
    for (int row = 0; row < 9; row++) {
      if (row != filledRow) {
        final cell = _currentBoard!.getCell(row, filledCol);
        if (cell.notes.contains(number)) {
          cell.notes.remove(number);
          clearedCount++;
          if (kDebugMode) {
            debugPrint('  清除同列筆記: ($row,$filledCol)');
          }
        }
      }
    }

    // 清除同宮格的筆記
    final boxStartRow = (filledRow ~/ 3) * 3;
    final boxStartCol = (filledCol ~/ 3) * 3;

    for (int row = boxStartRow; row < boxStartRow + 3; row++) {
      for (int col = boxStartCol; col < boxStartCol + 3; col++) {
        if (row != filledRow || col != filledCol) {
          final cell = _currentBoard!.getCell(row, col);
          if (cell.notes.contains(number)) {
            cell.notes.remove(number);
            clearedCount++;
            if (kDebugMode) {
              debugPrint('  清除同宮格筆記: ($row,$col)');
            }
          }
        }
      }
    }

    if (kDebugMode) {
      debugPrint('✅ 筆記清除完成: 共清除 $clearedCount 個筆記');
    }
  }

  // 檢查數字是否已完成（填滿9個正確位置）
  bool isNumberCompleted(int number) {
    if (_currentBoard == null) return false;

    int count = 0;
    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        final cell = _currentBoard!.getCell(row, col);
        if (cell.value == number && _currentBoard!.isCellCorrect(row, col)) {
          count++;
        }
      }
    }
    return count == 9;
  }

  // 清除已完成數字的所有筆記
  void _clearCompletedNumberNotes(int number) {
    if (_currentBoard == null) return;

    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        final cell = _currentBoard!.getCell(row, col);
        if (cell.notes.contains(number)) {
          cell.notes.remove(number);
        }
      }
    }
  }

  Future<void> _initializeProvider() async {
    _checkLifeRestore();
    // 如果有保存的遊戲，載入它
    await loadSavedGame();
  }

  // Expose services for external access
  StorageService get storage => _storage;
  GameRecordService get recordService => _recordService;

  // Getters
  SudokuBoard? get currentBoard => _currentBoard;
  int? get selectedRow => _selectedRow;
  int? get selectedCol => _selectedCol;
  bool get isNotesMode => _isNotesMode;
  bool get isGamePaused => _isGamePaused;
  bool get hasSelectedCell => _selectedRow != null && _selectedCol != null;
  bool get isContinuousInputEnabled => _isContinuousInputEnabled;
  bool get isGameOver => _isGameOver;
  bool get showLifeLostDialog => _showLifeLostDialog;
  int? get lastSelectedNumber => _lastSelectedNumber;

  // 獲取當前難度的錯誤限制
  int get maxMistakes {
    if (_currentBoard == null) return 10;
    switch (_currentBoard!.difficulty) {
      case Difficulty.easy:
        return 10;
      case Difficulty.medium:
        return 5;
      case Difficulty.hard:
        return 3;
    }
  }

  // 獲取當前錯誤數
  int get currentMistakes => _currentBoard?.mistakes ?? 0;

  // 獲取當前生命數
  int get currentLives => _currentBoard?.lives ?? 5;

  // 檢查是否達到錯誤限制
  bool get hasReachedMistakeLimit => currentMistakes >= maxMistakes;

  // 獲取操作歷史記錄
  List<GameAction> get actionHistory => List.unmodifiable(_actionHistory);

  // 檢查是否可以撤銷
  bool get canUndo => _actionHistory.isNotEmpty && !_isGamePaused && !_isGameOver;

  // 檢查是否可以重做
  bool get canRedo => _redoHistory.isNotEmpty && !_isGamePaused && !_isGameOver;

  // 獲取提示上限
  int get hintLimit {
    if (_currentBoard == null) return 0;
    switch (_currentBoard!.difficulty) {
      case Difficulty.easy:
        return 15;
      case Difficulty.medium:
        return 9;
      case Difficulty.hard:
        return 3;
    }
  }

  // 檢查是否還能使用提示
  bool get canUseHint => _currentBoard != null && _currentBoard!.hintsUsed < hintLimit;

  // 獲取醒目顯示的數字
  int? get highlightedNumber => _highlightedNumber;
  
  SudokuCell? get selectedCell {
    if (_currentBoard != null && _selectedRow != null && _selectedCol != null) {
      return _currentBoard!.getCell(_selectedRow!, _selectedCol!);
    }
    return null;
  }

  // 計算每個數字的剩餘量
  Map<int, int> get numberCounts {
    if (_currentBoard == null) return {};

    Map<int, int> counts = {};

    // 初始化每個數字的計數為0
    for (int i = 1; i <= 9; i++) {
      counts[i] = 0;
    }

    // 計算已正確填入的數字
    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        final cell = _currentBoard!.getCell(row, col);
        if (cell.value != 0 && _currentBoard!.isCellCorrect(row, col)) {
          counts[cell.value] = counts[cell.value]! + 1;
        }
      }
    }

    // 計算剩餘量：9 - 已答對的數量
    for (int i = 1; i <= 9; i++) {
      counts[i] = 9 - counts[i]!;
    }

    return counts;
  }

  // 檢查生命恢復
  void _checkLifeRestore() {
    final now = DateTime.now();
    final today5AM = DateTime(now.year, now.month, now.day, 5, 0, 0);

    // 如果現在時間已過今天早上5點，且上次檢查不是今天
    if (now.isAfter(today5AM) &&
        (_lastLifeRestoreCheck == null ||
         _lastLifeRestoreCheck!.isBefore(today5AM))) {

      // 恢復生命到滿值
      if (_currentBoard != null && _currentBoard!.lives < 5) {
        _currentBoard!.lives = 5;
        notifyListeners();
        _saveGame();
      }

      _lastLifeRestoreCheck = now;
    }
  }

  // 充值生命（暫時直接恢復滿值）
  void rechargeLife() {
    if (_currentBoard != null) {
      _currentBoard!.lives = 5;
      _isGameOver = false;
      _showLifeLostDialog = false;
      notifyListeners();
      _saveGame();
    }
  }

  // Game actions
  Future<void> startNewGame(Difficulty difficulty) async {
    _checkLifeRestore(); // 開始新遊戲時檢查生命恢復
    _currentBoard = await _generator.generatePuzzle(difficulty);
    _currentBoard!.startTime = DateTime.now();
    _selectedRow = null;
    _selectedCol = null;
    _isNotesMode = false;
    _isGamePaused = false;
    _isGameOver = false; // 重置遊戲結束狀態
    _showLifeLostDialog = false; // 重置失去生命對話框狀態
    _lastSelectedNumber = null; // 重置上次選擇的數字
    _setHighlightedNumber(null); // 重置醒目數字
    _actionHistory.clear(); // 清除操作歷史
    _redoHistory.clear(); // 清除重做歷史
    _lastUndoMessage = null; // 清除撤銷訊息
    // 注意：不重置 _isContinuousInputEnabled，保持用戶的偏好設置
    notifyListeners();
    await _saveGame();
  }

  void selectCell(int row, int col) {
    if (_currentBoard == null || _isGamePaused) return;

    final cell = _currentBoard!.getCell(row, col);

    // 筆記模式且有已選數字：直接切換筆記
    if (_isNotesMode && _lastSelectedNumber != null) {
      // 設置選中位置以便 _toggleNote 使用
      _selectedRow = row;
      _selectedCol = col;

      // 調用切換筆記
      _toggleNote(_lastSelectedNumber!);

      // 檢查連續輸入
      if (!_isContinuousInputEnabled) {
        _lastSelectedNumber = null;
      }

      notifyListeners();
      return;
    }

    // 連續輸入模式且非筆記模式且有已選數字：優先填入數字
    if (_isContinuousInputEnabled && !_isNotesMode && _lastSelectedNumber != null) {
      // 設置選中位置以便 _tryFillNumber 使用
      _selectedRow = row;
      _selectedCol = col;
      _currentBoard!.highlightRelated(row, col);

      // 設置醒目數字
      _setHighlightedNumber(_lastSelectedNumber);

      // 嘗試填入數字
      _tryFillNumber();

      notifyListeners();
      return;
    }

    // 原有的選格子邏輯
    // 如果點擊的是已選中的格子，取消選擇
    if (_selectedRow == row && _selectedCol == col) {
      _selectedRow = null;
      _selectedCol = null;
      _setHighlightedNumber(null); // 清除醒目數字
      _currentBoard!.clearHighlights();
    } else {
      _selectedRow = row;
      _selectedCol = col;
      _currentBoard!.highlightRelated(row, col);

      // 設置醒目數字：如果選中的格子有數字，醒目顯示相同數字
      if (cell.value != 0) {
        _setHighlightedNumber(cell.value);
      } else {
        _setHighlightedNumber(null);
      }

      // 檢查是否需要填入數字
      _tryFillNumber();
    }

    notifyListeners();
  }

  void longPressCell(int row, int col) {
    if (_currentBoard == null || _isGamePaused || _isGameOver) return;

    final cell = _currentBoard!.getCell(row, col);

    // 長按格子：如果格子有數字，選中該數字鍵、更新醒目、並選中格子
    if (cell.value != 0) {
      _lastSelectedNumber = cell.value;
      _setHighlightedNumber(cell.value); // 更新醒目數字

      // 更新選取格子
      _selectedRow = row;
      _selectedCol = col;
      _currentBoard!.highlightRelated(row, col);

      notifyListeners();
    }
    // 如果格子是空的，執行正常的選中格子邏輯
    else {
      selectCell(row, col);
    }
  }

  void clearSelection() {
    _selectedRow = null;
    _selectedCol = null;
    _currentBoard?.clearHighlights();
    notifyListeners();
  }

  void inputNumber(int number) {
    if (_currentBoard == null || _isGamePaused || _isGameOver) return;

    // 新邏輯：如果點擊已選中的數字鍵，取消選中
    if (_lastSelectedNumber == number) {
      // 取消選中
      _lastSelectedNumber = null;
      _setHighlightedNumber(null); // 清除醒目數字
      // 不調用 _tryFillNumber()，不填入數字，不切換筆記
    } else {
      // 點擊未選中的數字鍵：選中並嘗試操作
      _lastSelectedNumber = number;
      _setHighlightedNumber(number); // 設置醒目數字
      _tryFillNumber(); // 檢查是否需要填入數字或切換筆記
    }

    notifyListeners();
  }

  void longPressNumber(int number) {
    if (_currentBoard == null || _isGamePaused || _isGameOver) return;

    // 長按數字鍵：如果該數字鍵已選中則取消選中，否則選中
    if (_lastSelectedNumber == number) {
      // 取消選中
      _lastSelectedNumber = null;
      _setHighlightedNumber(null); // 同時清除醒目
    } else {
      // 選中該數字鍵
      _lastSelectedNumber = number;
      _setHighlightedNumber(number); // 同時設置醒目
    }

    notifyListeners();
  }

  void _tryFillNumber() {
    // 檢查是否有選中格子和選中數字鍵
    if (_currentBoard == null || _selectedRow == null || _selectedCol == null || _lastSelectedNumber == null) return;

    final cell = _currentBoard!.getCell(_selectedRow!, _selectedCol!);

    // 固定格子不能填入
    if (cell.isFixed) return;

    // 如果格子有錯誤且要填入相同數字，不允許
    if (_currentBoard!.isCellError(_selectedRow!, _selectedCol!) &&
        cell.value == _lastSelectedNumber) {
      return;
    }

    if (_isNotesMode) {
      // 筆記模式：允許在空格子或有錯誤的格子上操作
      if (cell.value != 0 && !_currentBoard!.isCellError(_selectedRow!, _selectedCol!)) {
        return; // 不能在正確填入的數字上添加筆記
      }
      _toggleNote(_lastSelectedNumber!);
    } else {
      // 填入模式：如果格子不是空的且沒有錯誤，不允許填入
      if (cell.value != 0 && !_currentBoard!.isCellError(_selectedRow!, _selectedCol!)) {
        return;
      }
      _fillNumber(_lastSelectedNumber!);
    }

    // 非連續輸入模式：操作後清除數字鍵選取
    if (!_isContinuousInputEnabled) {
      _lastSelectedNumber = null;
    }
  }

  void _fillNumber(int value) {
    final cell = _currentBoard!.getCell(_selectedRow!, _selectedCol!);
    final oldValue = cell.value;
    final oldNotes = Set<int>.from(cell.notes);

    // 記錄操作
    _recordAction(
      value == 0 ? ActionType.deleteValue : ActionType.setValue,
      _selectedRow!,
      _selectedCol!,
      oldValue,
      value,
      oldNotes: oldNotes,
      newNotes: Set<int>.from(oldNotes), // 保留筆記數據
    );

    // 填入數字
    _currentBoard!.setCellValue(_selectedRow!, _selectedCol!, value);

    if (value != 0) {
      // 填入數字時不清除筆記，保留在數據中
      // cell.notes.clear(); // 註釋掉，保留筆記數據

      // 填入數字時醒目該數字
      _setHighlightedNumber(value);

      // 檢查是否填錯（與正確答案不符）
      if (!_currentBoard!.isCellCorrect(_selectedRow!, _selectedCol!)) {
        _currentBoard!.mistakes++;
        
        if (kDebugMode) {
          debugPrint('❌ 填錯數字: $value 在位置 ($_selectedRow,$_selectedCol)');
        }

        // 播放錯誤回饋
        _playErrorFeedback();

        // 檢查是否達到錯誤限制
        if (hasReachedMistakeLimit) {
          _handleMistakeLimit();
        }
      } else {
        if (kDebugMode) {
          debugPrint('✅ 填對數字: $value 在位置 ($_selectedRow,$_selectedCol)');
        }
        // 填對時清除相關位置的該數字筆記
        _clearRelatedNotes(value, _selectedRow!, _selectedCol!);

        // 檢查該數字是否已完成，如果完成則清除所有該數字的筆記
        if (isNumberCompleted(value)) {
          _clearCompletedNumberNotes(value);
        }

        _checkGameCompletion();
      }
    } else {
      // 清除數字時清除醒目
      _setHighlightedNumber(null);
    }

    notifyListeners();
    _saveGame();
  }

  void _toggleNote(int number) {
    final cell = _currentBoard!.getCell(_selectedRow!, _selectedCol!);

    // 如果格子有值且沒有錯誤，不能添加筆記
    if (cell.value != 0 && !_currentBoard!.isCellError(_selectedRow!, _selectedCol!)) {
      return;
    }

    // 如果格子有錯誤，清除值
    if (_currentBoard!.isCellError(_selectedRow!, _selectedCol!)) {
      _currentBoard!.setCellValue(_selectedRow!, _selectedCol!, 0);
    }

    final oldNotes = Set<int>.from(cell.notes);

    if (cell.notes.contains(number)) {
      // 記錄移除筆記操作
      _recordAction(
        ActionType.removeNote,
        _selectedRow!,
        _selectedCol!,
        null,
        number,
        oldNotes: oldNotes,
        newNotes: Set<int>.from(oldNotes)..remove(number),
      );
      cell.notes.remove(number);
    } else {
      // 記錄添加筆記操作
      _recordAction(
        ActionType.addNote,
        _selectedRow!,
        _selectedCol!,
        null,
        number,
        oldNotes: oldNotes,
        newNotes: Set<int>.from(oldNotes)..add(number),
      );
      cell.notes.add(number);
    }
    notifyListeners();
    _saveGame();
  }

  void deleteCell() {
    if (_currentBoard == null || !hasSelectedCell || _isGamePaused) return;

    final cell = _currentBoard!.getCell(_selectedRow!, _selectedCol!);
    if (cell.isFixed) return;

    if (_isNotesMode) {
      if (cell.notes.isNotEmpty) {
        final oldNotes = Set<int>.from(cell.notes);
        _recordAction(
          ActionType.clearNotes,
          _selectedRow!,
          _selectedCol!,
          null,
          null,
          oldNotes: oldNotes,
          newNotes: <int>{},
        );
        cell.notes.clear();
      }
    } else {
      if (cell.value != 0) {
        // 使用 eraseCell 邏輯而不是 _fillNumber，以保留筆記
        final oldValue = cell.value;
        final oldNotes = Set<int>.from(cell.notes);
        
        _recordAction(
          ActionType.deleteValue,
          _selectedRow!,
          _selectedCol!,
          oldValue,
          0,
          oldNotes: oldNotes,
          newNotes: oldNotes, // 保留筆記
        );
        
        _currentBoard!.setCellValue(_selectedRow!, _selectedCol!, 0);
        // 筆記保持不變
        
        notifyListeners();
        _saveGame();
        return;
      }
    }

    notifyListeners();
    _saveGame();
  }

  void eraseCell() {
    if (_currentBoard == null || !hasSelectedCell || _isGamePaused || _isGameOver) return;

    final cell = _currentBoard!.getCell(_selectedRow!, _selectedCol!);

    // 固定格子不能擦除
    if (cell.isFixed) return;

    final oldValue = cell.value;
    final oldNotes = Set<int>.from(cell.notes);
    final isError = _currentBoard!.isCellError(_selectedRow!, _selectedCol!);

    // 擦除邏輯：
    // 1. 如果格子有錯誤值，清除值但保留筆記
    // 2. 如果格子有正確值，不能擦除
    // 3. 如果格子沒有值但有筆記，清除筆記

    bool hasValue = cell.value != 0;
    bool hasNotes = cell.notes.isNotEmpty;

    if (hasValue) {
      // 有值的情況
      if (isError) {
        // 填錯的格子：清除值但保留筆記
        _recordAction(
          ActionType.deleteValue,
          _selectedRow!,
          _selectedCol!,
          oldValue,
          0,
          oldNotes: oldNotes,
          newNotes: oldNotes, // 保留筆記
        );

        _currentBoard!.setCellValue(_selectedRow!, _selectedCol!, 0);
        // 筆記保持不變，清除錯誤值後筆記會重新顯示
      } else {
        // 正確的值不能擦除
        return;
      }
    } else if (hasNotes) {
      // 沒有值但有筆記：清除筆記
      _recordAction(
        ActionType.clearNotes,
        _selectedRow!,
        _selectedCol!,
        null,
        null,
        oldNotes: oldNotes,
        newNotes: <int>{},
      );

      cell.notes.clear();
    } else {
      // 空格子，無法擦除
      return;
    }

    // 清除醒目
    _setHighlightedNumber(null);

    notifyListeners();
    _saveGame();
  }

  void toggleNotesMode() {
    _isNotesMode = !_isNotesMode;
    notifyListeners();
  }

  void toggleContinuousInput() {
    _isContinuousInputEnabled = !_isContinuousInputEnabled;
    // 如果關閉連續輸入，清除上次選擇的數字
    if (!_isContinuousInputEnabled) {
      _lastSelectedNumber = null;
    }
    notifyListeners();
  }

  // 自動完成功能：填入直行、橫列、宮格內只剩1格的空格
  void autoComplete() {
    if (_currentBoard == null || _isGamePaused) return;

    int completedCells = 0;

    // 檢查所有行
    for (int row = 0; row < SudokuBoard.size; row++) {
      completedCells += _autoCompleteRow(row);
    }

    // 檢查所有列
    for (int col = 0; col < SudokuBoard.size; col++) {
      completedCells += _autoCompleteColumn(col);
    }

    // 檢查所有宮格
    for (int boxRow = 0; boxRow < 3; boxRow++) {
      for (int boxCol = 0; boxCol < 3; boxCol++) {
        completedCells += _autoCompleteBox(boxRow, boxCol);
      }
    }

    if (completedCells > 0) {
      // 清除相關筆記並檢查遊戲完成
      _updateAfterAutoComplete();
      notifyListeners();
      _saveGame();
    }
  }

  // 自動完成指定行
  int _autoCompleteRow(int row) {
    List<int> emptyCells = [];
    Set<int> usedNumbers = {};

    // 找出空格和已使用的數字
    for (int col = 0; col < SudokuBoard.size; col++) {
      final cell = _currentBoard!.getCell(row, col);
      if (cell.value == 0) {
        emptyCells.add(col);
      } else {
        usedNumbers.add(cell.value);
      }
    }

    // 如果只剩一個空格，填入缺少的數字
    if (emptyCells.length == 1) {
      final missingNumbers = <int>{1, 2, 3, 4, 5, 6, 7, 8, 9}.difference(usedNumbers);
      if (missingNumbers.length == 1) {
        final col = emptyCells.first;
        final value = missingNumbers.first;
        _currentBoard!.setCellValue(row, col, value);
        return 1;
      }
    }

    return 0;
  }

  // 自動完成指定列
  int _autoCompleteColumn(int col) {
    List<int> emptyCells = [];
    Set<int> usedNumbers = {};

    // 找出空格和已使用的數字
    for (int row = 0; row < SudokuBoard.size; row++) {
      final cell = _currentBoard!.getCell(row, col);
      if (cell.value == 0) {
        emptyCells.add(row);
      } else {
        usedNumbers.add(cell.value);
      }
    }

    // 如果只剩一個空格，填入缺少的數字
    if (emptyCells.length == 1) {
      final missingNumbers = <int>{1, 2, 3, 4, 5, 6, 7, 8, 9}.difference(usedNumbers);
      if (missingNumbers.length == 1) {
        final row = emptyCells.first;
        final value = missingNumbers.first;
        _currentBoard!.setCellValue(row, col, value);
        return 1;
      }
    }

    return 0;
  }

  // 自動完成指定宮格
  int _autoCompleteBox(int boxRow, int boxCol) {
    List<List<int>> emptyCells = [];
    Set<int> usedNumbers = {};

    // 找出空格和已使用的數字
    for (int row = boxRow * 3; row < boxRow * 3 + 3; row++) {
      for (int col = boxCol * 3; col < boxCol * 3 + 3; col++) {
        final cell = _currentBoard!.getCell(row, col);
        if (cell.value == 0) {
          emptyCells.add([row, col]);
        } else {
          usedNumbers.add(cell.value);
        }
      }
    }

    // 如果只剩一個空格，填入缺少的數字
    if (emptyCells.length == 1) {
      final missingNumbers = <int>{1, 2, 3, 4, 5, 6, 7, 8, 9}.difference(usedNumbers);
      if (missingNumbers.length == 1) {
        final row = emptyCells.first[0];
        final col = emptyCells.first[1];
        final value = missingNumbers.first;
        _currentBoard!.setCellValue(row, col, value);
        return 1;
      }
    }

    return 0;
  }

  // 自動完成後的更新處理
  void _updateAfterAutoComplete() {
    // 清除所有已完成數字的筆記
    for (int number = 1; number <= 9; number++) {
      if (isNumberCompleted(number)) {
        _clearCompletedNumberNotes(number);
      }
    }

    // 檢查遊戲是否完成
    _checkGameCompletion();
  }

  void getHint() {
    if (_currentBoard == null || !hasSelectedCell || _isGamePaused) return;
    if (!canUseHint) return; // 檢查提示上限

    final cell = _currentBoard!.getCell(_selectedRow!, _selectedCol!);
    if (cell.isFixed || cell.value != 0) return;

    // Find the correct value for this cell
    final solution = _generator.solvePuzzle(_currentBoard!);
    if (solution != null) {
      final correctValue = solution.getCell(_selectedRow!, _selectedCol!).value;

      // 記錄提示操作
      _recordAction(
        ActionType.hint,
        _selectedRow!,
        _selectedCol!,
        0,
        correctValue,
      );

      _currentBoard!.setCellValue(_selectedRow!, _selectedCol!, correctValue);
      _currentBoard!.hintsUsed++;

      // 清除相關位置的該數字筆記
      _clearRelatedNotes(correctValue, _selectedRow!, _selectedCol!);

      // 檢查該數字是否已完成，如果完成則清除所有該數字的筆記
      if (isNumberCompleted(correctValue)) {
        _clearCompletedNumberNotes(correctValue);
      }

      _checkGameCompletion();
      notifyListeners();
      _saveGame();
    }
  }

  void pauseGame() {
    if (_currentBoard == null) return;
    
    if (_isGamePaused) {
      // 恢復遊戲
      _currentBoard!.resumeTimer();
      _isGamePaused = false;
    } else {
      // 暫停遊戲
      _currentBoard!.pauseTimer();
      _isGamePaused = true;
    }
    
    notifyListeners();
    _saveGame();
  }

  // 強制暫停遊戲（用於返回首頁）
  Future<void> forcePauseGame() async {
    if (_currentBoard == null) return;
    if (!_isGamePaused) {
      _currentBoard!.pauseTimer(); // 暫停計時
      _isGamePaused = true;
      // 先保存再通知，減少重建次數
      await _saveGame(); // 保存遊戲狀態
      notifyListeners();
    }
  }

  void _checkGameCompletion() {
    if (_currentBoard == null) return;

    if (_currentBoard!.isBoardComplete()) {
      _currentBoard!.isCompleted = true;

      // 使用新的計時機制獲取遊戲時間
      _currentBoard!.elapsedTime = _currentBoard!.getCurrentGameTime();

      // 保存遊戲記錄
      _saveGameRecord();

      notifyListeners();
    }
  }

  void _handleMistakeLimit() {
    // 達到錯誤限制時扣除生命
    _currentBoard!.lives--;
    _currentBoard!.mistakes = 0; // 重置錯誤計數

    if (_currentBoard!.lives <= 0) {
      // 生命耗盡，遊戲結束
      _gameOver();
    } else {
      // 還有生命，暫停遊戲並詢問玩家
      _isGamePaused = true;
      _showLifeLostDialog = true;
      notifyListeners();
    }
  }

  void _gameOver() {
    if (_currentBoard == null) return;

    // 暫停計時
    _currentBoard!.pauseTimer();
    _isGamePaused = true;

    // 使用新的計時機制獲取遊戲時間
    _currentBoard!.elapsedTime = _currentBoard!.getCurrentGameTime();

    // 遊戲失敗時也保存記錄
    _saveGameRecord(isCompleted: false);
    _isGameOver = true; // 標記遊戲結束
    notifyListeners();
  }

  // 玩家選擇繼續遊戲
  void continueGame() {
    _showLifeLostDialog = false;
    if (_currentBoard != null) {
      _currentBoard!.resumeTimer(); // 恢復計時
    }
    _isGamePaused = false;
    notifyListeners();
    _saveGame();
  }

  // 玩家選擇放棄遊戲
  void giveUpGame() {
    _showLifeLostDialog = false;
    _gameOver();
  }

  Future<void> _saveGameRecord({bool? isCompleted}) async {
    if (_currentBoard == null) return;

    final completed = isCompleted ?? _currentBoard!.isCompleted;

    final record = GameRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      difficulty: _currentBoard!.difficulty,
      startTime: _currentBoard!.startTime!,
      endTime: DateTime.now(),
      playTime: _currentBoard!.elapsedTime!,
      isCompleted: completed,
      hintsUsed: _currentBoard!.hintsUsed,
      mistakes: _currentBoard!.mistakes,
    );

    await _recordService.saveGameRecord(record);
  }

  Future<void> _saveGame() async {
    if (_currentBoard != null && (_settingsProvider?.autoSave ?? true)) {
      await _storage.saveGame(_currentBoard!);
    }
  }

  Future<void> loadSavedGame() async {
    final savedBoard = await _storage.loadGame();
    if (savedBoard != null) {
      _currentBoard = savedBoard;
      _selectedRow = null;
      _selectedCol = null;
      _isNotesMode = false;
      _isGamePaused = false;
      _isGameOver = false; // 重置遊戲結束狀態
      _showLifeLostDialog = false; // 重置失去生命對話框狀態
      _lastSelectedNumber = null; // 重置上次選擇的數字
      _setHighlightedNumber(null); // 重置醒目數字
      _actionHistory.clear(); // 載入遊戲時清除歷史記錄
      _redoHistory.clear(); // 清除重做歷史
      _lastUndoMessage = null; // 清除撤銷訊息
      
      // 恢復計時（如果遊戲之前被暫停）
      if (_currentBoard!.pauseStartTime != null) {
        _currentBoard!.resumeTimer();
      }
      
      notifyListeners();
    }
  }





  void resetGame() {
    _currentBoard = null;
    _selectedRow = null;
    _selectedCol = null;
    _isNotesMode = false;
    _isGamePaused = false;
    _isGameOver = false; // 重置遊戲結束狀態
    _showLifeLostDialog = false; // 重置失去生命對話框狀態
    _lastSelectedNumber = null; // 重置上次選擇的數字
    _setHighlightedNumber(null); // 重置醒目數字
    _actionHistory.clear(); // 清除操作歷史
    _redoHistory.clear(); // 清除重做歷史
    _lastUndoMessage = null; // 清除撤銷訊息
    notifyListeners();
  }

  // 記錄操作
  void _recordAction(
    ActionType type,
    int row,
    int col,
    int? oldValue,
    int? newValue, {
    Set<int>? oldNotes,
    Set<int>? newNotes,
  }) {
    final action = GameAction(
      type: type,
      row: row,
      col: col,
      oldValue: oldValue,
      newValue: newValue,
      oldNotes: oldNotes != null ? Set<int>.from(oldNotes) : null,
      newNotes: newNotes != null ? Set<int>.from(newNotes) : null,
      timestamp: DateTime.now(),
    );

    _actionHistory.add(action);

    // 新操作時清除重做歷史
    _redoHistory.clear();

    // 限制歷史記錄數量
    if (_actionHistory.length > _maxHistorySize) {
      _actionHistory.removeAt(0);
    }
  }

  // 撤銷操作結果
  String? _lastUndoMessage;
  String? get lastUndoMessage => _lastUndoMessage;

  // 撤銷操作
  void undo() {
    _lastUndoMessage = null; // 清除上次的訊息
    if (!canUndo) return;

    final action = _actionHistory.removeLast();
    final cell = _currentBoard!.getCell(action.row, action.col);

    // 如果是提示操作，不能撤銷
    if (action.type == ActionType.hint) {
      // 重新加入歷史記錄
      _actionHistory.add(action);
      _lastUndoMessage = '提示不能撤銷';
      notifyListeners();
      return;
    }

    // 檢查是否是填對的操作
    if ((action.type == ActionType.setValue) &&
        action.newValue != null &&
        action.newValue! > 0 &&
        _currentBoard!.isCellCorrect(action.row, action.col)) {
      // 填對了，不撤銷，只移除歷史記錄
      // 不加入重做歷史，因為這個操作被"消費"了
      _lastUndoMessage = '剛剛填對了';
      notifyListeners();
      return;
    }

    // 將撤銷的操作加入重做歷史
    _redoHistory.add(action);

    // 恢復操作
    switch (action.type) {
      case ActionType.setValue:
      case ActionType.deleteValue:
        // 恢復數值
        _currentBoard!.setCellValue(action.row, action.col, action.oldValue ?? 0);
        // 恢復筆記
        if (action.oldNotes != null) {
          cell.notes.clear();
          cell.notes.addAll(action.oldNotes!);
        }
        // 錯誤狀態現在由 solution 自動計算，不需要恢復
        break;

      case ActionType.addNote:
        // 移除筆記
        if (action.newValue != null) {
          cell.notes.remove(action.newValue!);
        }
        break;

      case ActionType.removeNote:
        // 添加筆記
        if (action.newValue != null) {
          cell.notes.add(action.newValue!);
        }
        break;

      case ActionType.clearNotes:
        // 恢復筆記
        if (action.oldNotes != null) {
          cell.notes.clear();
          cell.notes.addAll(action.oldNotes!);
        }
        break;

      case ActionType.hint:
        // 提示操作不應該到這裡
        break;
    }

    notifyListeners();
    _saveGame();
  }

  // 重做操作
  void redo() {
    if (!canRedo) return;

    final action = _redoHistory.removeLast();
    final cell = _currentBoard!.getCell(action.row, action.col);

    // 將重做的操作重新加入撤銷歷史
    _actionHistory.add(action);

    // 執行操作
    switch (action.type) {
      case ActionType.setValue:
      case ActionType.deleteValue:
        // 設置數值
        _currentBoard!.setCellValue(action.row, action.col, action.newValue ?? 0);
        // 設置筆記
        if (action.newNotes != null) {
          cell.notes.clear();
          cell.notes.addAll(action.newNotes!);
        }
        // 如果是填入正確數字，清除相關筆記
        if (action.newValue != null && action.newValue! > 0 &&
            _currentBoard!.isCellCorrect(action.row, action.col)) {
          _clearRelatedNotes(action.newValue!, action.row, action.col);

          // 檢查該數字是否已完成
          if (isNumberCompleted(action.newValue!)) {
            _clearCompletedNumberNotes(action.newValue!);
          }
        }
        break;

      case ActionType.addNote:
        // 添加筆記
        if (action.newValue != null) {
          cell.notes.add(action.newValue!);
        }
        break;

      case ActionType.removeNote:
        // 移除筆記
        if (action.newValue != null) {
          cell.notes.remove(action.newValue!);
        }
        break;

      case ActionType.clearNotes:
        // 清除筆記
        cell.notes.clear();
        break;

      case ActionType.hint:
        // 重做提示操作
        _currentBoard!.setCellValue(action.row, action.col, action.newValue ?? 0);
        _currentBoard!.hintsUsed++;
        // 清除相關位置的該數字筆記
        if (action.newValue != null) {
          _clearRelatedNotes(action.newValue!, action.row, action.col);

          // 檢查該數字是否已完成
          if (isNumberCompleted(action.newValue!)) {
            _clearCompletedNumberNotes(action.newValue!);
          }
        }
        break;
    }

    notifyListeners();
    _saveGame();
  }
}
