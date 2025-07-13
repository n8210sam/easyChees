import 'package:flutter/material.dart';

class NumberInputWidget extends StatelessWidget {
  final Function(int) onNumberTap;
  final Function(int)? onNumberLongPress;
  final VoidCallback onDeleteTap;
  final bool isNotesMode;
  final int? lastSelectedNumber;
  final Map<int, int> numberCounts;

  const NumberInputWidget({
    super.key,
    required this.onNumberTap,
    this.onNumberLongPress,
    required this.onDeleteTap,
    required this.isNotesMode,
    this.lastSelectedNumber,
    required this.numberCounts,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isPortrait = screenSize.height > screenSize.width;

    if (isPortrait) {
      // 直式畫面：分為兩行
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          children: [
            // 第一行：數字 1-5
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(5, (index) {
                final number = index + 1;
                return _buildNumberButton(context, number);
              }),
            ),
            const SizedBox(height: 8),
            // 第二行：數字 6-9 + 刪除鍵
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ...List.generate(4, (index) {
                  final number = index + 6;
                  return _buildNumberButton(context, number);
                }),
                _buildDeleteButton(context),
              ],
            ),
          ],
        ),
      );
    } else {
      // 橫式畫面：單行顯示
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Numbers 1-9
            ...List.generate(9, (index) {
              final number = index + 1;
              return _buildNumberButton(context, number);
            }),

            // Delete button
            _buildDeleteButton(context),
          ],
        ),
      );
    }
  }

  Widget _buildNumberButton(BuildContext context, int number) {
    final isLastSelected = lastSelectedNumber == number;
    final remainingCount = numberCounts[number] ?? 0;
    final isCompleted = remainingCount == 0;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2.0),
        child: AspectRatio(
          aspectRatio: 1.0,
          child: GestureDetector(
            onTap: () => onNumberTap(number),
            onLongPress: onNumberLongPress != null
                ? () => onNumberLongPress!(number)
                : null,
            child: Container(
              decoration: BoxDecoration(
                color: isLastSelected
                    ? Theme.of(context).primaryColor
                    : isNotesMode
                        ? Colors.orange.shade100
                        : Theme.of(context).primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isLastSelected
                      ? Theme.of(context).primaryColor
                      : isNotesMode
                          ? Colors.orange.shade300
                          : Theme.of(context).primaryColor.withValues(alpha: 0.3),
                  width: isLastSelected ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: isLastSelected ? 4 : 2,
                    offset: Offset(0, isLastSelected ? 2 : 1),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    number.toString(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: isLastSelected ? FontWeight.bold : FontWeight.w600,
                      color: isLastSelected
                          ? Colors.white
                          : isCompleted
                              ? Colors.green.shade600
                              : isNotesMode
                                  ? Colors.orange.shade700
                                  : Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '($remainingCount)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isLastSelected
                          ? Colors.white.withValues(alpha: 0.8)
                          : isCompleted
                              ? Colors.green.shade600
                              : isNotesMode
                                  ? Colors.orange.shade600
                                  : Theme.of(context).primaryColor.withValues(alpha: 0.7),
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

  Widget _buildDeleteButton(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2.0),
        child: AspectRatio(
          aspectRatio: 1.0,
          child: ElevatedButton(
            onPressed: onDeleteTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade50,
              foregroundColor: Colors.red.shade700,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: Colors.red.shade200,
                  width: 1,
                ),
              ),
              padding: EdgeInsets.zero,
            ),
            child: const Icon(
              Icons.backspace_outlined,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}
