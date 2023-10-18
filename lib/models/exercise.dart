import 'package:hive/hive.dart';
import 'package:yelb/models/set.dart';

class Exercise extends HiveObject {
  String name;
  String type;
  List<Set> sets;
  bool? hasBodyWeight;

  Exercise(
      {required this.name,
      required this.type,
      required this.sets,
      this.hasBodyWeight});
}
