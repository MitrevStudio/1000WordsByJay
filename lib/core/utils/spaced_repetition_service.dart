import 'dart:math';

/// Result of SRS calculation
class SrsResult {
  final double easeFactor;
  final int interval;
  final DateTime nextReviewDate;
  final int consecutiveCorrect;

  const SrsResult({
    required this.easeFactor,
    required this.interval,
    required this.nextReviewDate,
    required this.consecutiveCorrect,
  });
}

/// Spaced Repetition Service implementing SM-2 algorithm
///
/// Quality scale (0-5):
/// - 0: Complete blackout, no recall
/// - 1: Incorrect, but recognized correct answer
/// - 2: Incorrect, but correct answer seemed easy to recall
/// - 3: Correct with serious difficulty
/// - 4: Correct with some hesitation
/// - 5: Perfect response
class SpacedRepetitionService {
  /// Minimum ease factor to prevent intervals from becoming too short
  static const double minEaseFactor = 1.3;

  /// Maximum ease factor
  static const double maxEaseFactor = 3.0;

  /// Calculate next review based on answer quality
  ///
  /// [quality] - 0 to 5, where 5 is perfect recall
  /// [currentEaseFactor] - current ease factor (default 2.5)
  /// [currentInterval] - current interval in days
  /// [consecutiveCorrect] - number of consecutive correct answers
  SrsResult calculate({
    required int quality,
    required double currentEaseFactor,
    required int currentInterval,
    required int consecutiveCorrect,
  }) {
    // Clamp quality to valid range
    quality = quality.clamp(0, 5);

    double newEaseFactor = currentEaseFactor;
    int newInterval;
    int newConsecutiveCorrect;

    if (quality < 3) {
      // Failed recall - reset to beginning
      newInterval = 1;
      newConsecutiveCorrect = 0;
      // Decrease ease factor
      newEaseFactor = max(minEaseFactor, currentEaseFactor - 0.2);
    } else {
      // Successful recall
      newConsecutiveCorrect = consecutiveCorrect + 1;

      // Update ease factor based on quality
      // EF' = EF + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02))
      newEaseFactor =
          currentEaseFactor +
          (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02));
      newEaseFactor = newEaseFactor.clamp(minEaseFactor, maxEaseFactor);

      // Calculate new interval
      if (newConsecutiveCorrect == 1) {
        newInterval = 1;
      } else if (newConsecutiveCorrect == 2) {
        newInterval = 6;
      } else {
        newInterval = (currentInterval * newEaseFactor).round();
      }

      // Cap maximum interval at 365 days
      newInterval = min(newInterval, 365);
    }

    final nextReviewDate = DateTime.now().add(Duration(days: newInterval));

    return SrsResult(
      easeFactor: newEaseFactor,
      interval: newInterval,
      nextReviewDate: nextReviewDate,
      consecutiveCorrect: newConsecutiveCorrect,
    );
  }

  /// Convert answer correctness and attempt number to quality score
  ///
  /// [isCorrect] - whether the answer was correct
  /// [attemptNumber] - 1 for first attempt, 2 for second (after hint)
  /// [responseTimeMs] - optional response time in milliseconds
  int calculateQuality({
    required bool isCorrect,
    required int attemptNumber,
    int? responseTimeMs,
  }) {
    if (!isCorrect) {
      // Wrong answer
      return attemptNumber == 1 ? 1 : 0;
    }

    // Correct answer
    if (attemptNumber > 1) {
      // Correct after hint
      return 3;
    }

    // First attempt correct
    if (responseTimeMs != null) {
      if (responseTimeMs < 3000) {
        return 5; // Fast and correct = perfect
      } else if (responseTimeMs < 8000) {
        return 4; // Normal speed
      } else {
        return 3; // Slow but correct
      }
    }

    // Default to 4 if no timing info
    return 4;
  }
}
