import 'package:flutter/material.dart';

import '../../../../constants/app_colors.dart';

class PageIndicator extends StatelessWidget {

  final bool active;

  const PageIndicator({
    super.key,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {

    return AnimatedContainer(

      duration: const Duration(milliseconds: 300),

      margin: const EdgeInsets.symmetric(horizontal: 4),

      width: active ? 24 : 8,

      height: 8,

      decoration: BoxDecoration(
        color: active
            ? AppColors.primary
            : Colors.grey.shade400,

        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}