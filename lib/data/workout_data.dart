import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:yelb/models/exercise.dart';
import 'package:yelb/models/workout.dart';
import 'package:yelb/models/set.dart';
import 'package:intl/intl.dart';

class WorkoutData extends ChangeNotifier {
  final workoutsDB = Hive.box<Workout>("WorkoutsDB");

  final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  // List<Workout> getWorkouts() {
  //   return workoutsDB.toMap().entries.map((e) => e.value).toList();
  // }

  void addWorkout(String type, String location) {
    DateTime date = DateTime.now();
    String key = type + dateFormat.format(date).toString();
    workoutsDB.put(key,
        Workout(type: type, location: location, date: date, exercises: []));
    notifyListeners();
  }

  void addExercise(
      String workoutType, DateTime workoutDate, String name, String type) {
    Workout workout = getWorkout(workoutType, workoutDate);
    workout.exercises.add(Exercise(name: name, type: type, sets: []));
    workout.save();
    workoutsDB
        .get(workoutType + dateFormat.format(workoutDate))
        ?.exercises
        .toString();
    notifyListeners();
  }

  void addSet(String workoutType, DateTime workoutDate, String exerciseName,
      String exerciseType, int reps, double weight) {
    Workout workout = getWorkout(workoutType, workoutDate);
    Exercise exercise = getExercise(
        getWorkout(workoutType, workoutDate), exerciseName, exerciseType);
    exercise.sets.add(Set(
      reps: reps,
      weight: weight,
    ));
    workout.save();
    notifyListeners();
  }

  Workout getWorkout(String type, DateTime date) {
    return workoutsDB.get(type + dateFormat.format(date).toString()) as Workout;
  }

  Exercise getExercise(Workout workout, String name, String type) {
    return workout.exercises.firstWhere(
        (exercise) => exercise.name == name && exercise.type == type);
  }

  void deleteWorkout(Workout workout) {
    workout.delete();
    notifyListeners();
  }

  void deleteExercise(Workout workout, String name, String type) {
    workout.exercises.remove(getExercise(workout, name, type));
    notifyListeners();
  }
}
