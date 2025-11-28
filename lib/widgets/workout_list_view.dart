import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

import 'slidable_action_pane.dart';

class WorkoutListView extends StatelessWidget {
  final Stream<QuerySnapshot> stream;
  final DateFormat dateFormat;
  final void Function(QueryDocumentSnapshot workout) onWorkoutTap;
  final void Function(String workoutId, String type, String location)?
      onEditWorkout;
  final void Function(String workoutId)? onDeleteWorkout;
  final Duration? recentWindow;
  final EdgeInsetsGeometry cardPadding;
  final EdgeInsetsGeometry cardMargin;
  final String emptyMessage;
  final String groupTag;
  final double slidableActionWidth;
  final EdgeInsetsGeometry listPadding;

  const WorkoutListView({
    super.key,
    required this.stream,
    required this.dateFormat,
    required this.onWorkoutTap,
    this.onEditWorkout,
    this.onDeleteWorkout,
    this.recentWindow,
    this.cardPadding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    this.cardMargin = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    this.emptyMessage = 'No workouts yet.',
    this.groupTag = 'workouts',
    this.slidableActionWidth = 108.0,
    this.listPadding = EdgeInsets.zero,
  });

  bool get _showActions => onEditWorkout != null && onDeleteWorkout != null;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        List<QueryDocumentSnapshot> workouts = snapshot.data!.docs;

        if (recentWindow != null) {
          final cutoff = DateTime.now().subtract(recentWindow!);
          workouts = workouts.where((doc) {
            final timestamp = doc['date'] as Timestamp?;
            if (timestamp == null) return false;
            return timestamp.toDate().isAfter(cutoff);
          }).toList();
        }

        if (workouts.isEmpty) {
          return Center(child: Text(emptyMessage));
        }

        return SlidableAutoCloseBehavior(
          child: ListView.builder(
            padding: listPadding,
            itemCount: workouts.length,
            itemBuilder: (context, index) {
              final workout = workouts[index];
              return Padding(
                padding: cardPadding,
                child: _WorkoutCard(
                  workout: workout,
                  dateFormat: dateFormat,
                  showActions: _showActions,
                  onWorkoutTap: onWorkoutTap,
                  onEditWorkout: onEditWorkout,
                  onDeleteWorkout: onDeleteWorkout,
                  groupTag: groupTag,
                  slidableActionWidth: slidableActionWidth,
                  margin: cardMargin,
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _WorkoutCard extends StatelessWidget {
  final QueryDocumentSnapshot workout;
  final DateFormat dateFormat;
  final bool showActions;
  final void Function(QueryDocumentSnapshot workout) onWorkoutTap;
  final void Function(String workoutId, String type, String location)?
      onEditWorkout;
  final void Function(String workoutId)? onDeleteWorkout;
  final String groupTag;
  final double slidableActionWidth;
  final EdgeInsetsGeometry margin;

  const _WorkoutCard({
    required this.workout,
    required this.dateFormat,
    required this.showActions,
    required this.onWorkoutTap,
    this.onEditWorkout,
    this.onDeleteWorkout,
    required this.groupTag,
    required this.slidableActionWidth,
    required this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final date = (workout['date'] as Timestamp).toDate();
    final card = Card(
      margin: margin,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        title: Text(workout['type']),
        subtitle: Text("${workout['location']} • ${dateFormat.format(date)}"),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () => onWorkoutTap(workout),
      ),
    );

    if (!showActions) {
      return card;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final ratio =
            (slidableActionWidth / constraints.maxWidth).clamp(0.2, 0.35);
        return Slidable(
          key: ValueKey(workout.id),
          groupTag: groupTag,
          endActionPane: buildSlidableActionPane(
            context,
            extentRatio: ratio,
            onEdit: () => onEditWorkout!(
              workout.id,
              workout['type'],
              workout['location'],
            ),
            onDelete: () => onDeleteWorkout!(workout.id),
            buttonSize: 52,
          ),
          child: card,
        );
      },
    );
  }
}
