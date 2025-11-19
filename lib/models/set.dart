import 'package:hive/hive.dart';

class Set extends HiveObject {
  double weight;
  int reps;

  Set({required this.weight, required this.reps});
}
