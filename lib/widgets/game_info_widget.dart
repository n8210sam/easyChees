import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudoku_app/providers/game_provider.dart';
import 'package:sudoku_app/providers/settings_provider.dart';
import 'package:sudoku_app/models/sudoku_board.dart';

class GameInfoWidget extends StatefulWidget {
  const GameInfoWidget({super.key});

  @override
  State<GameInfoWidget> createState() => _GameInfoWidgetState();
}

class _GameInfoWidgetState extends State<GameInfoWidget> {
  late Stream<DateTime> _timeStream;

  @override
  void initState() {
    super.initState();
    _timeStream = Stream.periodic(
      const Duration(seconds: 1),
      (_) => DateTime.now(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        final board = gameProvider.currentBoard;
        if (board == null) return const SizedBox.shrink();

        final screenWidth = MediaQuery.of(context).size.width;
        final isTabletOrLarger = screenWidth >= 600; // 平板以上顯示中文

        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Consumer<SettingsProvider>(
            builder: (context, settingsProvider, child) {
              final showTimer = settingsProvider.showTimer;

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Difficulty
                  _buildResponsiveInfoItem(
                    context,
                    icon: Icons.speed,
                    label: isTabletOrLarger ? '難度' : null,
                    value: _getDifficultyText(board.difficulty),
                    color: _getDifficultyColor(board.difficulty),
                  ),

                  // Timer (conditional)
                  if (showTimer)
                    StreamBuilder<DateTime>(
                      stream: _timeStream,
                      builder: (context, snapshot) {
                        return _buildResponsiveInfoItem(
                          context,
                          icon: Icons.timer,
                          label: isTabletOrLarger ? '時間' : null,
                          value: _getElapsedTime(board),
                          color: Colors.blue,
                        );
                      },
                    ),

                  // Lives
                  _buildResponsiveInfoItem(
                    context,
                    icon: Icons.favorite,
                    label: isTabletOrLarger ? '生命' : null,
                    value: '${board.lives}',
                    color: board.lives <= 1
                        ? Colors.red
                        : (board.lives <= 2
                            ? Colors.orange
                            : Colors.pink),
                  ),

              // Mistakes
              _buildResponsiveInfoItem(
                context,
                icon: Icons.error_outline,
                label: isTabletOrLarger ? '錯誤' : null,
                value: '${board.mistakes}/${gameProvider.maxMistakes}',
                color: board.mistakes >= gameProvider.maxMistakes
                    ? Colors.red
                    : (board.mistakes > gameProvider.maxMistakes * 0.7
                        ? Colors.orange
                        : Colors.grey),
              ),

                  // Hints Used
                  _buildResponsiveInfoItem(
                    context,
                    icon: Icons.lightbulb,
                    label: isTabletOrLarger ? '提示' : null,
                    value: board.hintsUsed.toString(),
                    color: Colors.amber,
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildResponsiveInfoItem(
    BuildContext context, {
    required IconData icon,
    String? label, // 可選的標籤
    required String value,
    required Color color,
  }) {
    final hasLabel = label != null && label.isNotEmpty;

    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: hasLabel ? 8.0 : 6.0,
          horizontal: hasLabel ? 12.0 : 8.0,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: hasLabel ? 18 : 20,
              color: color,
            ),
            if (hasLabel) ...[
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            SizedBox(height: hasLabel ? 2 : 4),
            Text(
              value,
              style: TextStyle(
                fontSize: hasLabel ? 12 : 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
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

  String _getElapsedTime(SudokuBoard board) {
    if (board.startTime == null) return '00:00';
    
    final now = DateTime.now();
    final elapsed = now.difference(board.startTime!);
    
    final minutes = elapsed.inMinutes;
    final seconds = elapsed.inSeconds % 60;
    
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
