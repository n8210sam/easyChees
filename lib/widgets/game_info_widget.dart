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
        final isMobile = screenWidth < 600;
        final isTablet = screenWidth >= 600 && screenWidth < 900;
        final isDesktop = screenWidth >= 900;

        // 響應式容器間距 - 桌面版減少內邊距避免溢出
        final containerPadding = isDesktop 
            ? const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0)
            : isTablet 
                ? const EdgeInsets.all(16.0)
                : const EdgeInsets.all(12.0);

        return Container(
          padding: containerPadding,
          child: Consumer<SettingsProvider>(
            builder: (context, settingsProvider, child) {
              final showTimer = settingsProvider.showTimer;

              // 響應式間距
              final itemSpacing = isMobile ? 4.0 : (isTablet ? 6.0 : 8.0);

              final items = <Widget>[
                // Difficulty
                _buildCompactInfoItem(
                  context,
                  icon: Icons.speed,
                  label: '難度',
                  showLabel: !isMobile,
                  value: _getDifficultyText(board.difficulty),
                  color: _getDifficultyColor(board.difficulty),
                ),

                // Timer (conditional)
                if (showTimer)
                  StreamBuilder<DateTime>(
                    stream: _timeStream,
                    builder: (context, snapshot) {
                      return _buildCompactInfoItem(
                        context,
                        icon: Icons.timer,
                        label: '時間',
                        showLabel: !isMobile,
                        value: _getElapsedTime(board, isMobile),
                        color: Colors.blue,
                      );
                    },
                  ),

                // Lives
                _buildCompactInfoItem(
                  context,
                  icon: Icons.favorite,
                  label: '生命',
                  showLabel: !isMobile,
                  value: '${board.lives}',
                  color: board.lives <= 1
                      ? Colors.red
                      : (board.lives <= 2
                          ? Colors.orange
                          : Colors.pink),
                ),

                // Mistakes
                _buildCompactInfoItem(
                  context,
                  icon: Icons.error_outline,
                  label: '錯誤',
                  showLabel: !isMobile,
                  value: '${board.mistakes}/${gameProvider.maxMistakes}',
                  color: board.mistakes >= gameProvider.maxMistakes
                      ? Colors.red
                      : (board.mistakes > gameProvider.maxMistakes * 0.7
                          ? Colors.orange
                          : Colors.grey),
                ),

                // Hints Used - 顯示為A/B格式
                _buildCompactInfoItem(
                  context,
                  icon: Icons.lightbulb,
                  label: '提示',
                  showLabel: !isMobile,
                  value: '${board.hintsUsed}/${gameProvider.hintLimit}',
                  color: board.hintsUsed >= gameProvider.hintLimit
                      ? Colors.red
                      : (board.hintsUsed > gameProvider.hintLimit * 0.7
                          ? Colors.orange
                          : Colors.amber),
                ),
              ];

              return Row(
                children: items.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: index < items.length - 1 ? itemSpacing : 0,
                      ),
                      child: item,
                    ),
                  );
                }).toList(),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildCompactInfoItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool showLabel, // 是否顯示標籤
    required String value,
    required Color color,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 900;
    final isDesktop = screenWidth >= 900;

    // 響應式字體大小
    double iconSize, labelFontSize, valueFontSize;
    EdgeInsets padding;

    if (isDesktop) {
      iconSize = showLabel ? 24 : 28;
      labelFontSize = 14;
      valueFontSize = showLabel ? 16 : 20;
      padding = EdgeInsets.symmetric(
        vertical: showLabel ? 12.0 : 10.0,
        horizontal: showLabel ? 16.0 : 12.0,
      );
    } else if (isTablet) {
      iconSize = showLabel ? 20 : 24;
      labelFontSize = 12;
      valueFontSize = showLabel ? 14 : 18;
      padding = EdgeInsets.symmetric(
        vertical: showLabel ? 10.0 : 8.0,
        horizontal: showLabel ? 14.0 : 10.0,
      );
    } else {
      // 手機
      iconSize = showLabel ? 16 : 18;
      labelFontSize = 9;
      valueFontSize = showLabel ? 10 : 14;
      padding = EdgeInsets.symmetric(
        vertical: showLabel ? 6.0 : 4.0,
        horizontal: showLabel ? 8.0 : 6.0,
      );
    }

    return Container(
        padding: padding,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: showLabel && !isMobile
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 平板以上：圖示和標題在同一行
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        icon,
                        size: iconSize,
                        color: color,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: labelFontSize,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: valueFontSize,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 手機版：保持原有佈局
                  Icon(
                    icon,
                    size: iconSize,
                    color: color,
                  ),
                  if (showLabel) ...[
                    SizedBox(height: isMobile ? 2 : 4),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: labelFontSize,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  SizedBox(height: showLabel ? 2 : 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: valueFontSize,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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

  String _getElapsedTime(SudokuBoard board, [bool isMobile = false]) {
    final elapsed = board.getCurrentGameTime();

    final hours = elapsed.inHours;
    final minutes = elapsed.inMinutes % 60;
    final seconds = elapsed.inSeconds % 60;

    if (isMobile) {
      // 手機版：更緊湊的格式
      if (hours > 0) {
        return '${hours}h${minutes.toString().padLeft(2, '0')}m';
      } else if (minutes > 0) {
        return '${minutes}m${seconds.toString().padLeft(2, '0')}s';
      } else {
        return '${seconds}s';
      }
    } else {
      // 平板和桌面版：標準格式
      if (hours > 0) {
        return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
      } else {
        return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
      }
    }
  }
}
