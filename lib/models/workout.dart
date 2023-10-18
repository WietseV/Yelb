import 'package:hive/hive.dart';
import 'package:yelb/models/exercise.dart';

part 'workout.g.dart';

@HiveType(typeId: 1)
class Workout extends HiveObject {
  @HiveField(0)
  String type;
  @HiveField(1)
  String location;
  @HiveField(2)
  DateTime date;
  @HiveField(3)
  List<Exercise> exercises;

  Workout(
      {required this.type,
      required this.location,
      required this.date,
      required this.exercises});
}
