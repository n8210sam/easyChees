import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudoku_app/providers/game_provider.dart';

class GameControlsWidget extends StatelessWidget {
  const GameControlsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTabletOrLarger = screenWidth >= 600; // 平板以上顯示中文

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 筆記
          Consumer<GameProvider>(
            builder: (context, gameProvider, child) {
              return _buildResponsiveButton(
                context,
                icon: Icons.edit_note,
                label: isTabletOrLarger ? '筆記' : null,
                isActive: gameProvider.isNotesMode,
                onTap: gameProvider.toggleNotesMode,
              );
            },
          ),

          // 連續輸入
          Consumer<GameProvider>(
            builder: (context, gameProvider, child) {
              return _buildResponsiveButton(
                context,
                icon: Icons.touch_app,
                label: isTabletOrLarger ? '連續輸入' : null,
                isActive: gameProvider.isContinuousInputEnabled,
                onTap: gameProvider.toggleContinuousInput,
              );
            },
          ),

          // 自動完成
          Consumer<GameProvider>(
            builder: (context, gameProvider, child) {
              return _buildResponsiveButton(
                context,
                icon: Icons.auto_fix_high,
                label: isTabletOrLarger ? '自動完成' : null,
                isActive: false,
                isEnabled: !gameProvider.isGamePaused,
                onTap: () => _showAutoCompleteDialog(context, gameProvider),
              );
            },
          ),

          // 提示
          Consumer<GameProvider>(
            builder: (context, gameProvider, child) {
              return _buildResponsiveButton(
                context,
                icon: Icons.lightbulb_outline,
                label: isTabletOrLarger ? '提示' : null,
                isActive: false,
                onTap: () => _showHintDialog(context, gameProvider),
              );
            },
          ),

          // 撤銷
          Consumer<GameProvider>(
            builder: (context, gameProvider, child) {
              return _buildResponsiveButton(
                context,
                icon: Icons.undo,
                label: isTabletOrLarger ? '撤銷' : null,
                isActive: false,
                isEnabled: gameProvider.canUndo,
                onTap: () => _handleUndo(context, gameProvider),
              );
            },
          ),

          // 重做
          Consumer<GameProvider>(
            builder: (context, gameProvider, child) {
              return _buildResponsiveButton(
                context,
                icon: Icons.redo,
                label: isTabletOrLarger ? '重做' : null,
                isActive: false,
                isEnabled: gameProvider.canRedo,
                onTap: () => _handleRedo(context, gameProvider),
              );
            },
          ),

          // 擦除
          Consumer<GameProvider>(
            builder: (context, gameProvider, child) {
              return _buildResponsiveButton(
                context,
                icon: Icons.backspace_outlined,
                label: isTabletOrLarger ? '擦除' : null,
                isActive: false,
                onTap: () => _handleErase(context, gameProvider),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveButton(
    BuildContext context, {
    required IconData icon,
    String? label, // 可選的標籤
    required bool isActive,
    required VoidCallback onTap,
    bool isEnabled = true,
  }) {
    final hasLabel = label != null && label.isNotEmpty;

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
                vertical: hasLabel ? 8.0 : 12.0,
                horizontal: hasLabel ? 8.0 : 4.0,
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
              child: hasLabel
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
