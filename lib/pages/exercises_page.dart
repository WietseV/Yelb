import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../data/workout_data.dart';
import '../utils/navigation_utils.dart';
import '../settings/app_settings.dart';
import '../widgets/app_gradient_background.dart';
import '../widgets/app_bottom_nav_bar.dart';
import '../widgets/confirm_action_dialog.dart';
import '../widgets/slidable_action_pane.dart';
import '../theme/app_colors.dart';
import '../widgets/circle_action_button.dart';
import '../widgets/triangle_action_button.dart';

class WorkoutPage extends StatefulWidget {
  final String workoutId;
  final String workoutType;
  final String workoutDescription;

  const WorkoutPage({
    super.key,
    required this.workoutId,
    required this.workoutType,
    required this.workoutDescription,
  });

  @override
  State<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
  static const double _slidableActionWidth = 108.0;
  static const EdgeInsets _exerciseCardPadding =
      EdgeInsets.symmetric(horizontal: 8, vertical: 4);
  static const double _sheetCornerRadius = 24.0;
  static const double _sheetBottomSpacing = 24.0;
  static const double _sheetFieldSpacing = 24.0;
  static const double _setActionSpacing = 8.0;
  static const double _bodyWeightFallback = 69.0;
  static const String _noExercisesText = 'Add an exercise';
  static const String _descriptionHint = 'Add notes or goals for this workout';
  static const String _addExerciseTitle = 'Add Exercise';
  static const String _editExerciseTitle = 'Edit Exercise';
  static const String _exerciseNameLabel = 'Exercise Name';
  static const String _exerciseTypeLabel = 'Exercise Type';
  static const String _noDefaultsMessage = 'No exercise defaults found.';
  static const String _saveExerciseLabel = 'Save Exercise';
  static const String _updateExerciseLabel = 'Update Exercise';
  static const String _noSetsText = 'No sets yet.';
  static const String _addSetLabel = 'Add Set';

  late final TextEditingController _descriptionController;
  late final FocusNode _descriptionFocusNode;
  bool _isSavingDescription = false;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController();
    _descriptionFocusNode = FocusNode();
    _loadDescription();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _descriptionFocusNode.dispose();
    super.dispose();
  }

  // ADD/EDIT EXERCISE ----------------------

  Future<void> _showExerciseDialog(
      {String? exerciseId, String? currentName, String? currentType}) async {
    final workoutData = context.read<WorkoutData>();
    final exerciseTypes = await workoutData.getDefaultExerciseTypes();
    final weightTypes = await workoutData.getDefaultWeightTypes();

    if (exerciseTypes.isEmpty || weightTypes.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(_noDefaultsMessage)),
        );
      }
      return;
    }
    if (!mounted) return;

    String? selectedNameKey = currentName != null
        ? _findKeyForValue(exerciseTypes, currentName)
        : null;
    String? selectedTypeKey =
        currentType != null ? _findKeyForValue(weightTypes, currentType) : null;

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
                left: 24,
                right: 24,
                top: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    exerciseId == null ? _addExerciseTitle : _editExerciseTitle,
                    style: Theme.of(sheetContext).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  DropdownMenu<String>(
                    width: double.infinity,
                    menuHeight: maxMenuHeight,
                    initialSelection: selectedNameKey,
                    label: const Text(_exerciseNameLabel),
                    dropdownMenuEntries: exerciseTypes.entries
                        .map((entry) => DropdownMenuEntry<String>(
                              value: entry.key,
                              label: entry.value,
                              enabled: entry.value.isNotEmpty,
                            ))
                        .toList(),
                    onSelected: (String? key) {
                      setSheetState(() => selectedNameKey = key);
                    },
                  ),
                  const SizedBox(height: _sheetFieldSpacing),
                  DropdownMenu<String>(
                    width: double.infinity,
                    menuHeight: maxMenuHeight,
                    initialSelection: selectedTypeKey,
                    label: const Text(_exerciseTypeLabel),
                    dropdownMenuEntries: weightTypes.entries
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
                  ElevatedButton(
                    onPressed: () async {
                      final navigator = Navigator.of(sheetContext);
                      if (selectedNameKey == null || selectedTypeKey == null) {
                        return;
                      }
                      final selectedName = exerciseTypes[selectedNameKey]!;
                      final selectedType = weightTypes[selectedTypeKey]!;
                      if (exerciseId == null) {
                        await workoutData.addExercise(
                          widget.workoutId,
                          selectedName,
                          selectedType,
                        );
                      } else {
                        await workoutData.updateExercise(
                          widget.workoutId,
                          exerciseId,
                          selectedName,
                          selectedType,
                        );
                      }
                      if (!navigator.mounted) return;
                      navigator.pop();
                    },
                    child: Text(exerciseId == null
                        ? _saveExerciseLabel
                        : _updateExerciseLabel),
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

  // DELETE EXERCISE ----------------------

  void _deleteExercise(String exerciseId) {
    showDialog(
      context: context,
      builder: (ctx) => ConfirmActionDialog(
        title: 'Delete Exercise',
        message:
            'Are you sure you want to delete this exercise and all its sets?',
        onConfirm: () async {
          await context
              .read<WorkoutData>()
              .deleteExercise(widget.workoutId, exerciseId);
        },
      ),
    );
  }

  // SLIDE-UP ADD/EDIT SET ----------------------

  void _showAddOrEditSetSheet(
      String exerciseId, String exerciseName, String exerciseType,
      {String? setId, int? currentReps, double? currentWeight}) async {
    final appSettings = context.read<AppSettings>();
    int selectedReps = currentReps ?? 8;
    double selectedWeight = currentWeight != null
        ? appSettings.convertStorageToDisplay(currentWeight)
        : 0.0;

    final workoutData = context.read<WorkoutData>();
    if (setId == null && currentReps == null && currentWeight == null) {
      final last = await workoutData.getLastSet(widget.workoutId, exerciseId);
      if (last != null) {
        selectedReps = last['reps'] as int;
        selectedWeight = appSettings
            .convertStorageToDisplay((last['weight'] as num).toDouble());
      }
    }

    if (!mounted) return;

    final repsController = PageController(
      initialPage: (selectedReps - 1).clamp(0, 19),
      viewportFraction: 0.22,
    );
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (sheetContext, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
                left: 24,
                right: 24,
                top: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "${setId == null ? "Add" : "Edit"} Set for $exerciseName",
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Text("Reps",
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  SizedBox(
                    height: 70,
                    child: PageView.builder(
                      controller: repsController,
                      scrollDirection: Axis.horizontal,
                      itemCount: 20,
                      onPageChanged: (value) =>
                          setState(() => selectedReps = value + 1),
                      itemBuilder: (context, index) {
                        final isSelected = index + 1 == selectedReps;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          alignment: Alignment.center,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.blueGreyLight
                                : AppColors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "${index + 1}",
                            style: TextStyle(
                              fontSize: isSelected ? 20 : 16,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: isSelected
                                  ? AppColors.blueGreyDark
                                  : AppColors.blueGreyMid,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  if (exerciseType != "Bodyweight") ...[
                    const SizedBox(height: 12),
                    Text("Weight (${appSettings.weightUnitLabel})",
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: _buildWeightAdjustmentButtons(
                            sheetContext,
                            steps: appSettings.weightSteps,
                            increase: false,
                            onAdjust: (step) {
                              setState(() {
                                selectedWeight = (selectedWeight - step)
                                    .clamp(0, double.infinity);
                              });
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${selectedWeight.toStringAsFixed(2)} ${appSettings.weightUnitLabel}',
                                style: Theme.of(sheetContext)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: _buildWeightAdjustmentButtons(
                            sheetContext,
                            steps: appSettings.weightSteps,
                            increase: true,
                            onAdjust: (step) {
                              setState(() {
                                selectedWeight = selectedWeight + step;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blueGrey700,
                      foregroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      minimumSize: const Size.fromHeight(45),
                    ),
                    onPressed: () async {
                      final navigator = Navigator.of(sheetContext);
                      final convertedWeight = exerciseType == "Bodyweight"
                          ? _bodyWeightFallback
                          : appSettings.convertDisplayToStorage(selectedWeight);
                      if (setId == null) {
                        await workoutData.addSet(
                          widget.workoutId,
                          exerciseId,
                          selectedReps,
                          convertedWeight,
                        );
                      } else {
                        await workoutData.updateSet(
                          widget.workoutId,
                          exerciseId,
                          setId,
                          selectedReps,
                          convertedWeight,
                        );
                      }
                      if (!navigator.mounted) return;
                      navigator.pop();
                    },
                    child: Text(setId == null ? "Save Set" : "Update Set"),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // DELETE SET ----------------------

  void _deleteSet(String exerciseId, String setId) {
    showDialog(
      context: context,
      builder: (ctx) => ConfirmActionDialog(
        title: 'Delete Set',
        message: 'Are you sure you want to delete this set?',
        onConfirm: () => context
            .read<WorkoutData>()
            .deleteSet(widget.workoutId, exerciseId, setId),
      ),
    );
  }

  // BUILD UI ----------------------

  @override
  Widget build(BuildContext context) {
    final appSettings = context.watch<AppSettings>();
    return Scaffold(
      floatingActionButton: TriangleActionButton(
        size: 72,
        fillColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
        borderColor: AppColors.primary.withValues(alpha: 0.4),
        borderWidth: 1.0,
        onPressed: () => _showExerciseDialog(),
        child: const Icon(Icons.add, color: AppColors.primary),
      ),
      bottomNavigationBar: AppBottomNavBar(
        current: null,
        onNavigate: (destination) =>
            NavigationUtils.handleBottomNav(context, destination),
      ),
      body: AppGradientBackground(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DescriptionSection(
              title: 'Description',
              controller: _descriptionController,
              focusNode: _descriptionFocusNode,
              isSaving: _isSavingDescription,
              onSave: _saveDescription,
              hint: _descriptionHint,
            ),
            Expanded(
              child: _ExercisesSection(
                workoutData: context.read<WorkoutData>(),
                workoutId: widget.workoutId,
                exerciseCardPadding: _exerciseCardPadding,
                slidableActionWidth: _slidableActionWidth,
                setActionSpacing: _setActionSpacing,
                emptyMessage: _noExercisesText,
                noSetsMessage: _noSetsText,
                addSetLabel: _addSetLabel,
                onEditExercise: ({exerciseId, currentName, currentType}) =>
                    _showExerciseDialog(
                  exerciseId: exerciseId,
                  currentName: currentName,
                  currentType: currentType,
                ),
                onDeleteExercise: _deleteExercise,
                onManageSet: _showAddOrEditSetSheet,
                onDeleteSet: _deleteSet,
                settings: appSettings,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadDescription() async {
    final workoutData = context.read<WorkoutData>();
    final description =
        await workoutData.getWorkoutDescription(widget.workoutId);
    if (!mounted) return;
    _descriptionController.text = description;
  }

  Future<void> _saveDescription() async {
    if (_isSavingDescription) return;
    setState(() => _isSavingDescription = true);
    try {
      await context.read<WorkoutData>().updateWorkoutDescription(
          widget.workoutId, _descriptionController.text);
      _descriptionFocusNode.unfocus();
    } finally {
      if (mounted) {
        setState(() => _isSavingDescription = false);
      }
    }
  }

  Widget _buildWeightAdjustmentButtons(
    BuildContext context, {
    required bool increase,
    required ValueChanged<double> onAdjust,
    required List<double> steps,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final baseColor = increase ? colorScheme.primary : colorScheme.secondary;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: steps.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        final step = steps[index];
        final label = "${increase ? '+' : '-'}${_formatWeightStep(step)}";
        return Center(
          child: CircleActionButton(
            size: 56,
            fillColor: baseColor.withValues(alpha: 0.12),
            borderColor: baseColor.withValues(alpha: 0.5),
            onPressed: () => onAdjust(step),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                      color: baseColor,
                      fontWeight: FontWeight.w600,
                    ) ??
                    TextStyle(
                      color: baseColor,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatWeightStep(double step) {
    return step % 1 == 0 ? step.toStringAsFixed(0) : step.toStringAsFixed(2);
  }
}

class _DescriptionSection extends StatelessWidget {
  final String title;
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isSaving;
  final VoidCallback onSave;
  final String hint;

  const _DescriptionSection({
    required this.title,
    required this.controller,
    required this.focusNode,
    required this.isSaving,
    required this.onSave,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          TextField(
            controller: controller,
            focusNode: focusNode,
            maxLines: 3,
            minLines: 1,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: AppColors.secondary.withValues(alpha: 0.4),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              suffixIcon: isSaving
                  ? const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : IconButton(
                      icon: const Icon(Icons.save),
                      onPressed: onSave,
                    ),
            ),
            onSubmitted: (_) => onSave(),
            onTapOutside: (_) => focusNode.unfocus(),
          ),
        ],
      ),
    );
  }
}

class _ExercisesSection extends StatelessWidget {
  final WorkoutData workoutData;
  final String workoutId;
  final EdgeInsets exerciseCardPadding;
  final double slidableActionWidth;
  final double setActionSpacing;
  final String emptyMessage;
  final String noSetsMessage;
  final String addSetLabel;
  final Future<void> Function({
    String? exerciseId,
    String? currentName,
    String? currentType,
  }) onEditExercise;
  final void Function(String exerciseId) onDeleteExercise;
  final void Function(
    String exerciseId,
    String exerciseName,
    String exerciseType, {
    String? setId,
    int? currentReps,
    double? currentWeight,
  }) onManageSet;
  final void Function(String exerciseId, String setId) onDeleteSet;
  final AppSettings settings;

  const _ExercisesSection({
    required this.workoutData,
    required this.workoutId,
    required this.exerciseCardPadding,
    required this.slidableActionWidth,
    required this.setActionSpacing,
    required this.emptyMessage,
    required this.noSetsMessage,
    required this.addSetLabel,
    required this.onEditExercise,
    required this.onDeleteExercise,
    required this.onManageSet,
    required this.onDeleteSet,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child:
              Text('Exercises', style: Theme.of(context).textTheme.titleMedium),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: workoutData.getExercisesStream(workoutId),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(child: Text(emptyMessage));
              }

              final exercises = snapshot.data!.docs;
              return SlidableAutoCloseBehavior(
                child: ListView.builder(
                  itemCount: exercises.length,
                  itemBuilder: (context, index) {
                    final exercise = exercises[index];
                    return _ExerciseCard(
                      exercise: exercise,
                      workoutId: workoutId,
                      workoutData: workoutData,
                      padding: exerciseCardPadding,
                      slidableActionWidth: slidableActionWidth,
                      setActionSpacing: setActionSpacing,
                      noSetsMessage: noSetsMessage,
                      addSetLabel: addSetLabel,
                      onEditExercise: onEditExercise,
                      onDeleteExercise: onDeleteExercise,
                      onManageSet: onManageSet,
                      onDeleteSet: onDeleteSet,
                      settings: settings,
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final QueryDocumentSnapshot exercise;
  final WorkoutData workoutData;
  final String workoutId;
  final EdgeInsets padding;
  final double slidableActionWidth;
  final double setActionSpacing;
  final String noSetsMessage;
  final String addSetLabel;
  final Future<void> Function({
    String? exerciseId,
    String? currentName,
    String? currentType,
  }) onEditExercise;
  final void Function(String exerciseId) onDeleteExercise;
  final void Function(
    String exerciseId,
    String exerciseName,
    String exerciseType, {
    String? setId,
    int? currentReps,
    double? currentWeight,
  }) onManageSet;
  final void Function(String exerciseId, String setId) onDeleteSet;
  final AppSettings settings;

  const _ExerciseCard({
    required this.exercise,
    required this.workoutData,
    required this.workoutId,
    required this.padding,
    required this.slidableActionWidth,
    required this.setActionSpacing,
    required this.noSetsMessage,
    required this.addSetLabel,
    required this.onEditExercise,
    required this.onDeleteExercise,
    required this.onManageSet,
    required this.onDeleteSet,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    final name = exercise['name'];
    final type = exercise['type'];

    return Padding(
      padding: padding,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final ratio =
              (slidableActionWidth / constraints.maxWidth).clamp(0.2, 0.35);

          return Slidable(
            key: ValueKey(exercise.id),
            groupTag: workoutId,
            endActionPane: buildSlidableActionPane(
              context,
              extentRatio: ratio,
              onEdit: () => onEditExercise(
                exerciseId: exercise.id,
                currentName: name,
                currentType: type,
              ),
              onDelete: () => onDeleteExercise(exercise.id),
              buttonSize: 48,
            ),
            child: Card(
              child: Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: AppColors.transparent,
                ),
                child: ExpansionTile(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  collapsedShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  title: Text("($type) $name"),
                  childrenPadding: const EdgeInsets.symmetric(horizontal: 8),
                  children: [
                    _ExerciseSetsList(
                      workoutData: workoutData,
                      workoutId: workoutId,
                      exerciseId: exercise.id,
                      exerciseName: name,
                      exerciseType: type,
                      setActionSpacing: setActionSpacing,
                      noSetsMessage: noSetsMessage,
                      addSetLabel: addSetLabel,
                      onManageSet: onManageSet,
                      onDeleteSet: onDeleteSet,
                      settings: settings,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ExerciseSetsList extends StatelessWidget {
  final WorkoutData workoutData;
  final String workoutId;
  final String exerciseId;
  final String exerciseName;
  final String exerciseType;
  final double setActionSpacing;
  final String noSetsMessage;
  final String addSetLabel;
  final void Function(
    String exerciseId,
    String exerciseName,
    String exerciseType, {
    String? setId,
    int? currentReps,
    double? currentWeight,
  }) onManageSet;
  final void Function(String exerciseId, String setId) onDeleteSet;
  final AppSettings settings;

  const _ExerciseSetsList({
    required this.workoutData,
    required this.workoutId,
    required this.exerciseId,
    required this.exerciseName,
    required this.exerciseType,
    required this.setActionSpacing,
    required this.noSetsMessage,
    required this.addSetLabel,
    required this.onManageSet,
    required this.onDeleteSet,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StreamBuilder<QuerySnapshot>(
          stream: workoutData.getSetsStream(workoutId, exerciseId),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(noSetsMessage),
              );
            }
            final sets = snapshot.data!.docs;
            return Column(
              children: sets.map((set) {
                final weightLabel = exerciseType == 'Bodyweight'
                    ? ''
                    : 'x ${settings.formatWeight((set['weight'] as num).toDouble())}';
                return ListTile(
                  dense: true,
                  title: Text("${set['reps']} $weightLabel"),
                  trailing: Wrap(
                    spacing: setActionSpacing,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        onPressed: () => onManageSet(
                          exerciseId,
                          exerciseName,
                          exerciseType,
                          setId: set.id,
                          currentReps: set['reps'],
                          currentWeight: set['weight'],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete,
                            color: AppColors.danger, size: 20),
                        onPressed: () => onDeleteSet(exerciseId, set.id),
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          },
        ),
        TextButton.icon(
          onPressed: () => onManageSet(exerciseId, exerciseName, exerciseType),
          icon: const Icon(Icons.add),
          label: Text(addSetLabel),
        ),
      ],
    );
  }
}
