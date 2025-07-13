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
      // 直式畫面：分為兩行 - 緊湊設計
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Column(
          children: [
            // 第一行：數字 1-5
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(5, (index) {
                  final number = index + 1;
                  return _buildCompactNumberButton(context, number);
                }),
              ),
            ),
            const SizedBox(height: 4),
            // 第二行：數字 6-9 + 刪除鍵
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ...List.generate(4, (index) {
                    final number = index + 6;
                    return _buildCompactNumberButton(context, number);
                  }),
                  _buildCompactDeleteButton(context),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      // 橫式畫面：單行顯示 - 緊湊設計
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Numbers 1-9
            ...List.generate(9, (index) {
              final number = index + 1;
              return _buildCompactNumberButton(context, number);
            }),

            // Delete button
            _buildCompactDeleteButton(context),
          ],
        ),
      );
    }
  }



  // 緊湊版本的數字按鈕
  Widget _buildCompactNumberButton(BuildContext context, int number) {
    final isLastSelected = lastSelectedNumber == number;
    final remainingCount = numberCounts[number] ?? 0;
    final isCompleted = remainingCount == 0;
    final screenWidth = MediaQuery.of(context).size.width;
    final isPortrait = MediaQuery.of(context).size.height > screenWidth;

    // 根據螢幕方向和尺寸調整按鈕尺寸 - 矩形按鈕（寬度加倍）
    double buttonWidth, buttonHeight, fontSize;

    if (screenWidth >= 900) {
      // 桌面 - 適中矩形按鈕
      buttonHeight = isPortrait ? 80.0 : 70.0;
      buttonWidth = buttonHeight * 1.5; // 寬度增加50%
      fontSize = isPortrait ? 24.0 : 22.0;
    } else if (screenWidth >= 600) {
      // 平板 - 適中矩形按鈕
      buttonHeight = isPortrait ? 75.0 : 65.0;
      buttonWidth = buttonHeight * 1.4; // 寬度增加40%
      fontSize = isPortrait ? 23.0 : 21.0;
    } else {
      // 手機 - 保持正方形
      buttonHeight = isPortrait ? 45.0 : 38.0;
      buttonWidth = buttonHeight;
      fontSize = isPortrait ? 18.0 : 16.0;
    }

    // 根據螢幕尺寸調整間距 - 適中間距
    final horizontalPadding = screenWidth >= 900 ? 6.0 : (screenWidth >= 600 ? 5.0 : 2.0);

    return Flexible(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: SizedBox(
          width: buttonWidth,
          height: buttonHeight,
          child: Material(
            color: isLastSelected
                ? Theme.of(context).primaryColor.withValues(alpha: 0.2)
                : (isCompleted
                    ? Colors.grey.shade100
                    : (isNotesMode
                        ? Colors.yellow.shade50  // 筆記模式淡黃底色
                        : Colors.white)),
            borderRadius: BorderRadius.circular(6),
            child: InkWell(
              onTap: isCompleted ? null : () => onNumberTap(number),
              onLongPress: isCompleted ? null : () => onNumberLongPress?.call(number),
              borderRadius: BorderRadius.circular(6),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isLastSelected
                        ? Theme.of(context).primaryColor
                        : (isCompleted
                            ? Colors.grey.shade300
                            : Colors.grey.shade400),
                    width: isLastSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Text(
                        number.toString(),
                        style: TextStyle(
                          fontSize: fontSize,
                          fontWeight: FontWeight.bold,
                          color: isCompleted
                              ? Colors.grey.shade400
                              : (isLastSelected
                                  ? Theme.of(context).primaryColor
                                  : Colors.black87),
                        ),
                      ),
                    ),
                    if (remainingCount < 9)
                      Positioned(
                        top: 1,
                        right: 2,
                        child: Container(
                          padding: const EdgeInsets.all(1),
                          decoration: BoxDecoration(
                            color: isCompleted
                                ? Colors.grey.shade400
                                : Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 12,
                            minHeight: 12,
                          ),
                          child: Text(
                            remainingCount.toString(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: screenWidth >= 900 ? 12.0 : (screenWidth >= 600 ? 11.0 : 10.0),
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 緊湊版本的刪除按鈕
  Widget _buildCompactDeleteButton(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isPortrait = MediaQuery.of(context).size.height > screenWidth;

    // 根據螢幕方向和尺寸調整按鈕尺寸 - 矩形按鈕（寬度加倍）
    double buttonWidth, buttonHeight, iconSize;

    if (screenWidth >= 900) {
      // 桌面 - 適中矩形按鈕
      buttonHeight = isPortrait ? 80.0 : 70.0;
      buttonWidth = buttonHeight * 1.5; // 寬度增加50%
      iconSize = isPortrait ? 26.0 : 24.0;
    } else if (screenWidth >= 600) {
      // 平板 - 適中矩形按鈕
      buttonHeight = isPortrait ? 75.0 : 65.0;
      buttonWidth = buttonHeight * 1.4; // 寬度增加40%
      iconSize = isPortrait ? 25.0 : 23.0;
    } else {
      // 手機 - 保持正方形
      buttonHeight = isPortrait ? 45.0 : 38.0;
      buttonWidth = buttonHeight;
      iconSize = isPortrait ? 20.0 : 18.0;
    }

    // 根據螢幕尺寸調整間距 - 適中間距
    final horizontalPadding = screenWidth >= 900 ? 6.0 : (screenWidth >= 600 ? 5.0 : 2.0);

    return Flexible(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: SizedBox(
          width: buttonWidth,
          height: buttonHeight,
          child: Material(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(6),
            child: InkWell(
              onTap: onDeleteTap,
              borderRadius: BorderRadius.circular(6),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.red.shade300,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.backspace_outlined,
                  size: iconSize,
                  color: Colors.red.shade600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
