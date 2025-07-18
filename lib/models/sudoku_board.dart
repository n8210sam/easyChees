import 'sudoku_cell.dart';

enum Difficulty { easy, medium, hard }

class SudokuBoard {
  static const int size = 9;
  static const int boxSize = 3;

  List<List<SudokuCell>> grid;
  List<List<int>> solution; // 完整正確答案
  Difficulty difficulty;
  DateTime? startTime;
  Duration? elapsedTime;
  DateTime? pauseStartTime; // 暫停開始時間
  Duration accumulatedTime; // 累積的遊戲時間
  int hintsUsed;
  int mistakes;
  int lives;
  bool isCompleted;

  SudokuBoard({
    List<List<SudokuCell>>? grid,
    List<List<int>>? solution,
    this.difficulty = Difficulty.easy,
    this.startTime,
    this.elapsedTime,
    this.pauseStartTime,
    Duration? accumulatedTime,
    this.hintsUsed = 0,
    this.mistakes = 0,
    this.lives = 5,
    this.isCompleted = false,
  }) : grid = grid ?? _createEmptyGrid(),
       solution = solution ?? _createEmptySolution(),
       accumulatedTime = accumulatedTime ?? Duration.zero;

  static List<List<SudokuCell>> _createEmptyGrid() {
    return List.generate(
      size,
      (row) => List.generate(
        size,
        (col) => SudokuCell(),
      ),
    );
  }

  static List<List<int>> _createEmptySolution() {
    return List.generate(
      size,
      (row) => List.generate(size, (col) => 0),
    );
  }

  SudokuCell getCell(int row, int col) {
    return grid[row][col];
  }

  void setCell(int row, int col, SudokuCell cell) {
    grid[row][col] = cell;
  }

  void setCellValue(int row, int col, int value) {
    if (!grid[row][col].isFixed) {
      grid[row][col].value = value;
    }
  }

  // 檢查格子是否填入正確答案
  bool isCellCorrect(int row, int col) {
    final cell = grid[row][col];
    if (cell.value == 0) return true; // 空格子不算錯誤
    return cell.value == solution[row][col];
  }

  // 檢查格子是否有錯誤
  bool isCellError(int row, int col) {
    final cell = grid[row][col];
    if (cell.value == 0 || cell.isFixed) return false; // 空格子和固定格子不算錯誤
    return cell.value != solution[row][col];
  }

  bool isValidMove(int row, int col, int value) {
    if (value == 0) return true;
    
    // Check row
    for (int c = 0; c < size; c++) {
      if (c != col && grid[row][c].value == value) {
        return false;
      }
    }
    
    // Check column
    for (int r = 0; r < size; r++) {
      if (r != row && grid[r][col].value == value) {
        return false;
      }
    }
    
    // Check 3x3 box
    int boxRow = (row ~/ boxSize) * boxSize;
    int boxCol = (col ~/ boxSize) * boxSize;
    
    for (int r = boxRow; r < boxRow + boxSize; r++) {
      for (int c = boxCol; c < boxCol + boxSize; c++) {
        if ((r != row || c != col) && grid[r][c].value == value) {
          return false;
        }
      }
    }
    
    return true;
  }

  bool isBoardComplete() {
    for (int row = 0; row < size; row++) {
      for (int col = 0; col < size; col++) {
        if (grid[row][col].isEmpty) {
          return false;
        }
      }
    }
    return true;
  }

  void clearHighlights() {
    for (int row = 0; row < size; row++) {
      for (int col = 0; col < size; col++) {
        grid[row][col] = grid[row][col].copyWith(isHighlighted: false);
      }
    }
  }

  void highlightRelated(int selectedRow, int selectedCol) {
    clearHighlights();
    
    for (int row = 0; row < size; row++) {
      for (int col = 0; col < size; col++) {
        bool shouldHighlight = false;
        
        // Same row or column
        if (row == selectedRow || col == selectedCol) {
          shouldHighlight = true;
        }
        
        // Same 3x3 box
        int boxRow = (selectedRow ~/ boxSize) * boxSize;
        int boxCol = (selectedCol ~/ boxSize) * boxSize;
        if (row >= boxRow && row < boxRow + boxSize &&
            col >= boxCol && col < boxCol + boxSize) {
          shouldHighlight = true;
        }
        
        if (shouldHighlight) {
          grid[row][col] = grid[row][col].copyWith(isHighlighted: true);
        }
      }
    }
  }

  // 計算當前的遊戲時間（包含累積時間和當前會話時間）
  Duration getCurrentGameTime() {
    if (startTime == null) return accumulatedTime;
    
    if (pauseStartTime != null) {
      // 遊戲已暫停，返回累積時間
      return accumulatedTime;
    } else {
      // 遊戲進行中，返回累積時間加上當前會話時間
      final currentSessionTime = DateTime.now().difference(startTime!);
      return accumulatedTime + currentSessionTime;
    }
  }

  // 暫停遊戲計時
  void pauseTimer() {
    if (startTime != null && pauseStartTime == null) {
      // 累積當前會話的時間
      final currentSessionTime = DateTime.now().difference(startTime!);
      accumulatedTime += currentSessionTime;
      pauseStartTime = DateTime.now();
    }
  }

  // 恢復遊戲計時
  void resumeTimer() {
    if (pauseStartTime != null) {
      startTime = DateTime.now(); // 重新設置開始時間
      pauseStartTime = null;
    }
  }

  SudokuBoard copyWith({
    List<List<SudokuCell>>? grid,
    List<List<int>>? solution,
    Difficulty? difficulty,
    DateTime? startTime,
    Duration? elapsedTime,
    DateTime? pauseStartTime,
    Duration? accumulatedTime,
    int? hintsUsed,
    int? mistakes,
    int? lives,
    bool? isCompleted,
  }) {
    return SudokuBoard(
      grid: grid ?? this.grid.map((row) => row.map((cell) =>
        SudokuCell(
          value: cell.value,
          isFixed: cell.isFixed,
          isHighlighted: cell.isHighlighted,
          notes: Set<int>.from(cell.notes),
        )).toList()).toList(),
      solution: solution ?? this.solution.map((row) => List<int>.from(row)).toList(),
      difficulty: difficulty ?? this.difficulty,
      startTime: startTime ?? this.startTime,
      elapsedTime: elapsedTime ?? this.elapsedTime,
      pauseStartTime: pauseStartTime ?? this.pauseStartTime,
      accumulatedTime: accumulatedTime ?? this.accumulatedTime,
      hintsUsed: hintsUsed ?? this.hintsUsed,
      mistakes: mistakes ?? this.mistakes,
      lives: lives ?? this.lives,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
