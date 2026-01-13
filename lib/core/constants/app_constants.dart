/// Application-wide constants
class AppConstants {
  AppConstants._();

  /// Total number of words in the app
  static const int totalWords = 1000;

  /// Number of correct answers required to "learn" a word in Level 2
  static const int requiredCorrectCount = 10;

  /// Minimum EN→BG correct answers required
  static const int requiredEnToBgCount = 3;

  /// Minimum BG→EN correct answers required
  static const int requiredBgToEnCount = 3;

  /// Maximum Levenshtein distance for typo tolerance
  static const int maxTypoDistance = 1;

  /// Random factor percentage for word selection algorithm
  static const double randomFactorPercent = 0.15;

  /// Days threshold for "not seen recently" priority
  static const int notSeenRecentlyDays = 3;
}
