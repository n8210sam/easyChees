import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sudoku_app/models/game_record.dart';
import 'package:sudoku_app/models/sudoku_board.dart';

class GameRecordService {
  static const String _recordsKey = 'game_records';
  static const int _maxRecords = 100; // 最多保存100條記錄

  // 保存遊戲記錄
  Future<void> saveGameRecord(GameRecord record) async {
    final prefs = await SharedPreferences.getInstance();
    
    // 獲取現有記錄
    List<GameRecord> records = await getGameRecords();
    
    // 添加新記錄到開頭
    records.insert(0, record);
    
    // 限制記錄數量
    if (records.length > _maxRecords) {
      records = records.take(_maxRecords).toList();
    }
    
    // 轉換為JSON並保存
    final jsonList = records.map((record) => record.toJson()).toList();
    await prefs.setString(_recordsKey, jsonEncode(jsonList));
  }

  // 獲取所有遊戲記錄
  Future<List<GameRecord>> getGameRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_recordsKey);
    
    if (jsonString == null) return [];
    
    try {
      final jsonList = jsonDecode(jsonString) as List;
      return jsonList
          .map((json) => GameRecord.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // 如果解析失敗，返回空列表
      return [];
    }
  }

  // 根據難度篩選記錄
  Future<List<GameRecord>> getRecordsByDifficulty(Difficulty difficulty) async {
    final allRecords = await getGameRecords();
    return allRecords.where((record) => record.difficulty == difficulty).toList();
  }

  // 獲取已完成的遊戲記錄
  Future<List<GameRecord>> getCompletedRecords() async {
    final allRecords = await getGameRecords();
    return allRecords.where((record) => record.isCompleted).toList();
  }

  // 獲取統計信息
  Future<GameStatistics> getStatistics() async {
    final allRecords = await getGameRecords();
    final completedRecords = allRecords.where((record) => record.isCompleted).toList();
    
    if (completedRecords.isEmpty) {
      return GameStatistics(
        totalGames: allRecords.length,
        completedGames: 0,
        completionRate: 0.0,
        averageTime: Duration.zero,
        bestTime: Duration.zero,
        averageScore: 0.0,
        bestScore: 0,
        easyCompleted: 0,
        mediumCompleted: 0,
        hardCompleted: 0,
      );
    }
    
    // 計算統計數據
    final totalTime = completedRecords.fold<Duration>(
      Duration.zero,
      (sum, record) => sum + record.playTime,
    );
    
    final averageTime = Duration(
      milliseconds: totalTime.inMilliseconds ~/ completedRecords.length,
    );
    
    final bestTime = completedRecords
        .map((record) => record.playTime)
        .reduce((a, b) => a.inMilliseconds < b.inMilliseconds ? a : b);
    
    final averageScore = completedRecords
        .map((record) => record.score)
        .reduce((a, b) => a + b) / completedRecords.length;
    
    final bestScore = completedRecords
        .map((record) => record.score)
        .reduce((a, b) => a > b ? a : b);
    
    final easyCompleted = completedRecords
        .where((record) => record.difficulty == Difficulty.easy)
        .length;
    
    final mediumCompleted = completedRecords
        .where((record) => record.difficulty == Difficulty.medium)
        .length;
    
    final hardCompleted = completedRecords
        .where((record) => record.difficulty == Difficulty.hard)
        .length;
    
    return GameStatistics(
      totalGames: allRecords.length,
      completedGames: completedRecords.length,
      completionRate: completedRecords.length / allRecords.length,
      averageTime: averageTime,
      bestTime: bestTime,
      averageScore: averageScore,
      bestScore: bestScore,
      easyCompleted: easyCompleted,
      mediumCompleted: mediumCompleted,
      hardCompleted: hardCompleted,
    );
  }

  // 清除所有記錄
  Future<void> clearAllRecords() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_recordsKey);
  }

  // 刪除指定記錄
  Future<void> deleteRecord(String recordId) async {
    final records = await getGameRecords();
    final updatedRecords = records.where((record) => record.id != recordId).toList();
    
    final prefs = await SharedPreferences.getInstance();
    final jsonList = updatedRecords.map((record) => record.toJson()).toList();
    await prefs.setString(_recordsKey, jsonEncode(jsonList));
  }
}

// 遊戲統計信息類
class GameStatistics {
  final int totalGames;
  final int completedGames;
  final double completionRate;
  final Duration averageTime;
  final Duration bestTime;
  final double averageScore;
  final int bestScore;
  final int easyCompleted;
  final int mediumCompleted;
  final int hardCompleted;

  GameStatistics({
    required this.totalGames,
    required this.completedGames,
    required this.completionRate,
    required this.averageTime,
    required this.bestTime,
    required this.averageScore,
    required this.bestScore,
    required this.easyCompleted,
    required this.mediumCompleted,
    required this.hardCompleted,
  });

  String get formattedCompletionRate => '${(completionRate * 100).toStringAsFixed(1)}%';
  
  String get formattedAverageTime {
    final minutes = averageTime.inMinutes;
    final seconds = averageTime.inSeconds % 60;
    return '$minutes分$seconds秒';
  }
  
  String get formattedBestTime {
    final minutes = bestTime.inMinutes;
    final seconds = bestTime.inSeconds % 60;
    return '$minutes分$seconds秒';
  }
  
  String get formattedAverageScore => averageScore.toStringAsFixed(1);
}
