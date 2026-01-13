import '../entities/entities.dart';
import '../repositories/progress_repository.dart';
import '../repositories/word_repository.dart';

/// Statistics data class
class LearningStats {
  final int currentLevel;
  final int totalWords;
  final int level1Completed;
  final int level2Learned;
  final int totalCorrectAnswers;
  final double overallProgressPercent;
  final int todayCorrect;
  final int dayStreak;
  final int dailyGoal;

  const LearningStats({
    required this.currentLevel,
    required this.totalWords,
    required this.level1Completed,
    required this.level2Learned,
    required this.totalCorrectAnswers,
    required this.overallProgressPercent,
    this.todayCorrect = 0,
    this.dayStreak = 0,
    this.dailyGoal = 10,
  });

  /// Daily goal progress (0.0 - 1.0)
  double get dailyProgress =>
      dailyGoal > 0 ? (todayCorrect / dailyGoal).clamp(0.0, 1.0) : 1.0;

  /// Whether daily goal is met
  bool get dailyGoalMet => todayCorrect >= dailyGoal;
}

/// Use case for calculating learning statistics
class CalculateProgressUseCase {
  final ProgressRepository _progressRepository;
  final WordRepository _wordRepository;

  CalculateProgressUseCase(this._progressRepository, this._wordRepository);

  /// Get comprehensive learning statistics
  Future<LearningStats> call({int dailyGoal = 10}) async {
    final userProgress = await _progressRepository.getUserProgress();
    final level1Count = await _progressRepository.countLevel1Completed();
    final learnedCount = await _progressRepository.countLearnedWords();
    final totalWords = await _wordRepository.getWordCount();

    // Calculate overall progress (10% for Level 1, 90% for Level 2)
    double overallProgress = 0;
    if (totalWords > 0) {
      final level1Progress = level1Count / totalWords * 0.1;
      final level2Progress = learnedCount / totalWords * 0.9;
      overallProgress = level1Progress + level2Progress;
    }

    // Check if today's data needs reset
    final today = DateTime.now().toIso8601String().substring(0, 10);
    int todayCorrect = userProgress.todayCorrect;
    if (userProgress.lastPracticeDate != today) {
      todayCorrect = 0; // New day, show 0
    }

    return LearningStats(
      currentLevel: userProgress.currentLevel,
      totalWords: totalWords,
      level1Completed: level1Count,
      level2Learned: learnedCount,
      totalCorrectAnswers: userProgress.totalCorrect,
      overallProgressPercent: overallProgress,
      todayCorrect: todayCorrect,
      dayStreak: userProgress.dayStreak,
      dailyGoal: dailyGoal,
    );
  }

  /// Get progress for a specific word
  Future<WordProgress?> getWordProgress(String wordId) async {
    return _progressRepository.getWordProgress(wordId);
  }
}
