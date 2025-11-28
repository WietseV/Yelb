import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../theme/app_colors.dart';
import 'circle_action_button.dart';

ActionPane buildSlidableActionPane(
  BuildContext context, {
  required double extentRatio,
  required VoidCallback onEdit,
  required VoidCallback onDelete,
  double buttonSize = 48,
}) {
  final colorScheme = Theme.of(context).colorScheme;

  return ActionPane(
    motion: const ScrollMotion(),
    extentRatio: extentRatio,
    children: [
      Padding(
        padding: const EdgeInsets.only(right: 4),
        child: CircleActionButton(
          size: buttonSize,
          fillColor: colorScheme.primaryContainer,
          borderColor: AppColors.transparent,
          onPressed: onEdit,
          child: Icon(
            Icons.edit,
            color: colorScheme.onPrimaryContainer,
          ),
        ),
      ),
      CircleActionButton(
        size: buttonSize,
        fillColor: colorScheme.error,
        borderColor: AppColors.transparent,
        onPressed: onDelete,
        child: Icon(
          Icons.delete,
          color: colorScheme.onError,
        ),
      ),
    ],
  );
}
