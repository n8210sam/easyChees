import 'package:flutter/material.dart';
import 'package:sudoku_app/models/sudoku_board.dart';
import 'package:sudoku_app/models/sudoku_cell.dart';
import 'package:sudoku_app/utils/theme.dart';

class SudokuBoardWidget extends StatelessWidget {
  final SudokuBoard board;
  final int? selectedRow;
  final int? selectedCol;
  final int? highlightedNumber;
  final int? lastSelectedNumber;
  final Function(int row, int col) onCellTap;
  final Function(int row, int col)? onCellLongPress;
  final bool Function(int number)? isNumberCompleted;

  const SudokuBoardWidget({
    super.key,
    required this.board,
    this.selectedRow,
    this.selectedCol,
    this.highlightedNumber,
    this.lastSelectedNumber,
    required this.onCellTap,
    this.onCellLongPress,
    this.isNumberCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: AppTheme.cellBorderThick,
          width: 3,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: List.generate(SudokuBoard.size, (row) {
          return Expanded(
            child: Row(
              children: List.generate(SudokuBoard.size, (col) {
                return Expanded(
                  child: _buildCell(context, row, col),
                );
              }),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCell(BuildContext context, int row, int col) {
    final cell = board.getCell(row, col);
    final isSelected = selectedRow == row && selectedCol == col;

    return GestureDetector(
      onTap: () => onCellTap(row, col),
      onLongPress: onCellLongPress != null
          ? () => onCellLongPress!(row, col)
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: _getCellBackgroundColor(cell, isSelected, row, col),
          border: Border(
            right: BorderSide(
              color: (col + 1) % 3 == 0 && col != 8
                  ? AppTheme.cellBorderThick
                  : AppTheme.cellBorder,
              width: (col + 1) % 3 == 0 && col != 8 ? 2 : 1,
            ),
            bottom: BorderSide(
              color: (row + 1) % 3 == 0 && row != 8
                  ? AppTheme.cellBorderThick
                  : AppTheme.cellBorder,
              width: (row + 1) % 3 == 0 && row != 8 ? 2 : 1,
            ),
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Center(
          child: _buildCellContent(context, cell, row, col),
        ),
      ),
    );
  }

  Widget _buildCellContent(BuildContext context, SudokuCell cell, int row, int col) {
    final isError = board.isCellError(row, col);

    if (cell.value != 0) {
      // 有數值時顯示數值
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return ScaleTransition(
            scale: animation,
            child: child,
          );
        },
        child: Text(
          _getCellDisplayText(cell, row, col),
          key: ValueKey(cell.value),
          style: TextStyle(
            fontSize: 24,
            fontWeight: cell.isFixed ? FontWeight.bold : FontWeight.w500,
            color: _getCellTextColor(context, cell, row, col),
          ),
        ),
      );
    } else if (cell.notes.isNotEmpty) {
      // 沒有數值時顯示筆記
      // 填錯時筆記隱藏，清除後筆記重現
      return _buildNotesGrid(context, cell.notes);
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _buildNotesGrid(BuildContext context, Set<int> notes) {
    return Padding(
      padding: const EdgeInsets.all(1.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // 計算每個筆記格子的尺寸
          final cellSize = (constraints.maxWidth - 4) / 3; // 3x3網格，減去間距
          final fontSize = cellSize * 0.6; // 字型大小為格子尺寸的60%

          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(3, (row) {
              return Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(3, (col) {
                    final number = row * 3 + col + 1; // 1-9的數字
                    final isHighlighted = highlightedNumber != null &&
                                          highlightedNumber == number &&
                                          notes.contains(number);

                    return Expanded(
                      child: Container(
                        margin: const EdgeInsets.all(0.5),
                        child: Center(
                          child: Text(
                            notes.contains(number) ? _getNoteDisplayText(number, isHighlighted) : '',
                            style: TextStyle(
                              fontSize: fontSize.clamp(8.0, 14.0), // 限制字型大小範圍
                              color: notes.contains(number) ? _getNoteTextColor(context, number) : Colors.transparent,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              );
            }),
          );
        },
      ),
    );
  }

  String _getNoteDisplayText(int number, bool isHighlighted) {
    if (isHighlighted) {
      // 醒目筆記數字：使用圓圈數字
      const circleNumbers = ['⓿', '❶', '❷', '❸', '❹', '❺', '❻', '❼', '❽', '❾'];
      return circleNumbers[number];
    }
    // 普通筆記數字
    return number.toString();
  }

  Color _getNoteTextColor(BuildContext context, int number) {
    // 如果數字鍵被選中且匹配筆記數字，使用藍色
    if (lastSelectedNumber != null && lastSelectedNumber == number) {
      return Theme.of(context).primaryColor;
    }
    // 預設灰色
    return Colors.grey;
  }

  Color _getCellBackgroundColor(SudokuCell cell, bool isSelected, int row, int col) {
    if (board.isCellError(row, col)) {
      return AppTheme.cellError;
    }

    if (isSelected) {
      return AppTheme.cellSelected;
    }

    if (cell.isHighlighted) {
      return AppTheme.cellHighlight;
    }

    if (cell.isFixed) {
      return AppTheme.cellFixed;
    }

    return Colors.white;
  }

  Color _getCellTextColor(BuildContext context, SudokuCell cell, int row, int col) {
    // 如果格子有錯誤，顯示紅色文字
    if (board.isCellError(row, col)) {
      return Colors.red;
    }

    // 如果數字已完成，顯示綠色（優先級最高）
    if (cell.value != 0 && isNumberCompleted != null && isNumberCompleted!(cell.value)) {
      return Colors.green[700]!;
    }

    // 如果是固定格子（題目給定），顯示黑色
    if (cell.isFixed) {
      return Colors.black87;
    }

    // 用戶填入的正確數字，顯示主題色
    return Theme.of(context).primaryColor;
  }

  String _getCellDisplayText(SudokuCell cell, int row, int col) {
    if (cell.value == 0) return '';

    // 如果數字已完成，顯示普通數字（綠色效果優先級高於醒目效果）
    if (isNumberCompleted != null && isNumberCompleted!(cell.value)) {
      return cell.value.toString();
    }

    // 醒目數字：如果格子的數字與醒目數字相同且不是錯誤，顯示圓圈數字
    if (highlightedNumber != null &&
        cell.value == highlightedNumber &&
        !board.isCellError(row, col)) {
      const circleNumbers = ['⓿', '❶', '❷', '❸', '❹', '❺', '❻', '❼', '❽', '❾'];
      return circleNumbers[cell.value];
    }

    // 普通數字
    return cell.value.toString();
  }
}
