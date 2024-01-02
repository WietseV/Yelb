import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:provider/provider.dart';
import 'package:yelb/data/default_data.dart';
import 'package:yelb/data/workout_data.dart';
import 'package:yelb/models/workout.dart';
import 'package:yelb/utility/date_helpers.dart';

import '../main.dart';

class WorkoutPage extends StatefulWidget {
  final Workout workout;
  const WorkoutPage({super.key, required this.workout});

  @override
  State<WorkoutPage> createState() => _WorkoutPageState(workout);
}

class _WorkoutPageState extends State<WorkoutPage> {
  int integer = 0;
  int decimal = 0;
  int reps = 0;

  var workoutInApp;

  ExerciseName? exerciseName;
  ExerciseType? exerciseType;

  List<bool> show = [];

  final dateFormat = DateFormat('dd-MM-yyyy HH:mm');
  final hourFormat = DateFormat('HH:mm');

  _WorkoutPageState(Workout workout) {
    workoutInApp = workout;
    for (int i = 0; i < workout.exercises!.length; i++) {
      if (i == 0) {
        show.add(true);
      } else {
        show.add(false);
      }
    }
  }

  void createNewSet(String exerciseName, String exerciseType) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("Add Set"),
              content: StatefulBuilder(builder: (context, setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Reps: "),
                    NumberPicker(
                        minValue: 0,
                        maxValue: 20,
                        axis: Axis.horizontal,
                        value: reps,
                        zeroPad: true,
                        itemWidth: 50,
                        onChanged: (value) => setState(() {
                              reps = value;
                            })),
                    Visibility(
                      visible: exerciseType != "Bodyweight",
                      child: Column(
                        children: [
                          Text("Weight: "),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              NumberPicker(
                                  minValue: 0,
                                  maxValue: 300,
                                  itemWidth: 50,
                                  value: integer,
                                  onChanged: (value) => setState(() {
                                        integer = value;
                                      })),
                              NumberPicker(
                                  minValue: 0,
                                  maxValue: 99,
                                  step: 25,
                                  zeroPad: true,
                                  itemWidth: 50,
                                  value: decimal,
                                  onChanged: (value) => setState(() {
                                        decimal = value;
                                      })),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }),
              actions: [
                MaterialButton(
                  onPressed: () => saveSet(exerciseName, exerciseType),
                  child: Text("save"),
                ),
                MaterialButton(
                  onPressed: cancel,
                  child: Text("cancel"),
                ),
              ],
            ));
  }

  void createNewExercise() {
    final List<DropdownMenuEntry<ExerciseName>> exerciseNameEntries =
        <DropdownMenuEntry<ExerciseName>>[];
    for (final ExerciseName exerciseName in ExerciseName.values) {
      exerciseNameEntries.add(
        DropdownMenuEntry<ExerciseName>(
            value: exerciseName,
            label: exerciseName.name,
            enabled: exerciseName.name != ''),
      );
    }

    final List<DropdownMenuEntry<ExerciseType>> exerciseTypeEntries =
        <DropdownMenuEntry<ExerciseType>>[];
    for (final ExerciseType exerciseType in ExerciseType.values) {
      exerciseTypeEntries.add(
        DropdownMenuEntry<ExerciseType>(
            value: exerciseType,
            label: exerciseType.type,
            enabled: exerciseType.type != ''),
      );
    }

    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("Add Exercise"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  DropdownMenu<ExerciseName>(
                    width: 200,
                    menuHeight: 300,
                    label: const Text('Exercise Name'),
                    dropdownMenuEntries: exerciseNameEntries,
                    onSelected: (ExerciseName? name) {
                      setState(() {
                        exerciseName = name;
                      });
                    },
                  ),
                  SizedBox(
                    height: 24,
                  ),
                  DropdownMenu<ExerciseType>(
                    label: const Text('Exercise Type'),
                    dropdownMenuEntries: exerciseTypeEntries,
                    onSelected: (ExerciseType? type) {
                      setState(() {
                        exerciseType = type;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                MaterialButton(
                  onPressed: saveExercise,
                  child: Text("save"),
                ),
                MaterialButton(
                  onPressed: cancel,
                  child: Text("cancel"),
                ),
              ],
            ));
  }

  void saveExercise() {
    for (int i = 0; i < show.length; i++) {
      show[i] = false;
    }
    show.add(true);
    String newExerciseName = exerciseName!.name;
    String newExerciseType = exerciseType!.type;
    Provider.of<WorkoutData>(context, listen: false).addExercise(
        widget.workout.type,
        widget.workout.date,
        newExerciseName,
        newExerciseType);
    Navigator.pop(context);
  }

  void saveSet(String exerciseName, String exerciseType) {
    double weight;
    if (exerciseType == "Bodyweight") {
      weight = 69.0;
    } else {
      weight = double.parse((integer + (decimal / 100)).toString());
    }
    double newSetWeight = weight;
    int newSetReps = reps;
    Provider.of<WorkoutData>(context, listen: false).addSet(
        widget.workout.type,
        widget.workout.date,
        exerciseName,
        exerciseType,
        newSetReps,
        newSetWeight);
    Navigator.pop(context);
  }

  void cancel() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutData>(
      builder: (context, value, child) => Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text("${widget.workout.type} - "),
                  Text(
                    widget.workout.location,
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
              Text(
                  widget.workout.date.isToday()
                      ? "today ${hourFormat.format(widget.workout.date)}"
                      : widget.workout.date.isYesterday()
                          ? "yesterday ${hourFormat.format(widget.workout.date)}"
                          : dateFormat.format(widget.workout.date),
                  style: TextStyle(fontSize: 15)),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: createNewExercise,
          child: Icon(Icons.add),
        ),
        body: ScaffoldWithBackground(child: widget.workout.exercises!.isEmpty
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Add an exercise",
                        style: TextStyle(color: Colors.grey[600], fontSize: 30),
                      ),
                    ],
                  ),
                ],
              )
            : ListView.builder(
                itemCount: workoutInApp.exercises?.length,

                itemBuilder: (context, index) => Card(
                  color: Colors.blueGrey[100],
                  child: ListTile(
                    titleAlignment: ListTileTitleAlignment.center,
                    onTap: () {
                      setState(() {
                        if (show[index] == true) {
                          show[index] = !show[index];
                        } else {
                          for (int i = 0; i < show.length; i++) {
                            show[i] = false;
                          }
                          show[index] = !show[index];
                        }
                      });
                    },
                    title: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "(${workoutInApp.exercises?[index].type}) ${workoutInApp.exercises![index].name}",
                            ),
                            Icon(show[index]
                                ? Icons.arrow_drop_up_outlined
                                : Icons.arrow_drop_down_outlined)
                          ],
                        ),
                      ],
                    ),
                    subtitle: Visibility(
                      visible: show[index],
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(2.0),
                            decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                              color: Colors.blueGrey,
                              width: 0.5,
                            ))),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Card(
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: workoutInApp.exercises![index]
                                  .sets
                                  !.length,
                              itemBuilder: (context, index2) => ListTile(
                                titleAlignment: ListTileTitleAlignment.center,
                                dense: true,
                                visualDensity:
                                    VisualDensity(horizontal: -4, vertical: -4),
                                contentPadding:
                                    EdgeInsets.fromLTRB(10, 0, 0, 0),
                                subtitle: Text(
                                    "${workoutInApp.exercises![index].sets![index2].reps}  ${workoutInApp.exercises![index].type == "Bodyweight" ? "" : "x ${workoutInApp.exercises![index].sets![index2].weight.toString()} kg"}"),
                              ),
                            ),
                          ),
                          Card(
                            child: TextButton(
                              onPressed: () => createNewSet(
                                  workoutInApp
                                      .exercises![index]
                                      .name,
                                  workoutInApp
                                      .exercises![index]
                                      .type),
                              style: TextButton.styleFrom(
                                  minimumSize: const Size.fromHeight(30)),
                              child: Icon(Icons.add),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      ),)
    );
  }
}
