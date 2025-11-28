import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yelb/models/exercise.dart';

class Workout {
  final String type;
  final String location;
  final DateTime date;
  String? description;
  List<Exercise>? exercises;

  Workout(
      {required this.type,
      required this.location,
      required this.date,
      this.description,
      required this.exercises});

  factory Workout.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return Workout(
      type: data?['type'],
      location: data?['location'],
      date: data?['date'],
      description: data?['description'],
      exercises:
          data?['exercises'] is Iterable ? List.from(data?['exercises']) : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "type": type,
      "location": location,
      "date": date,
      "description": description,
      if (exercises != null) "exercises": exercises,
    };
  }
}
