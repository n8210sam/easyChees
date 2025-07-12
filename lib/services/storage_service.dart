import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sudoku_app/models/sudoku_board.dart';
import 'package:sudoku_app/models/sudoku_cell.dart';

class StorageService {
  static const String _gameKey = 'current_game';
  static const String _statisticsKey = 'game_statistics';

  Future<void> saveGame(SudokuBoard board) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final gameData = _boardToJson(board);
      await prefs.setString(_gameKey, jsonEncode(gameData));
    } catch (e) {
      print('Error saving game: $e');
    }
  }

  Future<SudokuBoard?> loadGame() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final gameDataString = prefs.getString(_gameKey);
      
      if (gameDataString != null) {
        final gameData = jsonDecode(gameDataString);
        return _boardFromJson(gameData);
      }
    } catch (e) {
      print('Error loading game: $e');
    }
    return null;
  }

  Future<void> clearSavedGame() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_gameKey);
    } catch (e) {
      print('Error clearing saved game: $e');
    }
  }

  Future<bool> hasSavedGame() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_gameKey);
    } catch (e) {
      print('Error checking for saved game: $e');
      return false;
    }
  }

  Map<String, dynamic> _boardToJson(SudokuBoard board) {
    return {
      'grid': board.grid.map((row) =>
        row.map((cell) => {
          'value': cell.value,
          'isFixed': cell.isFixed,
          'notes': cell.notes.toList(),
        }).toList()
      ).toList(),
      'solution': board.solution,
      'difficulty': board.difficulty.index,
      'startTime': board.startTime?.millisecondsSinceEpoch,
      'elapsedTime': board.elapsedTime?.inMilliseconds,
      'hintsUsed': board.hintsUsed,
      'mistakes': board.mistakes,
      'lives': board.lives,
      'isCompleted': board.isCompleted,
    };
  }

  SudokuBoard _boardFromJson(Map<String, dynamic> json) {
    final grid = (json['grid'] as List).map((row) =>
      (row as List).map((cellData) => SudokuCell(
        value: cellData['value'] as int,
        isFixed: cellData['isFixed'] as bool,
        notes: Set<int>.from(cellData['notes'] as List),
      )).toList()
    ).toList();

    // 向後兼容：如果沒有 solution 字段，創建空的解答
    List<List<int>> solution;
    if (json['solution'] != null) {
      solution = (json['solution'] as List).map((row) =>
        (row as List).map((value) => value as int).toList()
      ).toList();
    } else {
      // 舊版本數據沒有 solution，創建空的解答
      solution = List.generate(9, (row) => List.generate(9, (col) => 0));
    }

    return SudokuBoard(
      grid: grid,
      solution: solution,
      difficulty: Difficulty.values[json['difficulty'] as int],
      startTime: json['startTime'] != null
        ? DateTime.fromMillisecondsSinceEpoch(json['startTime'] as int)
        : null,
      elapsedTime: json['elapsedTime'] != null
        ? Duration(milliseconds: json['elapsedTime'] as int)
        : null,
      hintsUsed: json['hintsUsed'] as int,
      mistakes: json['mistakes'] as int? ?? 0,
      lives: json['lives'] as int? ?? 5,
      isCompleted: json['isCompleted'] as bool,
    );
  }

  // Game statistics
  Future<void> saveGameStatistics(GameStatistics stats) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_statisticsKey, jsonEncode(stats.toJson()));
    } catch (e) {
      print('Error saving statistics: $e');
    }
  }

  Future<GameStatistics> loadGameStatistics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statsString = prefs.getString(_statisticsKey);
      
      if (statsString != null) {
        final statsData = jsonDecode(statsString);
        return GameStatistics.fromJson(statsData);
      }
    } catch (e) {
      print('Error loading statistics: $e');
    }
    return GameStatistics();
  }
}

class GameStatistics {
  int gamesPlayed;
  int gamesCompleted;
  Map<Difficulty, int> completedByDifficulty;
  Map<Difficulty, Duration> bestTimeByDifficulty;
  int totalHintsUsed;

  GameStatistics({
    this.gamesPlayed = 0,
    this.gamesCompleted = 0,
    Map<Difficulty, int>? completedByDifficulty,
    Map<Difficulty, Duration>? bestTimeByDifficulty,
    this.totalHintsUsed = 0,
  }) : completedByDifficulty = completedByDifficulty ?? {
         Difficulty.easy: 0,
         Difficulty.medium: 0,
         Difficulty.hard: 0,
       },
       bestTimeByDifficulty = bestTimeByDifficulty ?? {};

  Map<String, dynamic> toJson() {
    return {
      'gamesPlayed': gamesPlayed,
      'gamesCompleted': gamesCompleted,
      'completedByDifficulty': completedByDifficulty.map(
        (key, value) => MapEntry(key.index.toString(), value),
      ),
      'bestTimeByDifficulty': bestTimeByDifficulty.map(
        (key, value) => MapEntry(key.index.toString(), value.inMilliseconds),
      ),
      'totalHintsUsed': totalHintsUsed,
    };
  }

  factory GameStatistics.fromJson(Map<String, dynamic> json) {
    return GameStatistics(
      gamesPlayed: json['gamesPlayed'] as int,
      gamesCompleted: json['gamesCompleted'] as int,
      completedByDifficulty: (json['completedByDifficulty'] as Map<String, dynamic>)
        .map((key, value) => MapEntry(
          Difficulty.values[int.parse(key)],
          value as int,
        )),
      bestTimeByDifficulty: (json['bestTimeByDifficulty'] as Map<String, dynamic>)
        .map((key, value) => MapEntry(
          Difficulty.values[int.parse(key)],
          Duration(milliseconds: value as int),
        )),
      totalHintsUsed: json['totalHintsUsed'] as int,
    );
  }

  void recordGameStart() {
    gamesPlayed++;
  }

  void recordGameCompletion(Difficulty difficulty, Duration time, int hintsUsed) {
    gamesCompleted++;
    completedByDifficulty[difficulty] = (completedByDifficulty[difficulty] ?? 0) + 1;
    totalHintsUsed += hintsUsed;
    
    if (!bestTimeByDifficulty.containsKey(difficulty) ||
        time < bestTimeByDifficulty[difficulty]!) {
      bestTimeByDifficulty[difficulty] = time;
    }
  }

  double get completionRate {
    if (gamesPlayed == 0) return 0.0;
    return gamesCompleted / gamesPlayed;
  }
}
