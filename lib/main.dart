import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yelb/data/workout_data.dart';
import 'models/workout.dart';
import 'pages/homePage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => WorkoutData(),
      child: MaterialApp(
        title: 'Yelb',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 16, 78, 34)),
          primaryTextTheme: TextTheme(
            displayLarge: TextStyle(
              color: Colors.green,
            )
          )
        ),
        home: HomePage(),
      ),
    );
  }
}


