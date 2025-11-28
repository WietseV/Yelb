import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../utils/navigation_utils.dart';

enum AppNavDestination { home, workouts, user, settings }

class AppBottomNavBar extends StatelessWidget {
  final AppNavDestination? current;
  final void Function(AppNavDestination destination)? onNavigate;

  const AppBottomNavBar({
    super.key,
    required this.current,
    this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      _NavItem(AppNavDestination.settings, Icons.settings, 'Settings'),
      _NavItem(AppNavDestination.user, Icons.person, 'You'),
      _NavItem(AppNavDestination.home, Icons.home, 'Home'),
      _NavItem(AppNavDestination.workouts, Icons.fitness_center, 'Workouts'),
    ];

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: items.map((item) {
              final isActive = current == item.destination;
              final color = isActive
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6);

              return Expanded(
                child: InkWell(
                  onTap: () => _handleTap(context, item.destination, isActive),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 4.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(item.icon, color: color),
                        const SizedBox(height: 2),
                        Text(
                          item.label,
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: color,
                                    fontWeight: isActive
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _handleTap(
      BuildContext context, AppNavDestination destination, bool isActive) {
    if (onNavigate != null) {
      onNavigate!(destination);
      return;
    }
    NavigationUtils.handleBottomNav(context, destination);
  }
}

class _NavItem {
  final AppNavDestination destination;
  final IconData icon;
  final String label;

  const _NavItem(this.destination, this.icon, this.label);
}
