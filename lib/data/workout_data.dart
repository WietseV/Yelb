import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:yelb/models/exercise.dart';
import 'package:yelb/models/workout.dart';
import 'package:yelb/models/set.dart';
import 'package:intl/intl.dart';

class WorkoutData extends ChangeNotifier {
  final db = FirebaseFirestore.instance;

  final dateFormat = DateFormat('dd/MM/yyyy HH:mm');


  Future<void> addWorkout (String type, String location) async {
    DateTime date = DateTime.now();
    String key = type + dateFormat.format(date).toString();
    Workout workout = Workout(type: type, location: location, date: date, exercises: []);
    // workoutsDB.put(key, workout);
    final docRef = db.collection("workouts").withConverter(
      fromFirestore: Workout.fromFirestore,
      toFirestore: (Workout workout, options) => workout.toFirestore(),
    ).doc(key);
    await docRef.set(workout);

    notifyListeners();
  }

  void addExercise(
      String workoutType, DateTime workoutDate, String name, String type) {
    String key = workoutType + dateFormat.format(workoutDate).toString();
    Workout workout = getWorkout(workoutType, workoutDate) as Workout;
    Exercise exercise = Exercise(name: name, type: type, sets: []);
    // workout.exercises.add(Exercise(name: name, type: type, sets: []));
    // workout.save();
    // workoutsDB
    //     .get(workoutType + dateFormat.format(workoutDate))
    //     ?.exercises
    //     .toString();
    notifyListeners();
  final exerciseRef = db.collection("workouts").doc(key);
  exerciseRef.update({"exercises": FieldValue.arrayUnion([exercise]),
  });
  }

  void addSet(String workoutType, DateTime workoutDate, String exerciseName,
      String exerciseType, int reps, double weight) {
    Workout workout = getWorkout(workoutType, workoutDate) as Workout;
    // Exercise exercise = getExercise(getExercise
    //     getWorkout(workoutType, workoutDate) as Workout, exerciseName, exerciseType);
    // exercise.sets.add(Set(
    //   reps: reps,
    //   weight: weight,
    // ));
    // workout.save();
    notifyListeners();
  }

  Workout getWorkout(String type, DateTime date) {
    String key = type + dateFormat.format(date);
    final ref = db.collection("workouts").doc(key).withConverter(
      fromFirestore: Workout.fromFirestore,
      toFirestore: (Workout workout, _) => workout.toFirestore(),
    );
    final docSnap = ref.get().then((DocumentSnapshot doc) { final data = doc.data() as Map<String, dynamic>;}
    );
    return docSnap as Workout;
    // return workoutsDB.get(type + dateFormat.format(date).toString()) as Workout;
  }

  Exercise getExercise(Workout workout, String name, String type) {
    final ref = db.collection("workouts").doc().withConverter(
      fromFirestore: Exercise.fromFirestore,
      toFirestore: (Exercise exercise, _) => exercise.toFirestore(),
    );
    final docSnap = ref.get().then((DocumentSnapshot doc) { final data = doc.data() as Map<String, dynamic>;}
    );
    return docSnap as Exercise;
    // return workout.exercises.firstWhere(
    //     (exercise) => exercise.name == name && exercise.type == type);
  }

  void deleteWorkout(Workout workout) {
    // workout.delete();
    notifyListeners();
  }

  void deleteExercise(Workout workout, String name, String type) {
    // workout.exercises.remove(getExercise(workout, name, type));
    String key = workout.type + dateFormat.format(workout.date);
    Exercise exercise = getExercise(workout, name, type) as Exercise;
    final exerciseRef = db.collection("workouts").doc(key);

    exerciseRef.update({"exercises": FieldValue.arrayRemove([exercise]),
    });
    notifyListeners();
  }
}
