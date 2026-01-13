import 'package:flutter/material.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/hive_local_datasource.dart';

/// Implementation of SettingsRepository using Hive
class SettingsRepositoryImpl implements SettingsRepository {
  final HiveLocalDataSource _dataSource;

  SettingsRepositoryImpl(this._dataSource);

  ThemeMode _intToThemeMode(int value) {
    switch (value) {
      case 1:
        return ThemeMode.light;
      case 2:
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  int _themeModeToInt(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 1;
      case ThemeMode.dark:
        return 2;
      case ThemeMode.system:
        return 0;
    }
  }

  @override
  Future<ThemeMode> getThemeMode() async {
    final settings = _dataSource.getSettings();
    return _intToThemeMode(settings.themeMode);
  }

  @override
  Future<void> setThemeMode(ThemeMode mode) async {
    final settings = _dataSource.getSettings();
    settings.themeMode = _themeModeToInt(mode);
    await _dataSource.saveSettings(settings);
  }

  @override
  Future<bool> getSoundEnabled() async {
    final settings = _dataSource.getSettings();
    return settings.soundEnabled;
  }

  @override
  Future<void> setSoundEnabled(bool enabled) async {
    final settings = _dataSource.getSettings();
    settings.soundEnabled = enabled;
    await _dataSource.saveSettings(settings);
  }

  @override
  Future<int> getDailyGoal() async {
    final settings = _dataSource.getSettings();
    return settings.dailyGoal;
  }

  @override
  Future<void> setDailyGoal(int goal) async {
    final settings = _dataSource.getSettings();
    settings.dailyGoal = goal;
    await _dataSource.saveSettings(settings);
  }
}
