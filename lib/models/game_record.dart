import 'package:sudoku_app/models/sudoku_board.dart';

class GameRecord {
  final String id;
  final Difficulty difficulty;
  final DateTime startTime;
  final DateTime endTime;
  final Duration playTime;
  final bool isCompleted;
  final int hintsUsed;
  final int mistakes;
  
  GameRecord({
    required this.id,
    required this.difficulty,
    required this.startTime,
    required this.endTime,
    required this.playTime,
    required this.isCompleted,
    this.hintsUsed = 0,
    this.mistakes = 0,
  });

  // 計算遊戲評分 (0-100)
  int get score {
    if (!isCompleted) return 0;
    
    int baseScore = 100;
    
    // 根據難度調整基礎分數
    switch (difficulty) {
      case Difficulty.easy:
        baseScore = 60;
        break;
      case Difficulty.medium:
        baseScore = 80;
        break;
      case Difficulty.hard:
        baseScore = 100;
        break;
    }
    
    // 扣除提示和錯誤的分數
    int penalty = (hintsUsed * 5) + (mistakes * 10);
    
    // 根據完成時間調整分數
    int timeBonus = 0;
    if (playTime.inMinutes < 5) {
      timeBonus = 20;
    } else if (playTime.inMinutes < 10) {
      timeBonus = 10;
    } else if (playTime.inMinutes < 20) {
      timeBonus = 5;
    }
    
    return (baseScore + timeBonus - penalty).clamp(0, 100);
  }

  // 格式化遊戲時間
  String get formattedPlayTime {
    final hours = playTime.inHours;
    final minutes = playTime.inMinutes % 60;
    final seconds = playTime.inSeconds % 60;
    
    if (hours > 0) {
      return '$hours時$minutes分$seconds秒';
    } else if (minutes > 0) {
      return '$minutes分$seconds秒';
    } else {
      return '$seconds秒';
    }
  }

  // 難度中文名稱
  String get difficultyName {
    switch (difficulty) {
      case Difficulty.easy:
        return '簡單';
      case Difficulty.medium:
        return '中等';
      case Difficulty.hard:
        return '困難';
    }
  }

  // 轉換為JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'difficulty': difficulty.index,
      'startTime': startTime.millisecondsSinceEpoch,
      'endTime': endTime.millisecondsSinceEpoch,
      'playTime': playTime.inMilliseconds,
      'isCompleted': isCompleted,
      'hintsUsed': hintsUsed,
      'mistakes': mistakes,
    };
  }

  // 從JSON創建
  factory GameRecord.fromJson(Map<String, dynamic> json) {
    return GameRecord(
      id: json['id'],
      difficulty: Difficulty.values[json['difficulty']],
      startTime: DateTime.fromMillisecondsSinceEpoch(json['startTime']),
      endTime: DateTime.fromMillisecondsSinceEpoch(json['endTime']),
      playTime: Duration(milliseconds: json['playTime']),
      isCompleted: json['isCompleted'],
      hintsUsed: json['hintsUsed'] ?? 0,
      mistakes: json['mistakes'] ?? 0,
    );
  }

  @override
  String toString() {
    return 'GameRecord(id: $id, difficulty: $difficultyName, playTime: $formattedPlayTime, score: $score)';
  }
}
