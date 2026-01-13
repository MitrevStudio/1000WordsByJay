import '../../core/utils/string_utils.dart';

/// Result of checking an answer
class AnswerResult {
  final bool isCorrect;
  final String userAnswer;

  /// All accepted answers (for display purposes)
  final List<String> expectedAnswers;

  const AnswerResult({
    required this.isCorrect,
    required this.userAnswer,
    required this.expectedAnswers,
  });

  /// Get expected answers as comma-separated string for display
  String get expectedAnswerDisplay => expectedAnswers.join(', ');
}

/// Use case for checking user's answer
class CheckAnswerUseCase {
  /// Check if the answer is correct (with typo tolerance)
  /// Supports multiple expected answers (e.g., "помня, спомням си" for "remember")
  AnswerResult call({
    required String userAnswer,
    required List<String> expectedAnswers,
  }) {
    final isCorrect = StringUtils.isAnswerCorrectMultiple(
      userAnswer,
      expectedAnswers,
    );

    return AnswerResult(
      isCorrect: isCorrect,
      userAnswer: userAnswer.trim(),
      expectedAnswers: expectedAnswers,
    );
  }
}
