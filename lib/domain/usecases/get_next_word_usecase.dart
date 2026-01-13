import 'dart:math';
import '../entities/entities.dart';
import '../repositories/repositories.dart';
import '../../core/constants/app_constants.dart';

/// Use case for getting the next word to practice
class GetNextWordUseCase {
  final WordRepository _wordRepository;
  final ProgressRepository _progressRepository;
  final Random _random = Random();

  GetNextWordUseCase(this._wordRepository, this._progressRepository);

  /// Get next word for Level 1 (introduction)
  /// Returns a word that hasn't been completed in Level 1 yet
  /// Optionally filter by category
  Future<Word?> getNextLevel1Word({String? category}) async {
    var incompleteWords = await _progressRepository.getLevel1IncompleteWords();

    // Filter by category if specified
    if (category != null && category.isNotEmpty) {
      incompleteWords = incompleteWords
          .where((w) => w.category == category)
          .toList();
    }

    if (incompleteWords.isEmpty) return null;

    // Return random word from incomplete list
    return incompleteWords[_random.nextInt(incompleteWords.length)];
  }

  /// Get next word for Level 2 (reinforcement)
  /// Uses SRS algorithm: prioritize words due for review
  /// Optionally filter by category
  Future<(Word, LearningMode)?> getNextLevel2Word({String? category}) async {
    var allWords = await _wordRepository.getAllWords();
    final allProgress = await _progressRepository.getAllWordProgress();

    // Filter by category if specified
    if (category != null && category.isNotEmpty) {
      allWords = allWords.where((w) => w.category == category).toList();
    }

    // Create map of wordId -> progress
    final progressMap = <String, WordProgress>{};
    for (final p in allProgress) {
      progressMap[p.wordId] = p;
    }

    // Filter to words that:
    // 1. Have completed Level 1 (level1Completed == true)
    // 2. Still need more practice (not fully learned)
    final needsPractice = <Word>[];
    for (final word in allWords) {
      final progress = progressMap[word.id];
      // Only include words that passed Level 1
      if (progress != null && progress.level1Completed && !progress.isLearned) {
        needsPractice.add(word);
      }
    }

    if (needsPractice.isEmpty) return null;

    // Separate words due for review vs not yet due
    final dueForReview = <Word>[];
    final notYetDue = <Word>[];

    for (final word in needsPractice) {
      final progress = progressMap[word.id];
      if (progress != null && progress.isDueForReview) {
        dueForReview.add(word);
      } else {
        notYetDue.add(word);
      }
    }

    // Prioritize due words, fall back to not yet due
    final wordsToScore = dueForReview.isNotEmpty ? dueForReview : notYetDue;

    // Calculate priority scores using SRS + legacy factors
    final scored = <({Word word, double score, LearningMode mode})>[];
    final now = DateTime.now();

    for (final word in wordsToScore) {
      final progress = progressMap[word.id];
      double score = 0;

      // SRS priority: overdue words get higher score
      if (progress?.nextReviewDate != null) {
        final overdueDays = now.difference(progress!.nextReviewDate!).inDays;
        if (overdueDays > 0) {
          score += overdueDays * 20; // High priority for overdue
        }
      }

      // Lower ease factor = harder word = higher priority
      final easeFactor = progress?.easeFactor ?? 2.5;
      score += (3.0 - easeFactor) * 30;

      // Lower correctCount = higher priority
      final correctCount = progress?.correctCount ?? 0;
      score += (10 - correctCount) * 10;

      // Not seen recently = higher priority (fallback for words without SRS data)
      if (progress?.lastAnswered != null && progress?.nextReviewDate == null) {
        final daysSince = now.difference(progress!.lastAnswered!).inDays;
        if (daysSince >= AppConstants.notSeenRecentlyDays) {
          score += daysSince * 2;
        }
      } else if (progress?.lastAnswered == null) {
        score += 20; // Never seen = high priority
      }

      // Random factor for variety
      score += _random.nextDouble() * 100 * AppConstants.randomFactorPercent;

      // Determine which mode needs more practice
      final enToBg = progress?.enToBgCount ?? 0;
      final bgToEn = progress?.bgToEnCount ?? 0;

      LearningMode mode;
      if (enToBg < AppConstants.requiredEnToBgCount &&
          bgToEn < AppConstants.requiredBgToEnCount) {
        // Both need practice, pick randomly
        mode = _random.nextBool() ? LearningMode.enToBg : LearningMode.bgToEn;
      } else if (enToBg < AppConstants.requiredEnToBgCount) {
        mode = LearningMode.enToBg;
      } else if (bgToEn < AppConstants.requiredBgToEnCount) {
        mode = LearningMode.bgToEn;
      } else {
        // Both met minimum, pick randomly
        mode = _random.nextBool() ? LearningMode.enToBg : LearningMode.bgToEn;
      }

      scored.add((word: word, score: score, mode: mode));
    }

    // Sort by score descending
    scored.sort((a, b) => b.score.compareTo(a.score));

    // Return highest scored word
    final best = scored.first;
    return (best.word, best.mode);
  }
}
