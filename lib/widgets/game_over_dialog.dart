import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudoku_app/providers/game_provider.dart';
import 'package:sudoku_app/models/sudoku_board.dart';

class GameOverDialog extends StatelessWidget {
  const GameOverDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        final board = gameProvider.currentBoard;
        if (board == null) return const SizedBox.shrink();

        return AlertDialog(
          title: const Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 28,
              ),
              SizedBox(width: 8),
              Text(
                '遊戲結束',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '很遺憾，您已達到錯誤限制！',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 16),
              _buildStatRow('難度', _getDifficultyText(board.difficulty)),
              _buildStatRow('錯誤次數', '${board.mistakes}/${gameProvider.maxMistakes}'),
              _buildStatRow('使用提示', '${board.hintsUsed} 次'),
              _buildStatRow('遊戲時間', _formatDuration(board.elapsedTime)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.blue.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.tips_and_updates,
                      color: Colors.blue,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '提示：使用筆記功能可以幫助您避免錯誤！',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // 返回主菜單
              },
              child: const Text('返回主菜單'),
            ),
            if (board.lives <= 0) // 只有在生命為0時顯示充值按鈕
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  gameProvider.rechargeLife();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('充值'),
              ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _startNewGame(context, board.difficulty);
              },
              child: const Text('重新開始'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _getDifficultyText(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return '簡單';
      case Difficulty.medium:
        return '中等';
      case Difficulty.hard:
        return '困難';
    }
  }

  String _formatDuration(Duration? duration) {
    if (duration == null) return '00:00';
    
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _startNewGame(BuildContext context, Difficulty difficulty) {
    final gameProvider = context.read<GameProvider>();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
    
    gameProvider.startNewGame(difficulty).then((_) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog
      }
    });
  }
}
