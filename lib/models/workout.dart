import 'package:yelb/models/exercise.dart';

class Workout {
  String type;
  DateTime date;
  List<Exercise> exercises;

  Workout({required this.type, required this.date, required this.exercises});
}