import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudoku_app/providers/game_provider.dart';
import 'package:sudoku_app/models/sudoku_board.dart';

class LifeLostDialog extends StatelessWidget {
  const LifeLostDialog({super.key});

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
                Icons.favorite_border,
                color: Colors.red,
                size: 28,
              ),
              SizedBox(width: 8),
              Text(
                '失去生命',
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
                '您已達到錯誤限制，失去了一條生命！',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 16),
              _buildStatRow('剩餘生命', '${board.lives}'),
              _buildStatRow('難度', _getDifficultyText(board.difficulty)),
              _buildStatRow('錯誤限制', '${gameProvider.maxMistakes} 次'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: board.lives <= 1 
                      ? Colors.red.withValues(alpha: 0.1)
                      : Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: board.lives <= 1 
                        ? Colors.red.withValues(alpha: 0.3)
                        : Colors.orange.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      board.lives <= 1 ? Icons.warning : Icons.info,
                      color: board.lives <= 1 ? Colors.red : Colors.orange,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        board.lives <= 1 
                            ? '警告：這是您的最後一條生命！'
                            : '提示：小心使用剩餘的生命！',
                        style: TextStyle(
                          fontSize: 14,
                          color: board.lives <= 1 
                              ? Colors.red[700] 
                              : Colors.orange[700],
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
                gameProvider.giveUpGame();
                Navigator.of(context).pop(); // 返回主菜單
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('放棄'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                gameProvider.continueGame();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('繼續'),
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
}
