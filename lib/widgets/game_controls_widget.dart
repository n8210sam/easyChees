import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudoku_app/providers/game_provider.dart';

class GameControlsWidget extends StatelessWidget {
  const GameControlsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Notes Mode Toggle
          Consumer<GameProvider>(
            builder: (context, gameProvider, child) {
              return _buildControlButton(
                context,
                icon: Icons.edit_note,
                label: '筆記',
                isActive: gameProvider.isNotesMode,
                onTap: gameProvider.toggleNotesMode,
              );
            },
          ),
          
          // Hint Button
          Consumer<GameProvider>(
            builder: (context, gameProvider, child) {
              return _buildControlButton(
                context,
                icon: Icons.lightbulb_outline,
                label: '提示',
                isActive: false,
                onTap: () => _showHintDialog(context, gameProvider),
              );
            },
          ),
          
          // Undo Button
          Consumer<GameProvider>(
            builder: (context, gameProvider, child) {
              return _buildControlButton(
                context,
                icon: Icons.undo,
                label: '撤銷',
                isActive: false,
                isEnabled: gameProvider.canUndo,
                onTap: () => _handleUndo(context, gameProvider),
              );
            },
          ),

          // Redo Button
          Consumer<GameProvider>(
            builder: (context, gameProvider, child) {
              return _buildControlButton(
                context,
                icon: Icons.redo,
                label: '重做',
                isActive: false,
                isEnabled: gameProvider.canRedo,
                onTap: () => _handleRedo(context, gameProvider),
              );
            },
          ),

          // Erase Button
          Consumer<GameProvider>(
            builder: (context, gameProvider, child) {
              return _buildControlButton(
                context,
                icon: Icons.cleaning_services,
                label: '擦除',
                isActive: false,
                isEnabled: gameProvider.hasSelectedCell && !gameProvider.isGamePaused,
                onTap: () => _handleErase(context, gameProvider),
              );
            },
          ),

          // Continuous Input Toggle
          Consumer<GameProvider>(
            builder: (context, gameProvider, child) {
              return _buildControlButton(
                context,
                icon: Icons.touch_app,
                label: '連續輸入',
                isActive: gameProvider.isContinuousInputEnabled,
                onTap: gameProvider.toggleContinuousInput,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    bool isEnabled = true,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Material(
          color: isActive
              ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            onTap: isEnabled ? onTap : null,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isActive
                      ? Theme.of(context).primaryColor
                      : isEnabled
                          ? Colors.grey.shade300
                          : Colors.grey.shade200,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 24,
                    color: isActive
                        ? Theme.of(context).primaryColor
                        : isEnabled
                            ? Colors.grey.shade600
                            : Colors.grey.shade400,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isActive
                          ? Theme.of(context).primaryColor
                          : isEnabled
                              ? Colors.grey.shade600
                              : Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showHintDialog(BuildContext context, GameProvider gameProvider) {
    if (!gameProvider.canUseHint) {
      // 顯示提示上限訊息
      _showMessage(context, '本難度提示次數已達上限 (${gameProvider.hintLimit} 次)');
      return;
    }

    if (!gameProvider.hasSelectedCell) {
      _showMessage(context, '請先選擇一個空格');
      return;
    }

    final selectedCell = gameProvider.selectedCell;
    if (selectedCell?.isFixed == true || selectedCell?.value != 0) {
      _showMessage(context, '請選擇一個空的格子');
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('使用提示'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('確定要使用提示嗎？這會在選中的格子中填入正確答案。'),
            const SizedBox(height: 8),
            Text(
              '剩餘提示次數: ${gameProvider.hintLimit - gameProvider.currentBoard!.hintsUsed}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              gameProvider.getHint();
              _showMessage(context, '提示已使用');
            },
            child: const Text('確定'),
          ),
        ],
      ),
    );
  }



  void _handleUndo(BuildContext context, GameProvider gameProvider) {
    if (!gameProvider.canUndo) return;

    gameProvider.undo();

    // 檢查是否有撤銷訊息
    if (gameProvider.lastUndoMessage != null) {
      _showMessage(context, gameProvider.lastUndoMessage!);
    }
  }

  void _handleErase(BuildContext context, GameProvider gameProvider) {
    if (!gameProvider.hasSelectedCell || gameProvider.isGamePaused) return;

    final cell = gameProvider.selectedCell;
    if (cell == null || cell.isFixed) return;

    // 檢查是否可以擦除
    bool canErase = false;
    String message = '';

    if (cell.notes.isNotEmpty) {
      canErase = true;
      message = '已清除筆記';
    }

    if (cell.value != 0 && gameProvider.currentBoard!.isCellError(
        gameProvider.selectedRow!, gameProvider.selectedCol!)) {
      canErase = true;
      message = '已擦除錯誤數字';
    }

    if (!canErase) {
      _showMessage(context, '只能擦除筆記或填錯的數字');
      return;
    }

    gameProvider.eraseCell();
    _showMessage(context, message, isSuccess: true);
  }

  void _handleRedo(BuildContext context, GameProvider gameProvider) {
    if (!gameProvider.canRedo) return;

    gameProvider.redo();
    _showMessage(context, '已重做操作', isSuccess: true);
  }

  void _showMessage(BuildContext context, String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : null,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
