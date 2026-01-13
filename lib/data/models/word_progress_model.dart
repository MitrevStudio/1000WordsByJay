import 'package:hive/hive.dart';

part 'word_progress_model.g.dart';

/// Hive model for tracking individual word learning progress
@HiveType(typeId: 1)
class WordProgressModel extends HiveObject {
  @HiveField(0)
  late String wordId;

  @HiveField(1)
  int level1Completed = 0;

  @HiveField(2)
  int correctCount = 0;

  @HiveField(3)
  int enToBgCount = 0;

  @HiveField(4)
  int bgToEnCount = 0;

  @HiveField(5)
  DateTime? lastAnswered;

  @HiveField(6)
  int skipCount = 0;

  /// SRS: Ease factor for spaced repetition (default 2.5)
  @HiveField(7)
  double easeFactor = 2.5;

  /// SRS: Current interval in days until next review
  @HiveField(8)
  int interval = 0;

  /// SRS: Next scheduled review date
  @HiveField(9)
  DateTime? nextReviewDate;

  /// SRS: Consecutive correct answers (resets on wrong)
  @HiveField(10)
  int consecutiveCorrect = 0;

  WordProgressModel();

  WordProgressModel.create({
    required this.wordId,
    this.level1Completed = 0,
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

  /// Check if the word is fully learned (Level 2 completed)
  bool get isLearned =>
      correctCount >= 10 && enToBgCount >= 3 && bgToEnCount >= 3;

  /// Check if word is due for review
  bool get isDueForReview {
    if (nextReviewDate == null) return true;
    return DateTime.now().isAfter(nextReviewDate!) ||
        DateTime.now().isAtSameMomentAs(nextReviewDate!);
  }
}
