import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yelb/data/workout_data.dart';
import 'package:yelb/pages/login_page.dart';
import 'pages/home_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,);
  runApp(const MyApp());
}

class ScaffoldWithBackground extends StatelessWidget {
  final Widget child;

  ScaffoldWithBackground({required this.child});

  @override
  Widget build(BuildContext context) {
    return  Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [Color(0xFF87DBE6), Color(0xFF1E1E1E)],
            ),
          ),
            child: child);
  }
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
            scaffoldBackgroundColor: const Color(0xFF1E1E1E),
            useMaterial3: true,
            appBarTheme: AppBarTheme(
              color: Color(0xFF1E1E1E),
              iconTheme: IconThemeData(
                color: Colors.white,
              ),
              titleTextStyle: TextStyle(
                color: Colors.white,
                fontSize: 24,
              )
            ),
            canvasColor: Color(0x87DBE7FF),
            textTheme: TextTheme(displayLarge: TextStyle(
              color: Colors.white,
            )),
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        ),
        home: LoginPage(),
      ),
    );
  }
}
