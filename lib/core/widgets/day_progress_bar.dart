import 'package:flutter/material.dart';
import 'dart:math';

class DayProgressBar extends StatelessWidget {
  final int days;
  final double blockHeight;
  final double spacing;

  const DayProgressBar({
    super.key,
    required this.days,
    this.blockHeight = 8,
    this.spacing = 4,
  });

  Color _getFillColor() {
    if (days <= 14) return Colors.blue;
    
    // 赤橙红绿青蓝紫 (Red, Orange, Amber, Green, Cyan, Blue, Purple)
    const rainbow = [
      Colors.red,
      Colors.orange,
      Colors.amber,
      Colors.green,
      Colors.cyan,
      Colors.blue,
      Colors.purple,
    ];
    
    int excess = days - 14;
    if (excess > rainbow.length) return Colors.purple;
    return rainbow[excess - 1];
  }

  @override
  Widget build(BuildContext context) {
    final fillColor = _getFillColor();
    final filledCount = min(days, 14);

    return LayoutBuilder(
      builder: (context, constraints) {
        // 计算每个小方块的宽度
        final totalSpacing = spacing * 13;
        final blockWidth = (constraints.maxWidth - totalSpacing) / 14;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(14, (index) {
            final isFilled = index < filledCount;
            return Container(
              width: blockWidth,
              height: blockHeight,
              decoration: BoxDecoration(
                color: isFilled ? fillColor : Colors.grey[200],
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        );
      },
    );
  }
}
