import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class CircleActionButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color fillColor;
  final Color borderColor;
  final double size;
  final double borderWidth;

  const CircleActionButton({
    super.key,
    required this.child,
    this.onPressed,
    this.fillColor = AppColors.transparent,
    this.borderColor = AppColors.white24,
    this.size = 48,
    this.borderWidth = 1.5,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Material(
        color: fillColor,
        shape: CircleBorder(
          side: BorderSide(color: borderColor, width: borderWidth),
        ),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: Center(child: child),
        ),
      ),
    );
  }
}
