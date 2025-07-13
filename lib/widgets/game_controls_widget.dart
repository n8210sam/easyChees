import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudoku_app/providers/game_provider.dart';

class GameControlsWidget extends StatelessWidget {
  const GameControlsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600; // 手機隱藏中文標題

    // 根據螢幕尺寸調整容器間距 - 適中間距
    EdgeInsets containerPadding;
    if (screenWidth >= 900) {
      containerPadding = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0);
    } else if (screenWidth >= 600) {
      containerPadding = const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0);
    } else {
      containerPadding = const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0);
    }

    return Container(
      padding: containerPadding,
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
              // 計算提示狀態顯示
              final hintsUsed = gameProvider.currentBoard?.hintsUsed ?? 0;
              final hintLimit = gameProvider.hintLimit;
              final hintLabel = isMobile ? '$hintsUsed/$hintLimit' : '提示 $hintsUsed/$hintLimit';
              
              return _buildCompactButton(
                context,
                icon: Icons.lightbulb_outline,
                label: hintLabel,
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
    // 響應式尺寸設計
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600 && screenWidth < 900;
    final isDesktop = screenWidth >= 900;

    // 根據螢幕尺寸調整按鈕尺寸
    double verticalPadding, horizontalPadding, iconSize, fontSize;

    if (isDesktop) {
      verticalPadding = showLabel ? 16.0 : 18.0; // 減少內邊距
      horizontalPadding = showLabel ? 14.0 : 12.0; // 減少內邊距
      iconSize = showLabel ? 28.0 : 30.0; // 減少圖示大小
      fontSize = 12.0; // 減少字體大小
    } else if (isTablet) {
      verticalPadding = showLabel ? 16.0 : 18.0;
      horizontalPadding = showLabel ? 14.0 : 12.0;
      iconSize = showLabel ? 30.0 : 32.0;
      fontSize = 12.0;
    } else {
      // 手機
      verticalPadding = showLabel ? 8.0 : 10.0;
      horizontalPadding = showLabel ? 8.0 : 6.0;
      iconSize = showLabel ? 20.0 : 22.0;
      fontSize = 10.0;
    }

    // 根據螢幕尺寸調整按鈕間距 - 適中間距
    double buttonPadding;
    if (screenWidth >= 900) {
      buttonPadding = 6.0;
    } else if (screenWidth >= 600) {
      buttonPadding = 4.0;
    } else {
      buttonPadding = 2.0;
    }

    // 根據螢幕尺寸設定按鈕尺寸 - 適中矩形按鈕
    double buttonWidth, buttonHeight;
    final isPortrait = MediaQuery.of(context).size.height > screenWidth;

    if (screenWidth >= 900) {
      // 桌面 - 適中矩形按鈕，調整高度避免文字截斷
      buttonHeight = showLabel ? 95.0 : 75.0; // 增加按鈕高度
      buttonWidth = buttonHeight * 1.3; // 調整寬高比
    } else if (screenWidth >= 600) {
      // 平板 - 適中矩形按鈕，直式時縮小避免溢出
      buttonHeight = showLabel ? 80.0 : 65.0;
      buttonWidth = isPortrait
          ? buttonHeight * 1.2  // 直式：寬度增加20%，避免溢出
          : buttonHeight * 1.4; // 橫式：寬度增加40%
    } else {
      // 手機 - 保持原有彈性佈局
      return Flexible(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: buttonPadding),
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
                  vertical: verticalPadding,
                  horizontal: horizontalPadding,
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
                            size: iconSize,
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
                              fontSize: fontSize,
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
                        size: iconSize,
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

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: buttonPadding),
      child: SizedBox(
        width: buttonWidth,
        height: buttonHeight,
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
                vertical: verticalPadding,
                horizontal: horizontalPadding,
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
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            icon,
                            size: iconSize,
                            color: isActive
                                ? Theme.of(context).primaryColor
                                : isEnabled
                                    ? Colors.grey.shade600
                                    : Colors.grey.shade400,
                          ),
                          const SizedBox(height: 4),
                          Flexible(
                            child: Text(
                              label,
                              style: TextStyle(
                                fontSize: fontSize,
                                fontWeight: FontWeight.w500,
                                color: isActive
                                    ? Theme.of(context).primaryColor
                                    : isEnabled
                                        ? Colors.grey.shade600
                                        : Colors.grey.shade400,
                              ),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Center(
                      child: Icon(
                        icon,
                        size: iconSize,
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
