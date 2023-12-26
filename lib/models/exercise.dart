import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yelb/models/set.dart';

class Exercise {
  String name;
  String type;
  List<Set>? sets;
  bool? hasBodyWeight;

  Exercise(
      {required this.name,
      required this.type,
      required this.sets,
      this.hasBodyWeight});

  factory Exercise.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options,
      ) {
    final data = snapshot.data();
    return Exercise(
      name: data?['name'],
      type: data?['type'],
      hasBodyWeight: data?['hasBodyWeight'],
      sets:
      data?['sets'] is Iterable ? List.from(data?['sets']) : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (name != null) "name": name,
      if (type != null) "type": type,
      if (hasBodyWeight != null) "hasBodyWeight": hasBodyWeight,
      if (sets != null) "sets": sets,
    };
  }

}
