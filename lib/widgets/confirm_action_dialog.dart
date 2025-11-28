import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class ConfirmActionDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final Future<void> Function()? onConfirm;
  final Color? confirmColor;

  const ConfirmActionDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = 'Delete',
    this.cancelLabel = 'Cancel',
    this.onConfirm,
    this.confirmColor,
  });

  @override
  Widget build(BuildContext context) {
    final Color defaultConfirmColor =
        confirmColor ?? Theme.of(context).colorScheme.error;

    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(cancelLabel),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: defaultConfirmColor,
            foregroundColor: AppColors.primary,
          ),
          onPressed: () async {
            Navigator.of(context).pop();
            if (onConfirm != null) {
              await onConfirm!();
            }
          },
          child: Text(confirmLabel),
        ),
      ],
    );
  }
}
