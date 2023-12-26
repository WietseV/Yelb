import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yelb/data/workout_data.dart';
import 'pages/home_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
            primaryTextTheme: TextTheme(
                displayLarge: TextStyle(
              color: Colors.white,
            ))),
        home: HomePage(),
      ),
    );
  }
}
