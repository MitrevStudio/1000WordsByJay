import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_providers.dart';

/// State for theme mode
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((
  ref,
) {
  return ThemeModeNotifier(ref);
});

/// Notifier for managing theme mode
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final Ref _ref;

  ThemeModeNotifier(this._ref) : super(ThemeMode.system) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    try {
      final settingsRepo = _ref.read(settingsRepositoryProvider);
      state = await settingsRepo.getThemeMode();
    } catch (_) {
      // Database not ready yet, use default
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    try {
      final settingsRepo = _ref.read(settingsRepositoryProvider);
      await settingsRepo.setThemeMode(mode);
    } catch (_) {
      // Ignore if not ready
    }
  }
}

/// State for sound enabled
final soundEnabledProvider = StateNotifierProvider<SoundEnabledNotifier, bool>((
  ref,
) {
  return SoundEnabledNotifier(ref);
});

/// Notifier for managing sound enabled state
class SoundEnabledNotifier extends StateNotifier<bool> {
  final Ref _ref;

  SoundEnabledNotifier(this._ref) : super(true) {
    _loadSetting();
  }

  Future<void> _loadSetting() async {
    try {
      final settingsRepo = _ref.read(settingsRepositoryProvider);
      state = await settingsRepo.getSoundEnabled();
      _ref.read(audioServiceProvider).soundEnabled = state;
    } catch (_) {
      // Database not ready yet, use default
    }
  }

  Future<void> setSoundEnabled(bool enabled) async {
    state = enabled;
    _ref.read(audioServiceProvider).soundEnabled = enabled;
    try {
      final settingsRepo = _ref.read(settingsRepositoryProvider);
      await settingsRepo.setSoundEnabled(enabled);
    } catch (_) {
      // Ignore if not ready
    }
  }
}

/// State for daily goal
final dailyGoalProvider = StateNotifierProvider<DailyGoalNotifier, int>((ref) {
  return DailyGoalNotifier(ref);
});

/// Notifier for managing daily goal setting
class DailyGoalNotifier extends StateNotifier<int> {
  final Ref _ref;

  DailyGoalNotifier(this._ref) : super(10) {
    _loadSetting();
  }

  Future<void> _loadSetting() async {
    try {
      final settingsRepo = _ref.read(settingsRepositoryProvider);
      state = await settingsRepo.getDailyGoal();
    } catch (_) {
      // Database not ready yet, use default
    }
  }

  Future<void> setDailyGoal(int goal) async {
    state = goal;
    try {
      final settingsRepo = _ref.read(settingsRepositoryProvider);
      await settingsRepo.setDailyGoal(goal);
    } catch (_) {
      // Ignore if not ready
    }
  }
}
