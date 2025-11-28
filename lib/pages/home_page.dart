import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:yelb/theme/app_colors.dart';

import '../data/workout_data.dart';
import '../settings/app_settings.dart';
import '../widgets/app_gradient_background.dart';
import '../widgets/app_bottom_nav_bar.dart';
import '../utils/navigation_utils.dart';
import '../widgets/workout_list_view.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const EdgeInsets _screenPadding = EdgeInsets.all(20);
  static const double _bannerHeight = 140;
  static const String _weekOverviewTitle = 'Last 7 Days';
  static const String _workoutButtonLabel = 'Let\'s go';
  static const String _recentWorkoutsTitle = 'Recent Workouts';
  static const String _noRecentWorkoutsMessage = 'No recent workouts.';
  static const String _welcomeBannerMessage =
      'Track your progress and crush your next session.';
  static const double _borderRadius = 16;
  static const double _bannerPadding = 20;

  @override
  Widget build(BuildContext context) {
    final workoutData = context.read<WorkoutData>();
    final settings = context.watch<AppSettings>();
    final dateFormat = settings.workoutDateFormat;

    return Scaffold(
      bottomNavigationBar: AppBottomNavBar(
        current: AppNavDestination.home,
        onNavigate: (destination) =>
            NavigationUtils.handleBottomNav(context, destination),
      ),
      body: AppGradientBackground(
        padding: _screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBanner(context),
            const SizedBox(height: 24),
            if (settings.showWeekOverview) ...[
              Text(
                _weekOverviewTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              _WeekOverview(stream: workoutData.getWorkoutsStream()),
              const SizedBox(height: 16),
            ],
            Text(
              _recentWorkoutsTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: WorkoutListView(
                stream: workoutData.getWorkoutsStream(),
                dateFormat: dateFormat,
                onWorkoutTap: (workout) =>
                    NavigationUtils.openWorkoutDetails(context, workout),
                recentWindow: const Duration(days: 7),
                emptyMessage: _noRecentWorkoutsMessage,
                cardPadding: const EdgeInsets.only(bottom: 8),
                cardMargin: EdgeInsets.zero,
                listPadding: EdgeInsets.zero,
                groupTag: 'home_workouts',
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => NavigationUtils.handleBottomNav(
                  context,
                  AppNavDestination.workouts,
                ),
                icon: const Icon(Icons.fitness_center),
                label: Text(_workoutButtonLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBanner(BuildContext context) {
    return Container(
      height: _bannerHeight,
      padding: const EdgeInsets.all(_bannerPadding),
      decoration: BoxDecoration(
        color: AppColors.secondaryMuted,
        borderRadius: BorderRadius.circular(_borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Welcome Back',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const Icon(Icons.fitness_center,
                  color: AppColors.primary, size: 40),
            ],
          ),
          const Spacer(),
          Text(
            _welcomeBannerMessage,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _WeekOverview extends StatelessWidget {
  final Stream<QuerySnapshot> stream;

  static const double _circleSize = 48;

  const _WeekOverview({required this.stream});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        final docs = snapshot.data?.docs ?? [];
        final workoutDays = docs
            .map((doc) => (doc['date'] as Timestamp).toDate())
            .map((date) => DateTime(date.year, date.month, date.day))
            .toSet();

        final now = DateTime.now();
        final days = List.generate(7, (index) {
          final day = now.subtract(Duration(days: 6 - index));
          return DateTime(day.year, day.month, day.day);
        });

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: days.map((day) {
            final hasWorkout = workoutDays.any((d) => _isSameDay(d, day));
            return Expanded(
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _circleSize,
                    height: _circleSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: hasWorkout
                            ? AppColors.confirmed
                            : AppColors.primaryMuted,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: hasWorkout
                          ? Icon(Icons.check_outlined,
                              color: AppColors.confirmed)
                          : Text(
                              '${day.day}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('EEE').format(day),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
