/// Domain entity representing overall user progress
class UserProgress {
  final int currentLevel;
  final int totalCorrect;
  final int level1WordsCompleted;
  final int level2WordsLearned;

  /// Daily goal: correct answers today
  final int todayCorrect;

  /// Last practice date (ISO string YYYY-MM-DD)
  final String? lastPracticeDate;

  /// Consecutive days with daily goal met
  final int dayStreak;

  const UserProgress({
    this.currentLevel = 1,
    this.totalCorrect = 0,
    this.level1WordsCompleted = 0,
    this.level2WordsLearned = 0,
    this.todayCorrect = 0,
    this.lastPracticeDate,
    this.dayStreak = 0,
  });

  /// Check if Level 1 is complete
  bool get isLevel1Complete => level1WordsCompleted >= 1000;

  /// Check if Level 2 is complete
  bool get isLevel2Complete => level2WordsLearned >= 1000;

  /// Check if practiced today
  bool get isPracticedToday {
    if (lastPracticeDate == null) return false;
    final today = DateTime.now().toIso8601String().substring(0, 10);
    return lastPracticeDate == today;
  }

  /// Overall progress percentage (0.0 - 1.0)
  double get overallProgress {
    if (currentLevel == 1) {
      return level1WordsCompleted / 1000 * 0.1; // Level 1 = 10% of total
    }
    return 0.1 + (level2WordsLearned / 1000 * 0.9); // Level 2 = 90% of total
  }

  UserProgress copyWith({
    int? currentLevel,
    int? totalCorrect,
    int? level1WordsCompleted,
    int? level2WordsLearned,
    int? todayCorrect,
    String? lastPracticeDate,
    int? dayStreak,
  }) {
    return UserProgress(
      currentLevel: currentLevel ?? this.currentLevel,
      totalCorrect: totalCorrect ?? this.totalCorrect,
      level1WordsCompleted: level1WordsCompleted ?? this.level1WordsCompleted,
      level2WordsLearned: level2WordsLearned ?? this.level2WordsLearned,
      todayCorrect: todayCorrect ?? this.todayCorrect,
      lastPracticeDate: lastPracticeDate ?? this.lastPracticeDate,
      dayStreak: dayStreak ?? this.dayStreak,
    );
  }
}
