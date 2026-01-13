import '../entities/entities.dart';

/// Repository interface for word operations
abstract class WordRepository {
  /// Get all words
  Future<List<Word>> getAllWords();

  /// Get word by ID
  Future<Word?> getWordById(String id);

  /// Get total word count
  Future<int> getWordCount();

  /// Import words from asset JSON
  Future<void> importWords();
}
