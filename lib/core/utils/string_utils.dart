import '../constants/app_constants.dart';

/// String utility functions including typo tolerance
class StringUtils {
  StringUtils._();

  /// Calculates the Levenshtein distance between two strings
  /// Used for typo tolerance in answer checking
  static int levenshteinDistance(String s1, String s2) {
    if (s1 == s2) return 0;
    if (s1.isEmpty) return s2.length;
    if (s2.isEmpty) return s1.length;

    List<int> previousRow = List.generate(s2.length + 1, (i) => i);
    List<int> currentRow = List.filled(s2.length + 1, 0);

    for (int i = 0; i < s1.length; i++) {
      currentRow[0] = i + 1;

      for (int j = 0; j < s2.length; j++) {
        final insertCost = currentRow[j] + 1;
        final deleteCost = previousRow[j + 1] + 1;
        final replaceCost = previousRow[j] + (s1[i] == s2[j] ? 0 : 1);

        currentRow[j + 1] = [
          insertCost,
          deleteCost,
          replaceCost,
        ].reduce((a, b) => a < b ? a : b);
      }

      final temp = previousRow;
      previousRow = currentRow;
      currentRow = temp;
    }

    return previousRow[s2.length];
  }

  /// Checks if answer is correct with typo tolerance
  /// Returns true if:
  /// - Exact match (case insensitive, trimmed)
  /// - Levenshtein distance <= maxTypoDistance (for words longer than 3 chars)
  static bool isAnswerCorrect(String answer, String expected) {
    final normalizedAnswer = answer.trim().toLowerCase();
    final normalizedExpected = expected.trim().toLowerCase();

    // Exact match
    if (normalizedAnswer == normalizedExpected) {
      return true;
    }

    // No typo tolerance for very short words
    if (normalizedExpected.length <= 3) {
      return false;
    }

    // Allow typo tolerance
    final distance = levenshteinDistance(normalizedAnswer, normalizedExpected);
    return distance <= AppConstants.maxTypoDistance;
  }

  /// Checks if answer matches any of the expected answers (for multiple meanings)
  /// Returns true if the answer matches any of the expected answers with typo tolerance
  static bool isAnswerCorrectMultiple(
    String answer,
    List<String> expectedAnswers,
  ) {
    for (final expected in expectedAnswers) {
      if (isAnswerCorrect(answer, expected)) {
        return true;
      }
    }
    return false;
  }

  /// Normalizes a string for comparison (trim + lowercase)
  static String normalize(String s) => s.trim().toLowerCase();
}
