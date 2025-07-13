import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudoku_app/providers/game_provider.dart';
import 'package:sudoku_app/widgets/sudoku_board_widget.dart';
import 'package:sudoku_app/widgets/number_input_widget.dart';
import 'package:sudoku_app/widgets/game_controls_widget.dart';
import 'package:sudoku_app/widgets/game_info_widget.dart';
import 'package:sudoku_app/widgets/completion_dialog.dart';
import 'package:sudoku_app/widgets/game_over_dialog.dart';
import 'package:sudoku_app/widgets/life_lost_dialog.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  @override
  Widget build(BuildContext context) {
    // 動態計算螢幕尺寸和佈局
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;
    final screenWidth = screenSize.width;
    final isPortrait = screenHeight > screenWidth;

    // 計算各組件高度 - 響應式佈局
    const appBarHeight = kToolbarHeight;
    final statusBarHeight = MediaQuery.of(context).padding.top;

    // 根據螢幕尺寸調整高度
    double gameInfoHeight, numberInputHeight, controlsHeight;

    if (screenWidth >= 900) {
      // 桌面 - 增加高度容納極大按鈕
      gameInfoHeight = 100.0;
      numberInputHeight = isPortrait ? 190.0 : 110.0;
      controlsHeight = 100.0;
    } else if (screenWidth >= 600) {
      // 平板 - 增加高度容納極大按鈕
      gameInfoHeight = 95.0;
      numberInputHeight = isPortrait ? 180.0 : 105.0;
      controlsHeight = 95.0;
    } else {
      // 手機
      gameInfoHeight = 85.0;
      numberInputHeight = isPortrait ? 110.0 : 65.0;
      controlsHeight = 55.0;
    }

    const totalPadding = 24.0; // 總間距

    final availableHeight = screenHeight - appBarHeight - statusBarHeight -
                           gameInfoHeight - numberInputHeight - controlsHeight - totalPadding;

    // 遊戲盤面尺寸（確保不超出螢幕，但盡可能大）
    final maxBoardSize = screenWidth * 0.95;
    final boardSize = availableHeight > maxBoardSize ? maxBoardSize : availableHeight;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final gameProvider = Provider.of<GameProvider>(context, listen: false);

        // 自動暫停遊戲並保存，不詢問直接返回
        if (gameProvider.currentBoard != null) {
          await gameProvider.forcePauseGame(); // 強制暫停並保存
        }

        if (context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
      appBar: AppBar(
        title: const Text('數獨遊戲'),
        actions: [
          Consumer<GameProvider>(
            builder: (context, gameProvider, child) {
              return IconButton(
                icon: Icon(
                  gameProvider.isGamePaused ? Icons.play_arrow : Icons.pause,
                ),
                onPressed: () => gameProvider.pauseGame(),
              );
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(context, value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'new_game',
                child: Row(
                  children: [
                    Icon(Icons.refresh),
                    SizedBox(width: 8),
                    Text('新遊戲'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'statistics',
                child: Row(
                  children: [
                    Icon(Icons.bar_chart),
                    SizedBox(width: 8),
                    Text('統計'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings),
                    SizedBox(width: 8),
                    Text('設置'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<GameProvider>(
        builder: (context, gameProvider, child) {
          if (gameProvider.currentBoard == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Show dialogs based on game state
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (gameProvider.currentBoard!.isCompleted) {
              _showCompletionDialog(context, gameProvider);
            } else if (gameProvider.isGameOver) {
              _showGameOverDialog(context);
            } else if (gameProvider.showLifeLostDialog) {
              _showLifeLostDialog(context);
            }
          });

          // 如果遊戲暫停，顯示暫停界面
          if (gameProvider.isGamePaused && !gameProvider.showLifeLostDialog) {
            return _buildPauseScreen(context, gameProvider);
          }

          return Column(
            children: [
              // Game Info - 響應式高度
              SizedBox(
                height: gameInfoHeight,
                child: const GameInfoWidget(),
              ),

              // Sudoku Board - 使用計算的尺寸
              Container(
                height: boardSize,
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Center(
                  child: SizedBox(
                    width: boardSize,
                    height: boardSize,
                    child: SudokuBoardWidget(
                      board: gameProvider.currentBoard!,
                      selectedRow: gameProvider.selectedRow,
                      selectedCol: gameProvider.selectedCol,
                      highlightedNumber: gameProvider.highlightedNumber,
                      lastSelectedNumber: gameProvider.lastSelectedNumber,
                      onCellTap: gameProvider.selectCell,
                      onCellLongPress: gameProvider.longPressCell,
                      isNumberCompleted: gameProvider.isNumberCompleted,
                    ),
                  ),
                ),
              ),

              // Number Input - 固定高度
              SizedBox(
                height: numberInputHeight,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: Column(
                    children: [
                      // 連續輸入提示
                      if (gameProvider.isContinuousInputEnabled && gameProvider.lastSelectedNumber != null)
                        Container(
                          margin: const EdgeInsets.only(bottom: 8.0),
                          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            '連續輸入: ${gameProvider.lastSelectedNumber} (點擊空格自動填入)',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                      // 數字輸入面板
                      Expanded(
                        child: NumberInputWidget(
                          onNumberTap: gameProvider.inputNumber,
                          onNumberLongPress: gameProvider.longPressNumber,
                          onDeleteTap: gameProvider.deleteCell,
                          isNotesMode: gameProvider.isNotesMode,
                          lastSelectedNumber: gameProvider.lastSelectedNumber,
                          numberCounts: gameProvider.numberCounts,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Game Controls - 響應式高度
              SizedBox(
                height: controlsHeight,
                child: const GameControlsWidget(),
              ),
            ],
          );
        },
      ),
      ),
    );
  }

  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'new_game':
        _showNewGameDialog(context);
        break;
      case 'statistics':
        _showStatisticsDialog(context);
        break;
      case 'settings':
        _showSettingsDialog(context);
        break;
    }
  }

  void _showNewGameDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('開始新遊戲'),
        content: const Text('確定要開始新遊戲嗎？當前進度將會丟失。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Return to home screen
            },
            child: const Text('確定'),
          ),
        ],
      ),
    );
  }

  void _showStatisticsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('遊戲統計'),
        content: const Text('統計功能即將推出...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('確定'),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('設置'),
        content: const Text('設置功能即將推出...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('確定'),
          ),
        ],
      ),
    );
  }

  void _showCompletionDialog(BuildContext context, GameProvider gameProvider) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CompletionDialog(
        board: gameProvider.currentBoard!,
        onNewGame: () {
          Navigator.of(context).pop(); // Close dialog
          Navigator.of(context).pop(); // Return to home screen
        },
        onHome: () {
          Navigator.of(context).pop(); // Close dialog
          Navigator.of(context).pop(); // Return to home screen
        },
      ),
    );
  }

  void _showGameOverDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const GameOverDialog(),
    );
  }

  void _showLifeLostDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const LifeLostDialog(),
    );
  }

  Widget _buildPauseScreen(BuildContext context, GameProvider gameProvider) {
    return Container(
      color: Colors.black.withValues(alpha: 0.8),
      child: Center(
        child: Card(
          margin: const EdgeInsets.all(32.0),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.pause_circle_filled,
                  size: 64,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 16),
                const Text(
                  '遊戲已暫停',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '點擊繼續按鈕恢復遊戲',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => gameProvider.pauseGame(),
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('繼續'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _showNewGameDialog(context),
                      icon: const Icon(Icons.refresh),
                      label: const Text('新遊戲'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
