import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:yelb/data/workout_data.dart';

import '../main.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {

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
                          "Notifications",
                        ),
                      ],
                    ),
                  ],
                ))
            )
    );
  }
}
