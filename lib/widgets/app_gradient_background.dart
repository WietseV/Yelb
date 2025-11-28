import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../settings/app_settings.dart';
import '../theme/app_colors.dart';

class AppGradientBackground extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool includeSafeArea;

  const AppGradientBackground({
    super.key,
    required this.child,
    this.padding,
    this.includeSafeArea = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = padding != null ? Padding(padding: padding!, child: child) : child;

    if (includeSafeArea) {
      content = SafeArea(child: content);
    }

    final accentColor = context.watch<AppSettings>().accentColor;

    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.backgroundGradient(accentColor),
      ),
      child: content,
    );
  }
}
