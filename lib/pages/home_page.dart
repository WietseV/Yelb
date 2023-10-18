import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:yelb/data/default_data.dart';
import 'package:yelb/data/workout_data.dart';
import 'package:yelb/models/workout.dart';
import 'package:yelb/pages/workout_page.dart';
import 'package:yelb/utility/date_helpers.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final newWorkoutTypeController = TextEditingController();
  final newWorkoutLocationController = TextEditingController();

  WorkoutType? workoutType;
  WorkoutLocation? workoutLocation;

  bool isWorkoutType = true;
  bool isWorkoutLocation = true;

  final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  void createNewWorkout() {
    final List<DropdownMenuEntry<WorkoutType>> workoutTypeEntries =
        <DropdownMenuEntry<WorkoutType>>[];
    for (final WorkoutType type in WorkoutType.values) {
      workoutTypeEntries.add(
        DropdownMenuEntry<WorkoutType>(
            value: type, label: type.type, enabled: type.type != ''),
      );
    }

    final List<DropdownMenuEntry<WorkoutLocation>> workoutLocationEntries =
        <DropdownMenuEntry<WorkoutLocation>>[];
    for (final WorkoutLocation type in WorkoutLocation.values) {
      workoutLocationEntries.add(
        DropdownMenuEntry<WorkoutLocation>(
            value: type, label: type.location, enabled: type.location != ''),
      );
    }

    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("Add Workout"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownMenu<WorkoutType>(
                    label: const Text('Workout Type'),
                    dropdownMenuEntries: workoutTypeEntries,
                    onSelected: (WorkoutType? type) {
                      setState(() {
                        workoutType = type;
                      });
                    },
                  ),
                  SizedBox(
                    height: 24,
                  ),
                  DropdownMenu<WorkoutLocation>(
                    label: const Text('Workout Location'),
                    dropdownMenuEntries: workoutLocationEntries,
                    onSelected: (WorkoutLocation? location) {
                      setState(() {
                        workoutLocation = location;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                MaterialButton(
                  onPressed: save,
                  child: Text("save"),
                ),
                MaterialButton(
                  onPressed: cancel,
                  child: Text("cancel"),
                ),
              ],
            ));
  }

  void goToWorkoutPage(String workoutType, DateTime workoutDate) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => WorkoutPage(
                  workout: Provider.of<WorkoutData>(context, listen: false)
                      .getWorkout(workoutType, workoutDate),
                )));
  }

  void save() {
    String newWorkoutType = workoutType!.type;
    String newWorkoutLocation = workoutLocation!.location;

    if (newWorkoutType.isNotEmpty && newWorkoutLocation.isNotEmpty) {
      Provider.of<WorkoutData>(context, listen: false)
          .addWorkout(newWorkoutType, newWorkoutLocation);
      Navigator.pop(context);
      newWorkoutTypeController.clear();
      newWorkoutLocationController.clear();
    }
  }

  void delete(Workout workout) {
    Provider.of<WorkoutData>(context, listen: false).deleteWorkout(workout);
  }

  void cancel() {
    Navigator.pop(context);
    newWorkoutTypeController.clear();
    newWorkoutLocationController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutData>(
      builder: (context, value, child) => Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          leading: Icon(Icons.ac_unit_outlined),
          title: Text("Yelb"),
          centerTitle: true,
          backgroundColor: Colors.blueGrey,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 24,
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: createNewWorkout,
          child: Icon(Icons.add),
        ),
        body: value.workoutsDB.isEmpty
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Add a workout",
                        style: TextStyle(color: Colors.grey[600], fontSize: 30),
                      ),
                    ],
                  ),
                ],
              )
            : ListView.builder(
                itemCount: value.workoutsDB.length,
                itemBuilder: (context, index) => Card(
                  color: Colors.blueGrey[200],
                  child: TextButton(
                    onPressed: () => goToWorkoutPage(
                        (value.workoutsDB.getAt(index) as Workout).type,
                        (value.workoutsDB.getAt(index) as Workout).date),
                    child: Slidable(
                      endActionPane:
                          ActionPane(motion: BehindMotion(), children: [
                        SlidableAction(
                          padding: EdgeInsets.all(0),
                          backgroundColor:
                              const Color.fromARGB(255, 104, 23, 17),
                          foregroundColor: Colors.white,
                          onPressed: (context) => delete(
                              (value.workoutsDB.getAt(index) as Workout)),
                          icon: Icons.delete,
                          label: "delete",
                        )
                      ]),
                      child: ListTile(
                          title: Text(
                              (value.workoutsDB.getAt(index) as Workout).type),
                          subtitle: Text(
                              "${(value.workoutsDB.getAt(index) as Workout).location} - ${(value.workoutsDB.getAt(index) as Workout).date.isToday() ? "Today" : (value.workoutsDB.getAt(index) as Workout).date.isYesterday() ? "Yesterday" : dateFormat.format((value.workoutsDB.getAt(index) as Workout).date)}"),
                          trailing: Icon(Icons.arrow_forward)),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
