import 'package:hive/hive.dart';

part 'settings_model.g.dart';

/// Hive model for app settings
@HiveType(typeId: 2)
class SettingsModel extends HiveObject {
  @HiveField(0)
  int themeMode = 0;

  @HiveField(1)
  bool soundEnabled = true;

  /// Daily goal: target number of words per day
  @HiveField(2)
  int dailyGoal = 10;

  SettingsModel();
}
