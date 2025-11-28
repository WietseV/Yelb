import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WorkoutData extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const _guestUserIdKey = 'guest_user_id';

  String? _guestUserId;
  bool _guestSessionActive = false;

  bool get isGuestSessionActive => _guestSessionActive;

  Future<void> enableGuestMode() async {
    if (_guestSessionActive) return;
    await _loadOrCreateGuestId();
    _guestSessionActive = true;
    notifyListeners();
  }

  void disableGuestMode() {
    if (!_guestSessionActive) return;
    _guestSessionActive = false;
    notifyListeners();
  }

  String? get _activeUserId =>
      FirebaseAuth.instance.currentUser?.uid ??
      (_guestSessionActive ? _guestUserId : null);

  DocumentReference<Map<String, dynamic>> get _userDoc {
    final userId = _activeUserId;
    if (userId == null) {
      throw StateError('No authenticated user');
    }
    return _db.collection('users').doc(userId);
  }

  Future<void> _ensureUserDocument() async {
    final doc = _userDoc;
    final snapshot = await doc.get();
    if (!snapshot.exists) {
      await doc.set({'createdAt': DateTime.now()});
    }
  }

  // WORKOUTS -------------------------

  Stream<QuerySnapshot> getWorkoutsStream() {
    return _userDoc
        .collection('workouts')
        .orderBy('date', descending: true)
        .snapshots();
  }

  Future<void> addWorkout(String type, String location) async {
    await _ensureUserDocument();
    final newWorkout = {
      'type': type,
      'location': location,
      'date': DateTime.now(),
    };
    await _userDoc.collection('workouts').add(newWorkout);
  }

  Future<void> updateWorkout(
      String workoutId, String type, String location) async {
    await _userDoc.collection('workouts').doc(workoutId).update({
      'type': type,
      'location': location,
    });
  }

  Future<void> deleteWorkout(String workoutId) async {
    final workoutRef = _userDoc.collection('workouts').doc(workoutId);

    final exercises = await workoutRef.collection('exercises').get();
    for (final exercise in exercises.docs) {
      final sets = await exercise.reference.collection('sets').get();
      for (final set in sets.docs) {
        await set.reference.delete();
      }
      await exercise.reference.delete();
    }

    await workoutRef.delete();
  }

  // EXERCISES -------------------------

  Stream<QuerySnapshot> getExercisesStream(String workoutId) {
    return _userDoc
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
    await _userDoc
        .collection('workouts')
        .doc(workoutId)
        .collection('exercises')
        .add(newExercise);
  }

  Future<void> updateExercise(
      String workoutId, String exerciseId, String name, String type) async {
    await _userDoc
        .collection('workouts')
        .doc(workoutId)
        .collection('exercises')
        .doc(exerciseId)
        .update({'name': name, 'type': type});
  }

  Future<void> deleteExercise(String workoutId, String exerciseId) async {
    final exerciseRef = _userDoc
        .collection('workouts')
        .doc(workoutId)
        .collection('exercises')
        .doc(exerciseId);
    final sets = await exerciseRef.collection('sets').get();
    for (final set in sets.docs) {
      await set.reference.delete();
    }
    await exerciseRef.delete();
  }

  // SETS -------------------------

  Stream<QuerySnapshot> getSetsStream(String workoutId, String exerciseId) {
    return _userDoc
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
    await _userDoc
        .collection('workouts')
        .doc(workoutId)
        .collection('exercises')
        .doc(exerciseId)
        .collection('sets')
        .add(newSet);
  }

  Future<void> updateSet(String workoutId, String exerciseId, String setId,
      int reps, double weight) async {
    await _userDoc
        .collection('workouts')
        .doc(workoutId)
        .collection('exercises')
        .doc(exerciseId)
        .collection('sets')
        .doc(setId)
        .update({'reps': reps, 'weight': weight});
  }

  Future<void> deleteSet(
      String workoutId, String exerciseId, String setId) async {
    await _userDoc
        .collection('workouts')
        .doc(workoutId)
        .collection('exercises')
        .doc(exerciseId)
        .collection('sets')
        .doc(setId)
        .delete();
  }

  Future<Map<String, dynamic>?> getLastSet(
      String workoutId, String exerciseId) async {
    final snapshot = await _userDoc
        .collection('workouts')
        .doc(workoutId)
        .collection('exercises')
        .doc(exerciseId)
        .collection('sets')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return null;
    return snapshot.docs.first.data();
  }

  Future<void> updateWorkoutDescription(
      String workoutId, String description) async {
    await _userDoc.collection('workouts').doc(workoutId).update({
      'description': description,
    });
  }

  Future<String> getWorkoutDescription(String workoutId) async {
    final doc = await _userDoc.collection('workouts').doc(workoutId).get();
    return doc.data()?['description'] ?? '';
  }

  // DEFAULT DATA LOADING -------------------------

  Future<Map<String, String>> getDefaultWeightTypes() {
    return _getDefaultMap('weight-types');
  }

  Future<Map<String, String>> getDefaultWorkoutTypes() {
    return _getDefaultMap('workout-types');
  }

  Future<Map<String, String>> getDefaultWorkoutLocations() {
    return _getDefaultMap('workout-locations');
  }

  Future<Map<String, String>> getDefaultExerciseTypes() {
    return _getDefaultMap('exercise-types');
  }

  Future<Map<String, String>> _getDefaultMap(String collectionId) async {
    final snap = await _db
        .collection('app-data')
        .doc('default-app-data')
        .collection(collectionId)
        .doc('default-$collectionId')
        .get();
    final data = snap.data();
    if (data == null) {
      return {};
    }
    return data.map((key, value) {
      return MapEntry(key, value == null ? '' : value.toString());
    });
  }

  Future<void> _loadOrCreateGuestId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _guestUserId = prefs.getString(_guestUserIdKey);
      if (_guestUserId == null) {
        _guestUserId = _generateGuestUserId();
        await prefs.setString(_guestUserIdKey, _guestUserId!);
      }
    } on PlatformException {
      _guestUserId ??= _generateGuestUserId();
    }
  }

  String _generateGuestUserId() {
    final random = Random();
    final buffer = StringBuffer('guest_');
    for (var i = 0; i < 12; i++) {
      buffer.write(random.nextInt(36).toRadixString(36));
    }
    return buffer.toString();
  }
}
