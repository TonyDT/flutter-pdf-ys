import 'package:flutter/material.dart';
import 'dart:math';
import '../constants/app_colors.dart';

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
    if (days <= 14) return AppColors.primary;
    
    int excess = days - 14;
    // 赤橙红绿青蓝紫
    if (excess > AppColors.rainbow.length) return AppColors.rainbow.last;
    return AppColors.rainbow[excess - 1];
  }

  @override
  Widget build(BuildContext context) {
    final fillColor = _getFillColor();
    final filledCount = min(days, 14);

    return LayoutBuilder(
      builder: (context, constraints) {
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
                color: isFilled ? fillColor : Colors.grey[100],
                borderRadius: BorderRadius.circular(4), // Slightly more rounded
              ),
            );
          }),
        );
      },
    );
  }
}
