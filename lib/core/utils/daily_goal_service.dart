/// Service for tracking daily learning goals and streaks
class DailyGoalService {
  /// Check if a new day has started and reset daily counter if needed
  ///
  /// Returns updated values as a record
  /// [todayCorrect] - current today's correct count
  /// [lastPracticeDate] - ISO date string of last practice
  /// [dayStreak] - current day streak
  /// [dailyGoal] - target words per day
  ({int todayCorrect, String lastPracticeDate, int dayStreak}) checkNewDay({
    required int todayCorrect,
    required String? lastPracticeDate,
    required int dayStreak,
    required int dailyGoal,
  }) {
    final today = _getToday();

    if (lastPracticeDate == null) {
      // First time ever
      return (todayCorrect: 0, lastPracticeDate: today, dayStreak: 0);
    }

    if (lastPracticeDate == today) {
      // Same day, no changes needed
      return (
        todayCorrect: todayCorrect,
        lastPracticeDate: lastPracticeDate,
        dayStreak: dayStreak,
      );
    }

    // New day started
    final yesterday = _getYesterday();
    final metGoalYesterday =
        lastPracticeDate == yesterday && todayCorrect >= dailyGoal;

    // Check if we need to continue or break streak
    int newStreak;
    if (lastPracticeDate == yesterday) {
      // Practiced yesterday
      newStreak = metGoalYesterday ? dayStreak : 0;
    } else {
      // Missed a day - streak broken
      newStreak = 0;
    }

    return (
      todayCorrect: 0, // Reset for new day
      lastPracticeDate: today,
      dayStreak: newStreak,
    );
  }

  /// Record a correct answer and check if daily goal is met
  ///
  /// Returns updated values and whether goal was just completed
  ({int todayCorrect, int dayStreak, bool goalJustCompleted})
  recordCorrectAnswer({
    required int todayCorrect,
    required int dayStreak,
    required int dailyGoal,
  }) {
    final newTodayCorrect = todayCorrect + 1;
    final goalJustCompleted =
        todayCorrect < dailyGoal && newTodayCorrect >= dailyGoal;

    int newDayStreak = dayStreak;
    if (goalJustCompleted) {
      newDayStreak = dayStreak + 1;
    }

    return (
      todayCorrect: newTodayCorrect,
      dayStreak: newDayStreak,
      goalJustCompleted: goalJustCompleted,
    );
  }

  /// Get today's date as ISO string (YYYY-MM-DD)
  String _getToday() {
    return DateTime.now().toIso8601String().substring(0, 10);
  }

  /// Get yesterday's date as ISO string (YYYY-MM-DD)
  String _getYesterday() {
    return DateTime.now()
        .subtract(const Duration(days: 1))
        .toIso8601String()
        .substring(0, 10);
  }

  /// Calculate progress towards daily goal (0.0 - 1.0)
  double calculateProgress(int todayCorrect, int dailyGoal) {
    if (dailyGoal <= 0) return 1.0;
    return (todayCorrect / dailyGoal).clamp(0.0, 1.0);
  }
}
