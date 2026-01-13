import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/models.dart';
import '../../data/datasources/datasources.dart';
import '../../data/repositories/repositories.dart';
import '../../domain/repositories/repositories.dart';
import '../../domain/usecases/usecases.dart';
import '../../core/utils/audio_service.dart';
import 'settings_providers.dart';

/// Provider for Hive initialization
final hiveProvider = FutureProvider<HiveLocalDataSource>((ref) async {
  await Hive.initFlutter();

  // Register adapters
  Hive.registerAdapter(WordModelAdapter());
  Hive.registerAdapter(WordProgressModelAdapter());
  Hive.registerAdapter(UserProgressModelAdapter());
  Hive.registerAdapter(SettingsModelAdapter());

  final dataSource = HiveLocalDataSource();
  await dataSource.init();
  return dataSource;
});

/// Provider for local data source
final localDataSourceProvider = Provider<HiveLocalDataSource>((ref) {
  return ref.watch(hiveProvider).requireValue;
});

/// Provider for WordRepository
final wordRepositoryProvider = Provider<WordRepository>((ref) {
  final dataSource = ref.watch(localDataSourceProvider);
  return WordRepositoryImpl(dataSource);
});

/// Provider for ProgressRepository
final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  final dataSource = ref.watch(localDataSourceProvider);
  return ProgressRepositoryImpl(dataSource);
});

/// Provider for SettingsRepository
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final dataSource = ref.watch(localDataSourceProvider);
  return SettingsRepositoryImpl(dataSource);
});

/// Provider for GetNextWordUseCase
final getNextWordUseCaseProvider = Provider<GetNextWordUseCase>((ref) {
  final wordRepo = ref.watch(wordRepositoryProvider);
  final progressRepo = ref.watch(progressRepositoryProvider);
  return GetNextWordUseCase(wordRepo, progressRepo);
});

/// Provider for CheckAnswerUseCase
final checkAnswerUseCaseProvider = Provider<CheckAnswerUseCase>((ref) {
  return CheckAnswerUseCase();
});

/// Provider for UpdateProgressUseCase
final updateProgressUseCaseProvider = Provider<UpdateProgressUseCase>((ref) {
  final progressRepo = ref.watch(progressRepositoryProvider);
  return UpdateProgressUseCase(progressRepo);
});

/// Provider for CalculateProgressUseCase
final calculateProgressUseCaseProvider = Provider<CalculateProgressUseCase>((
  ref,
) {
  final progressRepo = ref.watch(progressRepositoryProvider);
  final wordRepo = ref.watch(wordRepositoryProvider);
  return CalculateProgressUseCase(progressRepo, wordRepo);
});

/// Provider for AudioService
final audioServiceProvider = Provider<AudioService>((ref) {
  final service = AudioService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Provider for learning statistics (auto-refreshing)
final statsProvider = FutureProvider<LearningStats>((ref) async {
  final calculateProgress = ref.watch(calculateProgressUseCaseProvider);
  final dailyGoal = ref.watch(dailyGoalProvider);
  return calculateProgress(dailyGoal: dailyGoal);
});
