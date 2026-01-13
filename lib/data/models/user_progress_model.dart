import 'package:hive/hive.dart';

part 'user_progress_model.g.dart';

/// Hive model for storing overall user progress
@HiveType(typeId: 3)
class UserProgressModel extends HiveObject {
  @HiveField(0)
  int currentLevel = 1;

  @HiveField(1)
  int totalCorrect = 0;

  @HiveField(2)
  int level1WordsCompleted = 0;

  @HiveField(3)
  int level2WordsLearned = 0;

  /// Daily goal: correct answers today
  @HiveField(4)
  int todayCorrect = 0;

  /// Last practice date (ISO string for easy comparison)
  @HiveField(5)
  String? lastPracticeDate;

  /// Consecutive days with daily goal met
  @HiveField(6)
  int dayStreak = 0;

  UserProgressModel();

  /// Check if Level 1 is complete
  bool get isLevel1Complete => level1WordsCompleted >= 1000;

  /// Check if Level 2 is complete (all words learned)
  bool get isLevel2Complete => level2WordsLearned >= 1000;

  /// Check if today's practice date matches
  bool get isPracticedToday {
    if (lastPracticeDate == null) return false;
    final today = DateTime.now().toIso8601String().substring(0, 10);
    return lastPracticeDate == today;
  }
}
