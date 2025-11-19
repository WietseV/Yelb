import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:yelb/data/workout_data.dart';

import '../main.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  final dateFormat = DateFormat('dd-MM-yyyy HH:mm');
  final hourFormat = DateFormat('HH:mm');

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutData>(
        builder: (context, value, child) =>
            Scaffold(
                appBar: AppBar(
                  title: Text('placeholder'),
                ),
                body: ScaffoldWithBackground( child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Settings",
                        ),
                      ],
                    ),
                  ],
                ))
            )
    );
  }
}
