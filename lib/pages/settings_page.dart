import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../settings/app_settings.dart';
import '../utils/navigation_utils.dart';
import '../widgets/app_bottom_nav_bar.dart';
import '../widgets/app_gradient_background.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: AppBottomNavBar(
        current: AppNavDestination.settings,
        onNavigate: (destination) =>
            NavigationUtils.handleBottomNav(context, destination),
      ),
      body: AppGradientBackground(
        padding: const EdgeInsets.all(20),
        child: Consumer<AppSettings>(
          builder: (context, settings, _) => ListView(
            children: [
              Text('Units', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              SegmentedButton<WeightUnit>(
                segments: const [
                  ButtonSegment(value: WeightUnit.kg, label: Text('Kilograms')),
                  ButtonSegment(value: WeightUnit.lbs, label: Text('Pounds')),
                ],
                selected: {settings.weightUnit},
                onSelectionChanged: (value) =>
                    settings.setWeightUnit(value.first),
              ),
              const SizedBox(height: 24),
              Text('Accent Color',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                children: settings.accentOptions
                    .map(
                      (color) => GestureDetector(
                        onTap: () => settings.setAccentColor(color),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: color,
                            border: Border.all(
                              color: settings.accentColor == color
                                  ? Colors.white
                                  : Colors.transparent,
                              width: 3,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 24),
              SwitchListTile(
                title: const Text('Show Week Overview'),
                value: settings.showWeekOverview,
                onChanged: settings.toggleWeekOverview,
              ),
              SwitchListTile(
                title: const Text('24-hour Time'),
                value: settings.use24HourFormat,
                onChanged: settings.toggleTimeFormat,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
