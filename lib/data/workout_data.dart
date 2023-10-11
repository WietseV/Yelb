import 'package:flutter/material.dart';
import 'package:yelb/models/exercise.dart';
import 'package:yelb/models/workout.dart';
import 'package:yelb/models/set.dart';

class WorkoutData extends ChangeNotifier {

  List<Workout> workouts = [
    Workout(
      type: "Push A", 
      date: DateTime.now(), 
      exercises: [])
  ];

  List<Exercise> exercises = [
    Exercise(
      name: "Bench Press", 
      type: "barbell", 
      sets: [])
  ];

  List<Workout> getWorkouts() {
    return workouts;
  }

  List<Exercise> getExercises(){
    return exercises;
  }

  void addWorkout(String type) {
    workouts.add(Workout(
      type: type, 
      date: DateTime.now(), 
      exercises: []
    ));

    notifyListeners();
  }

  void addExercise(String workoutType, String type, String name) {
    Workout workout = getWorkout(workoutType);
    workout.exercises.add(Exercise(
      name: name, 
      type: type, 
      sets: []
    ));

    notifyListeners();
  }

  void addSet(String workoutType, String exerciseName, int reps, double weight){
    Exercise exercise = getExercise(getWorkout(workoutType), exerciseName);
    exercise.sets.add(Set(
      reps: reps,
      weight: weight,
    ));

    notifyListeners();
  }

  Workout getWorkout(String type){
    return workouts.firstWhere((workout) => workout.type == type);
  }

  Exercise getExercise(Workout workout, String name){
    return workout.exercises.firstWhere((exercise) => exercise.name == name);
  }

}