import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudoku_app/models/game_record.dart';
import 'package:sudoku_app/models/sudoku_board.dart';
import 'package:sudoku_app/providers/game_provider.dart';
import 'package:sudoku_app/services/game_record_service.dart';

class GameRecordsScreen extends StatefulWidget {
  const GameRecordsScreen({super.key});

  @override
  State<GameRecordsScreen> createState() => _GameRecordsScreenState();
}

class _GameRecordsScreenState extends State<GameRecordsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<List<GameRecord>> _recordsFuture;
  late Future<GameStatistics> _statisticsFuture;
  Difficulty? _selectedDifficulty;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  void _loadData() {
    final recordService = context.read<GameProvider>().recordService;
    _recordsFuture = _selectedDifficulty == null
        ? recordService.getGameRecords()
        : recordService.getRecordsByDifficulty(_selectedDifficulty!);
    _statisticsFuture = recordService.getStatistics();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('遊戲記錄'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.list), text: '記錄列表'),
            Tab(icon: Icon(Icons.analytics), text: '統計信息'),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.clear_all),
                    SizedBox(width: 8),
                    Text('清除所有記錄'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRecordsTab(),
          _buildStatisticsTab(),
        ],
      ),
    );
  }

  Widget _buildRecordsTab() {
    return Column(
      children: [
        // 難度篩選器
        Container(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const Text('篩選難度: '),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButton<Difficulty?>(
                  value: _selectedDifficulty,
                  isExpanded: true,
                  onChanged: (difficulty) {
                    setState(() {
                      _selectedDifficulty = difficulty;
                      _loadData();
                    });
                  },
                  items: [
                    const DropdownMenuItem<Difficulty?>(
                      value: null,
                      child: Text('全部'),
                    ),
                    ...Difficulty.values.map((difficulty) {
                      return DropdownMenuItem<Difficulty?>(
                        value: difficulty,
                        child: Text(_getDifficultyName(difficulty)),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // 記錄列表
        Expanded(
          child: FutureBuilder<List<GameRecord>>(
            future: _recordsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (snapshot.hasError) {
                return Center(
                  child: Text('載入失敗: ${snapshot.error}'),
                );
              }
              
              final records = snapshot.data ?? [];
              
              if (records.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('暫無遊戲記錄', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                );
              }
              
              return ListView.builder(
                itemCount: records.length,
                itemBuilder: (context, index) {
                  final record = records[index];
                  return _buildRecordCard(record);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecordCard(GameRecord record) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getDifficultyColor(record.difficulty),
          child: Text(
            record.score.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          '${record.difficultyName} - ${record.formattedPlayTime}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('完成時間: ${_formatDateTime(record.endTime)}'),
            if (record.hintsUsed > 0)
              Text('使用提示: ${record.hintsUsed}次'),
          ],
        ),
        trailing: record.isCompleted
            ? const Icon(Icons.check_circle, color: Colors.green)
            : const Icon(Icons.cancel, color: Colors.red),
        onTap: () => _showRecordDetails(record),
      ),
    );
  }

  Widget _buildStatisticsTab() {
    return FutureBuilder<GameStatistics>(
      future: _statisticsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(
            child: Text('載入失敗: ${snapshot.error}'),
          );
        }
        
        final stats = snapshot.data!;
        
        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildStatCard('總遊戲數', stats.totalGames.toString()),
            _buildStatCard('完成遊戲數', stats.completedGames.toString()),
            _buildStatCard('完成率', stats.formattedCompletionRate),
            if (stats.completedGames > 0) ...[
              _buildStatCard('平均時間', stats.formattedAverageTime),
              _buildStatCard('最佳時間', stats.formattedBestTime),
              _buildStatCard('平均分數', stats.formattedAverageScore),
              _buildStatCard('最高分數', stats.bestScore.toString()),
              const SizedBox(height: 16),
              const Text(
                '各難度完成數',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildStatCard('簡單', stats.easyCompleted.toString()),
              _buildStatCard('中等', stats.mediumCompleted.toString()),
              _buildStatCard('困難', stats.hardCompleted.toString()),
            ],
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getDifficultyName(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return '簡單';
      case Difficulty.medium:
        return '中等';
      case Difficulty.hard:
        return '困難';
    }
  }

  Color _getDifficultyColor(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return Colors.green;
      case Difficulty.medium:
        return Colors.orange;
      case Difficulty.hard:
        return Colors.red;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}/${dateTime.month}/${dateTime.day} '
           '${dateTime.hour.toString().padLeft(2, '0')}:'
           '${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _showRecordDetails(GameRecord record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${record.difficultyName}難度記錄'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('分數: ${record.score}'),
            Text('遊戲時間: ${record.formattedPlayTime}'),
            Text('開始時間: ${_formatDateTime(record.startTime)}'),
            Text('完成時間: ${_formatDateTime(record.endTime)}'),
            Text('使用提示: ${record.hintsUsed}次'),
            Text('狀態: ${record.isCompleted ? "已完成" : "未完成"}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('關閉'),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'clear':
        _showClearConfirmDialog();
        break;
    }
  }

  void _showClearConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('確認清除'),
        content: const Text('確定要清除所有遊戲記錄嗎？此操作無法撤銷。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await context.read<GameProvider>().recordService.clearAllRecords();
              setState(() {
                _loadData();
              });
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('已清除所有記錄')),
                );
              }
            },
            child: const Text('確定'),
          ),
        ],
      ),
    );
  }
}
