import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../pages/home_page.dart';
import '../pages/login_page.dart';
import '../pages/user_page.dart';
import '../pages/exercises_page.dart';
import '../pages/settings_page.dart';
import '../pages/workouts_page.dart';
import '../widgets/app_bottom_nav_bar.dart';

class NavigationUtils {
  static void handleBottomNav(
    BuildContext context,
    AppNavDestination destination, {
    bool isActive = false,
  }) {
    if (isActive) return;
    final navigator = Navigator.of(context);
    switch (destination) {
      case AppNavDestination.home:
        navigator.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomePage()),
          (route) => false,
        );
        break;
      case AppNavDestination.workouts:
        navigator.push(
          MaterialPageRoute(builder: (_) => const WorkoutsPage()),
        );
        break;
      case AppNavDestination.user:
        _openUserDestination(navigator);
        break;
      case AppNavDestination.settings:
        navigator.push(
          MaterialPageRoute(builder: (_) => const SettingsPage()),
        );
        break;
    }
  }

  static void openWorkoutDetails(
    BuildContext context,
    QueryDocumentSnapshot workout,
  ) {
    final data = workout.data() as Map<String, dynamic>? ?? {};
    final description = (data['description'] as String?) ?? '';
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WorkoutPage(
          workoutId: workout.id,
          workoutType: data['type'] as String,
          workoutDescription: description,
        ),
      ),
    );
  }

  static void _openUserDestination(NavigatorState navigator) {
    final user = FirebaseAuth.instance.currentUser;
    navigator.push(
      MaterialPageRoute(
        builder: (_) => user == null ? const LoginPage() : const UserPage(),
      ),
    );
  }
}
