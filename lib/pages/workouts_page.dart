import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/workout_data.dart';
import '../settings/app_settings.dart';
import '../theme/app_colors.dart';
import '../utils/navigation_utils.dart';
import '../widgets/app_bottom_nav_bar.dart';
import '../widgets/app_gradient_background.dart';
import '../widgets/confirm_action_dialog.dart';
import '../widgets/workout_list_view.dart';
import '../widgets/triangle_action_button.dart';

class WorkoutsPage extends StatefulWidget {
  const WorkoutsPage({super.key});

  @override
  State<WorkoutsPage> createState() => _WorkoutsPageState();
}

class _WorkoutsPageState extends State<WorkoutsPage> {
  static const double _slidableActionWidth = 108.0;
  static const EdgeInsets _cardPadding =
      EdgeInsets.symmetric(horizontal: 8, vertical: 4);
  static const double _sheetCornerRadius = 24.0;
  static const double _sheetHorizontalPadding = 24.0;
  static const double _sheetBottomSpacing = 24.0;
  static const double _sheetFieldSpacing = 24.0;
  static const String _noDefaultsMessage = 'No workout defaults found.';
  static const String _addWorkoutTitle = 'Add Workout';
  static const String _editWorkoutTitle = 'Edit Workout';
  static const String _workoutTypeLabel = 'Workout Type';
  static const String _workoutLocationLabel = 'Workout Location';
  static const String _saveWorkoutLabel = 'Save Workout';
  static const String _updateWorkoutLabel = 'Update Workout';

  Future<void> _showWorkoutDialog({
    String? workoutId,
    String? currentType,
    String? currentLocation,
  }) async {
    final workoutData = context.read<WorkoutData>();
    final workoutTypes = await workoutData.getDefaultWorkoutTypes();
    final workoutLocations = await workoutData.getDefaultWorkoutLocations();

    if (workoutTypes.isEmpty || workoutLocations.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(_noDefaultsMessage)),
      );
      return;
    }
    if (!mounted) return;

    String? selectedTypeKey = currentType != null
        ? _findKeyForValue(workoutTypes, currentType)
        : null;
    String? selectedLocationKey = currentLocation != null
        ? _findKeyForValue(workoutLocations, currentLocation)
        : null;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(_sheetCornerRadius)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            final double maxMenuHeight =
                MediaQuery.of(sheetContext).size.height * 0.5;
            return Padding(
              padding: EdgeInsets.only(
                bottom:
                    MediaQuery.of(ctx).viewInsets.bottom + _sheetBottomSpacing,
                left: _sheetHorizontalPadding,
                right: _sheetHorizontalPadding,
                top: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    workoutId == null ? _addWorkoutTitle : _editWorkoutTitle,
                    style: Theme.of(sheetContext).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  DropdownMenu<String>(
                    width: double.infinity,
                    menuHeight: maxMenuHeight,
                    initialSelection: selectedTypeKey,
                    label: const Text(_workoutTypeLabel),
                    dropdownMenuEntries: workoutTypes.entries
                        .map((entry) => DropdownMenuEntry<String>(
                              value: entry.key,
                              label: entry.value,
                              enabled: entry.value.isNotEmpty,
                            ))
                        .toList(),
                    onSelected: (String? key) {
                      setSheetState(() => selectedTypeKey = key);
                    },
                  ),
                  const SizedBox(height: _sheetFieldSpacing),
                  DropdownMenu<String>(
                    width: double.infinity,
                    menuHeight: maxMenuHeight,
                    initialSelection: selectedLocationKey,
                    label: const Text(_workoutLocationLabel),
                    dropdownMenuEntries: workoutLocations.entries
                        .map((entry) => DropdownMenuEntry<String>(
                              value: entry.key,
                              label: entry.value,
                              enabled: entry.value.isNotEmpty,
                            ))
                        .toList(),
                    onSelected: (String? key) {
                      setSheetState(() => selectedLocationKey = key);
                    },
                  ),
                  const SizedBox(height: _sheetFieldSpacing),
                  ElevatedButton(
                    onPressed: () async {
                      final navigator = Navigator.of(sheetContext);
                      if (selectedTypeKey == null ||
                          selectedLocationKey == null) {
                        return;
                      }
                      final selectedType = workoutTypes[selectedTypeKey]!;
                      final selectedLocation =
                          workoutLocations[selectedLocationKey]!;
                      if (workoutId == null) {
                        await workoutData.addWorkout(
                          selectedType,
                          selectedLocation,
                        );
                      } else {
                        await workoutData.updateWorkout(
                          workoutId,
                          selectedType,
                          selectedLocation,
                        );
                      }
                      if (!navigator.mounted) return;
                      navigator.pop();
                    },
                    child: Text(
                      workoutId == null
                          ? _saveWorkoutLabel
                          : _updateWorkoutLabel,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String? _findKeyForValue(Map<String, String> values, String value) {
    try {
      return values.entries.firstWhere((entry) => entry.value == value).key;
    } catch (_) {
      return null;
    }
  }

  void _deleteWorkout(String workoutId) {
    final workoutData = context.read<WorkoutData>();
    showDialog(
      context: context,
      builder: (ctx) => ConfirmActionDialog(
        title: 'Delete Workout',
        message:
            'Are you sure you want to delete this workout and all its data?',
        onConfirm: () => workoutData.deleteWorkout(workoutId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final workoutData = context.read<WorkoutData>();
    final settings = context.watch<AppSettings>();
    final dateFormat = settings.workoutDateFormat;

    return Scaffold(
      floatingActionButton: _AddWorkoutButton(onPressed: _showWorkoutDialog),
      bottomNavigationBar: AppBottomNavBar(
        current: AppNavDestination.workouts,
        onNavigate: (destination) =>
            NavigationUtils.handleBottomNav(context, destination),
      ),
      body: AppGradientBackground(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: Text(
                'Workouts',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Expanded(
              child: WorkoutListView(
                stream: workoutData.getWorkoutsStream(),
                dateFormat: dateFormat,
                onWorkoutTap: (workout) =>
                    NavigationUtils.openWorkoutDetails(context, workout),
                onEditWorkout: (id, type, location) => _showWorkoutDialog(
                  workoutId: id,
                  currentType: type,
                  currentLocation: location,
                ),
                onDeleteWorkout: _deleteWorkout,
                cardPadding: _cardPadding,
                slidableActionWidth: _slidableActionWidth,
                emptyMessage: 'No workouts yet.',
                groupTag: 'workouts',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddWorkoutButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _AddWorkoutButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TriangleActionButton(
      size: 72,
      fillColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
      borderColor: AppColors.primary.withValues(alpha: 0.4),
      borderWidth: 1.0,
      onPressed: onPressed,
      child: const Icon(Icons.add, color: AppColors.primary),
    );
  }
}
