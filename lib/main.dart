import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class Exercise {
  String name;
  double weight;
  int reps;
  int sets;

  Exercise({required this.name, required this.weight, required this.reps, required this.sets});
}

class MyApp extends StatelessWidget {
  final List<Exercise> exercises = []; // Store exercises in memory for simplicity

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'You even Lift, Bro?',
      home: Scaffold(
        appBar: AppBar(
          title: Text('You even Lift, Bro?'),
        ),
        body: ExerciseList(exercises: exercises),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddExerciseScreen()),
            ).then((newExercise) {
              if (newExercise != null) {
                // Add the new exercise to the list
                exercises.add(newExercise);
              }
            });
          },
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}

class ExerciseList extends StatelessWidget {
  final List<Exercise> exercises;

  ExerciseList({required this.exercises});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: exercises.length,
      itemBuilder: (context, index) {
        final exercise = exercises[index];
        return ListTile(
          title: Text(exercise.name),
          subtitle: Text('Weight: ${exercise.weight} lbs - Reps: ${exercise.reps} - Sets: ${exercise.sets}'),
        );
      },
    );
  }
}

class AddExerciseScreen extends StatefulWidget {
  @override
  _AddExerciseScreenState createState() => _AddExerciseScreenState();
}

class _AddExerciseScreenState extends State<AddExerciseScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController repsController = TextEditingController();
  final TextEditingController setsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Exercise'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Exercise Name'),
            ),
            TextField(
              controller: weightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Weight (lbs)'),
            ),
            TextField(
              controller: repsController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Reps'),
            ),
            TextField(
              controller: setsController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Sets'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // Create a new Exercise object and pass it back to the main screen
                final newExercise = Exercise(
                  name: nameController.text,
                  weight: double.parse(weightController.text),
                  reps: int.parse(repsController.text),
                  sets: int.parse(setsController.text),
                );
                Navigator.pop(context, newExercise);
              },
              child: Text('Add Exercise'),
            ),
          ],
        ),
      ),
    );
  }
}
