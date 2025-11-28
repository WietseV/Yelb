import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../theme/app_colors.dart';

enum WeightUnit { kg, lbs }

class AppSettings extends ChangeNotifier {
  WeightUnit weightUnit = WeightUnit.kg;
  Color accentColor = AppColors.accent;
  bool showWeekOverview = true;
  bool use24HourFormat = true;

  List<Color> get accentOptions => const [
        AppColors.accent,
        Color(0xFF7E57C2),
        Color(0xFF26A69A),
        Color(0xFFFF8A65),
      ];

  void setWeightUnit(WeightUnit unit) {
    if (weightUnit == unit) return;
    weightUnit = unit;
    notifyListeners();
  }

  void setAccentColor(Color color) {
    accentColor = color;
    notifyListeners();
  }

  void toggleWeekOverview(bool value) {
    showWeekOverview = value;
    notifyListeners();
  }

  void toggleTimeFormat(bool value) {
    use24HourFormat = value;
    notifyListeners();
  }

  String get weightUnitLabel => weightUnit == WeightUnit.kg ? 'kg' : 'lbs';

  List<double> get weightSteps =>
      weightUnit == WeightUnit.kg ? [1, 2.5, 5, 10] : [2, 5, 10, 20];

  double convertStorageToDisplay(double value) =>
      weightUnit == WeightUnit.kg ? value : value * 2.20462;

  double convertDisplayToStorage(double value) =>
      weightUnit == WeightUnit.kg ? value : value / 2.20462;

  String formatWeight(double storageValue) {
    final converted = convertStorageToDisplay(storageValue);
    return '${converted.toStringAsFixed(2)} $weightUnitLabel';
  }

  DateFormat get workoutDateFormat => DateFormat(
      use24HourFormat ? 'dd-MM-yyyy HH:mm' : 'dd-MM-yyyy h:mm a');
}
