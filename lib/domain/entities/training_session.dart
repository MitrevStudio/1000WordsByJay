/// Current training session state
class TrainingSession {
  final int currentWordId;
  final String displayWord;
  final String expectedAnswer;
  final bool isEnToBg;
  final bool? lastAnswerCorrect;
  final String? lastUserAnswer;

  const TrainingSession({
    required this.currentWordId,
    required this.displayWord,
    required this.expectedAnswer,
    required this.isEnToBg,
    this.lastAnswerCorrect,
    this.lastUserAnswer,
  });

  TrainingSession copyWith({
    int? currentWordId,
    String? displayWord,
    String? expectedAnswer,
    bool? isEnToBg,
    bool? lastAnswerCorrect,
    String? lastUserAnswer,
  }) {
    return TrainingSession(
      currentWordId: currentWordId ?? this.currentWordId,
      displayWord: displayWord ?? this.displayWord,
      expectedAnswer: expectedAnswer ?? this.expectedAnswer,
      isEnToBg: isEnToBg ?? this.isEnToBg,
      lastAnswerCorrect: lastAnswerCorrect,
      lastUserAnswer: lastUserAnswer,
    );
  }
}
