import '../entities/entities.dart';

/// Repository interface for progress operations
abstract class ProgressRepository {
  /// Get progress for a specific word
  Future<WordProgress?> getWordProgress(String wordId);

  /// Get all word progress entries
  Future<List<WordProgress>> getAllWordProgress();

  /// Save word progress
  Future<void> saveWordProgress(WordProgress progress);

  /// Get user progress
  Future<UserProgress> getUserProgress();

  /// Save user progress
  Future<void> saveUserProgress(UserProgress progress);

  /// Get words not completed in Level 1
  Future<List<Word>> getLevel1IncompleteWords();

  /// Get progress entries for words not fully learned in Level 2
  Future<List<WordProgress>> getLevel2IncompleteProgress();

  /// Count Level 1 completed words
  Future<int> countLevel1Completed();

  /// Count fully learned words (Level 2 complete)
  Future<int> countLearnedWords();
}
