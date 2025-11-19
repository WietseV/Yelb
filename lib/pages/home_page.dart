import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../data/default_data.dart';
import 'workout_page.dart';
import '../main.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  WorkoutType? workoutType;
  WorkoutLocation? workoutLocation;

  final dateFormat = DateFormat('dd-MM-yyyy HH:mm');

  // ADD OR EDIT WORKOUT ----------------------
  void _showWorkoutDialog(
      {String? workoutId, String? currentType, String? currentLocation}) {
    workoutType = currentType != null
        ? WorkoutType.values.firstWhere((e) => e.type == currentType)
        : null;
    workoutLocation = currentLocation != null
        ? WorkoutLocation.values
            .firstWhere((e) => e.location == currentLocation)
        : null;

    final workoutTypeEntries = WorkoutType.values
        .map((e) => DropdownMenuEntry<WorkoutType>(
              value: e,
              label: e.type,
              enabled: e.type.isNotEmpty,
            ))
        .toList();

    final workoutLocationEntries = WorkoutLocation.values
        .map((e) => DropdownMenuEntry<WorkoutLocation>(
              value: e,
              label: e.location,
              enabled: e.location.isNotEmpty,
            ))
        .toList();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(workoutId == null ? "Add Workout" : "Edit Workout"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownMenu<WorkoutType>(
              width: 200,
              menuHeight: 300,
              initialSelection: workoutType,
              label: const Text('Workout Type'),
              dropdownMenuEntries: workoutTypeEntries,
              onSelected: (WorkoutType? type) {
                setState(() => workoutType = type);
              },
            ),
            const SizedBox(height: 24),
            DropdownMenu<WorkoutLocation>(
              width: 200,
              initialSelection: workoutLocation,
              label: const Text('Workout Location'),
              dropdownMenuEntries: workoutLocationEntries,
              onSelected: (WorkoutLocation? loc) {
                setState(() => workoutLocation = loc);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              if (workoutType != null && workoutLocation != null) {
                if (workoutId == null) {
                  await _db.collection('workouts').add({
                    'type': workoutType!.type,
                    'location': workoutLocation!.location,
                    'date': DateTime.now(),
                  });
                } else {
                  await _db.collection('workouts').doc(workoutId).update({
                    'type': workoutType!.type,
                    'location': workoutLocation!.location,
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

  // DELETE WORKOUT ----------------------

  void _deleteWorkout(String workoutId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Workout"),
        content: const Text(
            "Are you sure you want to delete this workout and all its data?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final exercises = await _db
                  .collection('workouts')
                  .doc(workoutId)
                  .collection('exercises')
                  .get();
              for (var ex in exercises.docs) {
                final sets = await _db
                    .collection('workouts')
                    .doc(workoutId)
                    .collection('exercises')
                    .doc(ex.id)
                    .collection('sets')
                    .get();
                for (var s in sets.docs) {
                  await s.reference.delete();
                }
                await ex.reference.delete();
              }
              await _db.collection('workouts').doc(workoutId).delete();
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
      appBar: AppBar(
        title: const Text('Workouts'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showWorkoutDialog(),
        child: const Icon(Icons.add),
      ),
      body: ScaffoldWithBackground(
        child: StreamBuilder<QuerySnapshot>(
          stream: _db
              .collection('workouts')
              .orderBy('date', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text("No workouts yet."));
            }

            final workouts = snapshot.data!.docs;

            return ListView.builder(
              itemCount: workouts.length,
              itemBuilder: (context, index) {
                final w = workouts[index];
                final date = (w['date'] as Timestamp).toDate();

                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 4.0),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      const double actionWidth = 108.0;
                      final double ratio = actionWidth / constraints.maxWidth;
                      return Slidable(
                        key: ValueKey(w.id),
                        endActionPane: ActionPane(
                          motion: const ScrollMotion(),
                          extentRatio: ratio.clamp(0.2, 0.35),
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(right: 4), // 4 px space
                              child: ClipOval(
                                child: Material(
                                  color: Colors.blueGrey.shade700,
                                  child: InkWell(
                                    onTap: () => _showWorkoutDialog(
                                      workoutId: w.id,
                                      currentType: w['type'],
                                      currentLocation: w['location'],
                                    ),
                                    child: const SizedBox(
                                      width: 52,
                                      height: 52,
                                      child: Icon(Icons.edit,
                                          color: Colors.white, size: 24),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            ClipOval(
                              child: Material(
                                color: Colors.red.shade400,
                                child: InkWell(
                                  onTap: () => _deleteWorkout(w.id),
                                  child: const SizedBox(
                                    width: 52,
                                    height: 52,
                                    child: Icon(Icons.delete,
                                        color: Colors.white, size: 24),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        child: Card(
                          color: Colors.blueGrey[100],
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6), // slightly reduced height
                            title: Text(w['type']),
                            subtitle: Text(
                                "${w['location']} • ${dateFormat.format(date)}"),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => WorkoutPage(
                                  workoutId: w.id,
                                  workoutType: w['type'],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
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
