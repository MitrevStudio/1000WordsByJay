import '../entities/entities.dart';
import '../repositories/progress_repository.dart';
import '../../core/utils/spaced_repetition_service.dart';
import '../../core/utils/daily_goal_service.dart';

/// Use case for updating progress after an answer
class UpdateProgressUseCase {
  final ProgressRepository _progressRepository;
  final SpacedRepetitionService _srsService = SpacedRepetitionService();
  final DailyGoalService _dailyGoalService = DailyGoalService();

  UpdateProgressUseCase(this._progressRepository);

  /// Update progress for Level 1 (mark word as introduced)
  /// Returns whether daily goal was just completed
  Future<bool> updateLevel1Progress({
    required String wordId,
    required bool isCorrect,
    required int dailyGoal,
  }) async {
    if (!isCorrect) return false;

    // Get existing progress or create new
    final existing = await _progressRepository.getWordProgress(wordId);
    final progress = existing ?? WordProgress(wordId: wordId);

    // Mark as completed in Level 1
    final updated = progress.copyWith(
      level1Completed: true,
      lastAnswered: DateTime.now(),
    );

    await _progressRepository.saveWordProgress(updated);

    // Update user progress with daily goal tracking
    final userProgress = await _progressRepository.getUserProgress();
    final level1Count = await _progressRepository.countLevel1Completed();

    // Check for new day and update daily progress
    final dayCheck = _dailyGoalService.checkNewDay(
      todayCorrect: userProgress.todayCorrect,
      lastPracticeDate: userProgress.lastPracticeDate,
      dayStreak: userProgress.dayStreak,
      dailyGoal: dailyGoal,
    );

    // Record correct answer for daily goal
    final dailyResult = _dailyGoalService.recordCorrectAnswer(
      todayCorrect: dayCheck.todayCorrect,
      dayStreak: dayCheck.dayStreak,
      dailyGoal: dailyGoal,
    );

    await _progressRepository.saveUserProgress(
      userProgress.copyWith(
        level1WordsCompleted: level1Count,
        totalCorrect: userProgress.totalCorrect + 1,
        todayCorrect: dailyResult.todayCorrect,
        lastPracticeDate: dayCheck.lastPracticeDate,
        dayStreak: dailyResult.dayStreak,
      ),
    );

    return dailyResult.goalJustCompleted;
  }

  /// Update progress for Level 2 (track repeated correct answers with SRS)
  /// Returns whether daily goal was just completed
  Future<bool> updateLevel2Progress({
    required String wordId,
    required bool isCorrect,
    required LearningMode mode,
    required int attemptNumber,
    required int dailyGoal,
    int? responseTimeMs,
  }) async {
    // Get existing progress or create new
    final existing = await _progressRepository.getWordProgress(wordId);
    final progress =
        existing ?? WordProgress(wordId: wordId, level1Completed: true);

    // Calculate SRS quality score
    final quality = _srsService.calculateQuality(
      isCorrect: isCorrect,
      attemptNumber: attemptNumber,
      responseTimeMs: responseTimeMs,
    );

    // Calculate new SRS values
    final srsResult = _srsService.calculate(
      quality: quality,
      currentEaseFactor: progress.easeFactor,
      currentInterval: progress.interval,
      consecutiveCorrect: progress.consecutiveCorrect,
    );

    // Update progress
    WordProgress updated;
    if (isCorrect) {
      updated = progress.copyWith(
        correctCount: progress.correctCount + 1,
        enToBgCount: mode == LearningMode.enToBg
            ? progress.enToBgCount + 1
            : progress.enToBgCount,
        bgToEnCount: mode == LearningMode.bgToEn
            ? progress.bgToEnCount + 1
            : progress.bgToEnCount,
        lastAnswered: DateTime.now(),
        easeFactor: srsResult.easeFactor,
        interval: srsResult.interval,
        nextReviewDate: srsResult.nextReviewDate,
        consecutiveCorrect: srsResult.consecutiveCorrect,
      );
    } else {
      // Wrong answer - update SRS but don't increment correct counts
      updated = progress.copyWith(
        lastAnswered: DateTime.now(),
        easeFactor: srsResult.easeFactor,
        interval: srsResult.interval,
        nextReviewDate: srsResult.nextReviewDate,
        consecutiveCorrect: srsResult.consecutiveCorrect,
      );
    }

    await _progressRepository.saveWordProgress(updated);

    // Update user progress with daily goal tracking
    final userProgress = await _progressRepository.getUserProgress();
    final learnedCount = await _progressRepository.countLearnedWords();

    // Check for new day
    final dayCheck = _dailyGoalService.checkNewDay(
      todayCorrect: userProgress.todayCorrect,
      lastPracticeDate: userProgress.lastPracticeDate,
      dayStreak: userProgress.dayStreak,
      dailyGoal: dailyGoal,
    );

    bool goalJustCompleted = false;
    int newTodayCorrect = dayCheck.todayCorrect;
    int newDayStreak = dayCheck.dayStreak;

    if (isCorrect) {
      // Record correct answer for daily goal
      final dailyResult = _dailyGoalService.recordCorrectAnswer(
        todayCorrect: dayCheck.todayCorrect,
        dayStreak: dayCheck.dayStreak,
        dailyGoal: dailyGoal,
      );
      newTodayCorrect = dailyResult.todayCorrect;
      newDayStreak = dailyResult.dayStreak;
      goalJustCompleted = dailyResult.goalJustCompleted;
    }

    await _progressRepository.saveUserProgress(
      userProgress.copyWith(
        level2WordsLearned: learnedCount,
        totalCorrect: isCorrect
            ? userProgress.totalCorrect + 1
            : userProgress.totalCorrect,
        todayCorrect: newTodayCorrect,
        lastPracticeDate: dayCheck.lastPracticeDate,
        dayStreak: newDayStreak,
      ),
    );

    return goalJustCompleted;
  }

  /// Advance user to Level 2 if Level 1 is complete
  Future<bool> checkAndAdvanceLevel() async {
    final userProgress = await _progressRepository.getUserProgress();

    if (userProgress.currentLevel == 1 && userProgress.isLevel1Complete) {
      await _progressRepository.saveUserProgress(
        userProgress.copyWith(currentLevel: 2),
      );
      return true; // Level advanced
    }

    return false;
  }

  /// Record a word skip (user didn't know the word) - resets SRS
  Future<void> recordSkip({required String wordId}) async {
    // Get existing progress or create new
    final existing = await _progressRepository.getWordProgress(wordId);
    final progress = existing ?? WordProgress(wordId: wordId);

    // Calculate SRS for a complete fail (quality = 0)
    final srsResult = _srsService.calculate(
      quality: 0,
      currentEaseFactor: progress.easeFactor,
      currentInterval: progress.interval,
      consecutiveCorrect: progress.consecutiveCorrect,
    );

    // Increment skip count and reset SRS
    final updated = progress.copyWith(
      skipCount: progress.skipCount + 1,
      lastAnswered: DateTime.now(),
      easeFactor: srsResult.easeFactor,
      interval: srsResult.interval,
      nextReviewDate: srsResult.nextReviewDate,
      consecutiveCorrect: 0,
    );

    await _progressRepository.saveWordProgress(updated);
  }
}
