import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class TabText extends StatelessWidget {
  final String label;
  final bool active;

  const TabText({
    super.key,
    required this.label,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: active ? FontWeight.w800 : FontWeight.w500,
            color: active ? AppColors.black : AppColors.muted,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 2,
          width: 54,
          color: active ? AppColors.black : Colors.transparent,
        ),
      ],
    );
  }
}