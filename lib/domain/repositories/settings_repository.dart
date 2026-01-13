import 'package:flutter/material.dart';

/// Repository interface for settings operations
abstract class SettingsRepository {
  /// Get current theme mode
  Future<ThemeMode> getThemeMode();

  /// Set theme mode
  Future<void> setThemeMode(ThemeMode mode);

  /// Get sound enabled state
  Future<bool> getSoundEnabled();

  /// Set sound enabled state
  Future<void> setSoundEnabled(bool enabled);

  /// Get daily goal (words per day)
  Future<int> getDailyGoal();

  /// Set daily goal
  Future<void> setDailyGoal(int goal);
}
