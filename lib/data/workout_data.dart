import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class WorkoutData extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // WORKOUTS -------------------------

  Stream<QuerySnapshot> getWorkoutsStream() {
    return _db
        .collection('workouts')
        .orderBy('date', descending: true)
        .snapshots();
  }

  Future<void> addWorkout(String type, String location) async {
    final newWorkout = {
      'type': type,
      'location': location,
      'date': DateTime.now(),
    };
    await _db.collection('workouts').add(newWorkout);
  }

  // EXERCISES -------------------------

  Stream<QuerySnapshot> getExercisesStream(String workoutId) {
    return _db
        .collection('workouts')
        .doc(workoutId)
        .collection('exercises')
        .orderBy('name')
        .snapshots();
  }

  Future<void> addExercise(String workoutId, String name, String type) async {
    final newExercise = {
      'name': name,
      'type': type,
    };
    await _db
        .collection('workouts')
        .doc(workoutId)
        .collection('exercises')
        .add(newExercise);
  }

  // SETS -------------------------

  Stream<QuerySnapshot> getSetsStream(String workoutId, String exerciseId) {
    return _db
        .collection('workouts')
        .doc(workoutId)
        .collection('exercises')
        .doc(exerciseId)
        .collection('sets')
        .orderBy('weight', descending: true)
        .snapshots();
  }

  Future<void> addSet(
      String workoutId, String exerciseId, int reps, double weight) async {
    final newSet = {
      'reps': reps,
      'weight': weight,
      'timestamp': DateTime.now(),
    };
    await _db
        .collection('workouts')
        .doc(workoutId)
        .collection('exercises')
        .doc(exerciseId)
        .collection('sets')
        .add(newSet);
  }
}
