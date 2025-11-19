import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:yelb/data/default_data.dart';
import '../main.dart';

class WorkoutPage extends StatefulWidget {
  final String workoutId;
  final String workoutType;

  const WorkoutPage({
    super.key,
    required this.workoutId,
    required this.workoutType,
  });

  @override
  State<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  ExerciseName? exerciseName;
  ExerciseType? exerciseType;

  final dateFormat = DateFormat('dd-MM-yyyy HH:mm');

  // ---------------------- ADD/EDIT EXERCISE ----------------------
  void _showExerciseDialog(
      {String? exerciseId, String? currentName, String? currentType}) {
    exerciseName = currentName != null
        ? ExerciseName.values.firstWhere((e) => e.name == currentName)
        : null;
    exerciseType = currentType != null
        ? ExerciseType.values.firstWhere((e) => e.type == currentType)
        : null;

    final exerciseNameEntries = ExerciseName.values
        .map((e) => DropdownMenuEntry<ExerciseName>(
              value: e,
              label: e.name,
              enabled: e.name.isNotEmpty,
            ))
        .toList();

    final exerciseTypeEntries = ExerciseType.values
        .map((e) => DropdownMenuEntry<ExerciseType>(
              value: e,
              label: e.type,
              enabled: e.type.isNotEmpty,
            ))
        .toList();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(exerciseId == null ? "Add Exercise" : "Edit Exercise"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownMenu<ExerciseName>(
              width: 200,
              initialSelection: exerciseName,
              label: const Text('Exercise Name'),
              dropdownMenuEntries: exerciseNameEntries,
              onSelected: (ExerciseName? name) =>
                  setState(() => exerciseName = name),
            ),
            const SizedBox(height: 24),
            DropdownMenu<ExerciseType>(
              width: 200,
              initialSelection: exerciseType,
              label: const Text('Exercise Type'),
              dropdownMenuEntries: exerciseTypeEntries,
              onSelected: (ExerciseType? type) =>
                  setState(() => exerciseType = type),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              if (exerciseName != null && exerciseType != null) {
                if (exerciseId == null) {
                  await _db
                      .collection('workouts')
                      .doc(widget.workoutId)
                      .collection('exercises')
                      .add({
                    'name': exerciseName!.name,
                    'type': exerciseType!.type,
                  });
                } else {
                  await _db
                      .collection('workouts')
                      .doc(widget.workoutId)
                      .collection('exercises')
                      .doc(exerciseId)
                      .update({
                    'name': exerciseName!.name,
                    'type': exerciseType!.type,
                  });
                }
                Navigator.pop(ctx);
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  // ---------------------- DELETE EXERCISE ----------------------
  void _deleteExercise(String exerciseId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Exercise"),
        content: const Text(
            "Are you sure you want to delete this exercise and all its sets?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final sets = await _db
                  .collection('workouts')
                  .doc(widget.workoutId)
                  .collection('exercises')
                  .doc(exerciseId)
                  .collection('sets')
                  .get();
              for (var s in sets.docs) {
                await s.reference.delete();
              }
              await _db
                  .collection('workouts')
                  .doc(widget.workoutId)
                  .collection('exercises')
                  .doc(exerciseId)
                  .delete();
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // SLIDE-UP ADD/EDIT SET ----------------------

  void _showAddOrEditSetSheet(
      String exerciseId, String exerciseName, String exerciseType,
      {String? setId, int? currentReps, double? currentWeight}) async {
    int selectedReps = currentReps ?? 8;
    double selectedWeight = currentWeight ?? 0.0;

    if (setId == null && currentReps == null && currentWeight == null) {
      final lastSetSnapshot = await _db
          .collection('workouts')
          .doc(widget.workoutId)
          .collection('exercises')
          .doc(exerciseId)
          .collection('sets')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();
      if (lastSetSnapshot.docs.isNotEmpty) {
        final last = lastSetSnapshot.docs.first;
        selectedReps = last['reps'];
        selectedWeight = last['weight'];
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
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
                    height: 90,
                    child: ListWheelScrollView.useDelegate(
                      physics: const FixedExtentScrollPhysics(),
                      perspective: 0.004,
                      diameterRatio: 2,
                      itemExtent: 40,
                      onSelectedItemChanged: (v) =>
                          setState(() => selectedReps = v + 1),
                      childDelegate: ListWheelChildBuilderDelegate(
                        builder: (context, index) => Text(
                          "${index + 1}",
                          style: TextStyle(
                            fontSize: index + 1 == selectedReps ? 22 : 18,
                            color: index + 1 == selectedReps
                                ? Colors.blueGrey[900]
                                : Colors.blueGrey[400],
                          ),
                        ),
                        childCount: 20,
                      ),
                    ),
                  ),
                  if (exerciseType != "Bodyweight") ...[
                    const SizedBox(height: 12),
                    const Text("Weight (kg)",
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    SizedBox(
                      height: 90,
                      child: ListWheelScrollView.useDelegate(
                        physics: const FixedExtentScrollPhysics(),
                        perspective: 0.004,
                        diameterRatio: 2,
                        itemExtent: 40,
                        onSelectedItemChanged: (v) =>
                            setState(() => selectedWeight = v * 0.25),
                        childDelegate: ListWheelChildBuilderDelegate(
                          builder: (context, index) {
                            final w = index * 0.25;
                            final active = (w - selectedWeight).abs() < 0.001;
                            return Text(
                              w.toStringAsFixed(2),
                              style: TextStyle(
                                fontSize: active ? 22 : 18,
                                color: active
                                    ? Colors.blueGrey[900]
                                    : Colors.blueGrey[400],
                              ),
                            );
                          },
                          childCount: (300 / 0.25).round() + 1,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey[700],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      minimumSize: const Size.fromHeight(45),
                    ),
                    onPressed: () async {
                      if (setId == null) {
                        await _db
                            .collection('workouts')
                            .doc(widget.workoutId)
                            .collection('exercises')
                            .doc(exerciseId)
                            .collection('sets')
                            .add({
                          'reps': selectedReps,
                          'weight': exerciseType == "Bodyweight"
                              ? 69.0
                              : selectedWeight,
                          'timestamp': DateTime.now(),
                        });
                      } else {
                        await _db
                            .collection('workouts')
                            .doc(widget.workoutId)
                            .collection('exercises')
                            .doc(exerciseId)
                            .collection('sets')
                            .doc(setId)
                            .update({
                          'reps': selectedReps,
                          'weight': exerciseType == "Bodyweight"
                              ? 69.0
                              : selectedWeight,
                        });
                      }
                      Navigator.pop(ctx);
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
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Set"),
        content: const Text("Are you sure you want to delete this set?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              await _db
                  .collection('workouts')
                  .doc(widget.workoutId)
                  .collection('exercises')
                  .doc(exerciseId)
                  .collection('sets')
                  .doc(setId)
                  .delete();
              Navigator.pop(ctx);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // BUILD UI ----------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.workoutType), centerTitle: true),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showExerciseDialog(),
        child: const Icon(Icons.add),
      ),
      body: ScaffoldWithBackground(
        child: StreamBuilder<QuerySnapshot>(
          stream: _db
              .collection('workouts')
              .doc(widget.workoutId)
              .collection('exercises')
              .orderBy('name')
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text("Add an exercise"));
            }

            final exercises = snapshot.data!.docs;
            return ListView.builder(
              itemCount: exercises.length,
              itemBuilder: (context, index) {
                final e = exercises[index];
                final name = e['name'];
                final type = e['type'];

                return Slidable(
                  key: ValueKey(e.id),
                  endActionPane: ActionPane(
                    motion: const DrawerMotion(),
                    extentRatio: 0.3,
                    children: [
                      SlidableAction(
                        onPressed: (context) => _showExerciseDialog(
                            exerciseId: e.id,
                            currentName: name,
                            currentType: type),
                        backgroundColor: Colors.blueGrey,
                        foregroundColor: Colors.white,
                        icon: Icons.edit,
                        label: 'Edit',
                      ),
                      SlidableAction(
                        onPressed: (context) => _deleteExercise(e.id),
                        backgroundColor: Colors.red.shade400,
                        foregroundColor: Colors.white,
                        icon: Icons.delete,
                        label: 'Delete',
                      ),
                    ],
                  ),
                  child: Card(
                    color: Colors.blueGrey[100],
                    child: ExpansionTile(
                      title: Text("($type) $name"),
                      children: [
                        StreamBuilder<QuerySnapshot>(
                          stream: _db
                              .collection('workouts')
                              .doc(widget.workoutId)
                              .collection('exercises')
                              .doc(e.id)
                              .collection('sets')
                              .orderBy('timestamp', descending: false)
                              .snapshots(),
                          builder: (context, setSnapshot) {
                            if (!setSnapshot.hasData ||
                                setSnapshot.data!.docs.isEmpty) {
                              return const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text("No sets yet."),
                              );
                            }
                            final sets = setSnapshot.data!.docs;
                            return Column(
                              children: sets.map((s) {
                                return ListTile(
                                  dense: true,
                                  title: Text(
                                    "${s['reps']} ${type == 'Bodyweight' ? '' : 'x ${s['weight'].toStringAsFixed(2)} kg'}",
                                  ),
                                  trailing: Wrap(
                                    spacing: 8,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, size: 20),
                                        onPressed: () => _showAddOrEditSetSheet(
                                          e.id,
                                          name,
                                          type,
                                          setId: s.id,
                                          currentReps: s['reps'],
                                          currentWeight: s['weight'],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete,
                                            color: Colors.red, size: 20),
                                        onPressed: () => _deleteSet(e.id, s.id),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),
                        TextButton.icon(
                          onPressed: () =>
                              _showAddOrEditSetSheet(e.id, name, type),
                          icon: const Icon(Icons.add),
                          label: const Text("Add Set"),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
