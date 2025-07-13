import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudoku_app/providers/game_provider.dart';

class GameControlsWidget extends StatelessWidget {
  const GameControlsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600; // 手機隱藏中文標題

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 筆記
          Consumer<GameProvider>(
            builder: (context, gameProvider, child) {
              return _buildCompactButton(
                context,
                icon: Icons.edit_note,
                label: '筆記',
                showLabel: !isMobile,
                isActive: gameProvider.isNotesMode,
                onTap: gameProvider.toggleNotesMode,
              );
            },
          ),

          // 連續輸入
          Consumer<GameProvider>(
            builder: (context, gameProvider, child) {
              return _buildCompactButton(
                context,
                icon: Icons.touch_app,
                label: '連續輸入',
                showLabel: !isMobile,
                isActive: gameProvider.isContinuousInputEnabled,
                onTap: gameProvider.toggleContinuousInput,
              );
            },
          ),

          // 自動完成
          Consumer<GameProvider>(
            builder: (context, gameProvider, child) {
              return _buildCompactButton(
                context,
                icon: Icons.auto_fix_high,
                label: '自動完成',
                showLabel: !isMobile,
                isActive: false,
                isEnabled: !gameProvider.isGamePaused,
                onTap: () => _showAutoCompleteDialog(context, gameProvider),
              );
            },
          ),

          // 提示
          Consumer<GameProvider>(
            builder: (context, gameProvider, child) {
              return _buildCompactButton(
                context,
                icon: Icons.lightbulb_outline,
                label: '提示',
                showLabel: !isMobile,
                isActive: false,
                onTap: () => _showHintDialog(context, gameProvider),
              );
            },
          ),

          // 撤銷
          Consumer<GameProvider>(
            builder: (context, gameProvider, child) {
              return _buildCompactButton(
                context,
                icon: Icons.undo,
                label: '撤銷',
                showLabel: !isMobile,
                isActive: false,
                isEnabled: gameProvider.canUndo,
                onTap: () => _handleUndo(context, gameProvider),
              );
            },
          ),

          // 重做
          Consumer<GameProvider>(
            builder: (context, gameProvider, child) {
              return _buildCompactButton(
                context,
                icon: Icons.redo,
                label: '重做',
                showLabel: !isMobile,
                isActive: false,
                isEnabled: gameProvider.canRedo,
                onTap: () => _handleRedo(context, gameProvider),
              );
            },
          ),


        ],
      ),
    );
  }

  Widget _buildCompactButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool showLabel, // 是否顯示標籤
    required bool isActive,
    required VoidCallback onTap,
    bool isEnabled = true,
  }) {

    return Flexible(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2.0),
        child: Material(
          color: isActive
              ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            onTap: isEnabled ? onTap : null,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: EdgeInsets.symmetric(
                vertical: showLabel ? 8.0 : 12.0,
                horizontal: showLabel ? 8.0 : 4.0,
              ),
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
              child: showLabel
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          icon,
                          size: 20,
                          color: isActive
                              ? Theme.of(context).primaryColor
                              : isEnabled
                                  ? Colors.grey.shade600
                                  : Colors.grey.shade400,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: isActive
                                ? Theme.of(context).primaryColor
                                : isEnabled
                                    ? Colors.grey.shade600
                                    : Colors.grey.shade400,
                          ),
                        ),
                      ],
                    )
                  : Icon(
                      icon,
                      size: 24,
                      color: isActive
                          ? Theme.of(context).primaryColor
                          : isEnabled
                              ? Colors.grey.shade600
                              : Colors.grey.shade400,
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

  void _showAutoCompleteDialog(BuildContext context, GameProvider gameProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('自動完成'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('自動填入盤面上直行、橫列、宮格內只剩1格的空格。'),
            SizedBox(height: 8),
            Text(
              '注意：此操作不可復原，也不會列入操作記錄。',
              style: TextStyle(
                fontSize: 14,
                color: Colors.orange,
                fontWeight: FontWeight.w500,
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
              gameProvider.autoComplete();
              _showMessage(context, '自動完成已執行', isSuccess: true);
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
