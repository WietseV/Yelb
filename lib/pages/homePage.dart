import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:yelb/data/workout_data.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final newWorkoutTypeController = TextEditingController();

  void createNewWorkout(){
    showDialog(
      context: context, 
      builder: (context) => AlertDialog(
        title: Text("test"),
        content: TextField(
          controller: newWorkoutTypeController,
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
      )
    );
  }
  
  void save() {
    String newWorkoutType = newWorkoutTypeController.text;
    Provider.of<WorkoutData>(context, listen: false).addWorkout(newWorkoutType);
    Navigator.pop(context);
    newWorkoutTypeController.clear();
  }
  void cancel() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutData>(builder: (context, value, child) => Scaffold(
        appBar: AppBar(
          leading: Icon(Icons.ac_unit_outlined),
          leadingWidth: 100,
          title: Text("Yelb"),
          backgroundColor: Colors.blueGrey,
          titleTextStyle:  TextStyle(
              color: Colors.white,
              fontSize: 24,
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: createNewWorkout,
            child: Icon(Icons.add),
          ),
        body: ListView.builder(
          itemCount: value.getWorkouts().length,
          itemBuilder: (context, index) => ListTile(
            title: Text(value.getWorkouts()[index].type),
          ),
        ),
      ),
    );
  }
}