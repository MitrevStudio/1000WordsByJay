/// Domain entity representing progress for a single word
class WordProgress {
  final String wordId;
  final bool level1Completed;
  final int correctCount;
  final int enToBgCount;
  final int bgToEnCount;
  final DateTime? lastAnswered;
  final int skipCount;

  /// SRS: Ease factor for spaced repetition (default 2.5)
  final double easeFactor;

  /// SRS: Current interval in days until next review
  final int interval;

  /// SRS: Next scheduled review date
  final DateTime? nextReviewDate;

  /// SRS: Consecutive correct answers (resets on wrong)
  final int consecutiveCorrect;

  const WordProgress({
    required this.wordId,
    this.level1Completed = false,
    this.correctCount = 0,
    this.enToBgCount = 0,
    this.bgToEnCount = 0,
    this.lastAnswered,
    this.skipCount = 0,
    this.easeFactor = 2.5,
    this.interval = 0,
    this.nextReviewDate,
    this.consecutiveCorrect = 0,
  });

  /// Check if the word is fully learned
  bool get isLearned =>
      correctCount >= 10 && enToBgCount >= 3 && bgToEnCount >= 3;

  /// Progress percentage for this word (0.0 - 1.0)
  double get progressPercent => (correctCount / 10).clamp(0.0, 1.0);

  /// Check if word is due for review
  bool get isDueForReview {
    if (nextReviewDate == null) return true;
    return DateTime.now().isAfter(nextReviewDate!) ||
        DateTime.now().isAtSameMomentAs(nextReviewDate!);
  }

  WordProgress copyWith({
    String? wordId,
    bool? level1Completed,
    int? correctCount,
    int? enToBgCount,
    int? bgToEnCount,
    DateTime? lastAnswered,
    int? skipCount,
    double? easeFactor,
    int? interval,
    DateTime? nextReviewDate,
    int? consecutiveCorrect,
  }) {
    return WordProgress(
      wordId: wordId ?? this.wordId,
      level1Completed: level1Completed ?? this.level1Completed,
      correctCount: correctCount ?? this.correctCount,
      enToBgCount: enToBgCount ?? this.enToBgCount,
      bgToEnCount: bgToEnCount ?? this.bgToEnCount,
      lastAnswered: lastAnswered ?? this.lastAnswered,
      skipCount: skipCount ?? this.skipCount,
      easeFactor: easeFactor ?? this.easeFactor,
      interval: interval ?? this.interval,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
      consecutiveCorrect: consecutiveCorrect ?? this.consecutiveCorrect,
    );
  }
}
