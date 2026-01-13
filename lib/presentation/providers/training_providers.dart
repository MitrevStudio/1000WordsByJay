import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/entities.dart';
import 'app_providers.dart';
import 'settings_providers.dart';

/// State for the current training session
class TrainingState {
  final int currentLevel;
  final Word? currentWord;
  final LearningMode? mode;
  final bool? lastAnswerCorrect;
  final String? lastUserAnswer;
  final bool isLoading;
  final bool levelComplete;
  final int currentStreak;
  final bool wasSkipped;
  final int attemptNumber;
  final String? selectedCategory;
  final DateTime? questionStartTime;
  final bool dailyGoalJustCompleted;

  const TrainingState({
    this.currentLevel = 1,
    this.currentWord,
    this.mode,
    this.lastAnswerCorrect,
    this.lastUserAnswer,
    this.isLoading = false,
    this.levelComplete = false,
    this.currentStreak = 0,
    this.wasSkipped = false,
    this.attemptNumber = 1,
    this.selectedCategory,
    this.questionStartTime,
    this.dailyGoalJustCompleted = false,
  });

  TrainingState copyWith({
    int? currentLevel,
    Word? currentWord,
    LearningMode? mode,
    bool? lastAnswerCorrect,
    String? lastUserAnswer,
    bool? isLoading,
    bool? levelComplete,
    int? currentStreak,
    bool? wasSkipped,
    int? attemptNumber,
    String? selectedCategory,
    DateTime? questionStartTime,
    bool? dailyGoalJustCompleted,
  }) {
    return TrainingState(
      currentLevel: currentLevel ?? this.currentLevel,
      currentWord: currentWord ?? this.currentWord,
      mode: mode ?? this.mode,
      lastAnswerCorrect: lastAnswerCorrect,
      lastUserAnswer: lastUserAnswer,
      isLoading: isLoading ?? this.isLoading,
      levelComplete: levelComplete ?? this.levelComplete,
      currentStreak: currentStreak ?? this.currentStreak,
      wasSkipped: wasSkipped ?? this.wasSkipped,
      attemptNumber: attemptNumber ?? this.attemptNumber,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      questionStartTime: questionStartTime ?? this.questionStartTime,
      dailyGoalJustCompleted:
          dailyGoalJustCompleted ?? this.dailyGoalJustCompleted,
    );
  }

  /// Get the word to display to user
  String? get displayWord {
    if (currentWord == null) return null;
    if (currentLevel == 1) {
      return currentWord!.en; // Level 1: always show EN
    }
    // Level 2: depends on mode
    return mode == LearningMode.enToBg ? currentWord!.en : currentWord!.bg;
  }

  /// Get the expected answer (primary one for simple display)
  String? get expectedAnswer {
    if (currentWord == null) return null;
    if (currentLevel == 1) {
      return currentWord!.en; // Level 1: type EN
    }
    // Level 2: type opposite language
    return mode == LearningMode.enToBg ? currentWord!.bg : currentWord!.en;
  }

  /// Get all expected answers (for validation - supports multiple meanings)
  List<String> get expectedAnswers {
    if (currentWord == null) return [];
    if (currentLevel == 1) {
      return [currentWord!.en]; // Level 1: type EN (single answer)
    }
    // Level 2: type opposite language
    return mode == LearningMode.enToBg
        ? currentWord!
              .bgList // All Bulgarian translations are valid
        : [currentWord!.en]; // English is single
  }

  /// Get all expected answers as display string
  String get expectedAnswerDisplay {
    return expectedAnswers.join(', ');
  }

  /// Get the translation hint (Level 1 only)
  String? get translationHint {
    if (currentLevel == 1 && currentWord != null) {
      return currentWord!.bgDisplay; // Show all translations
    }
    return null;
  }

  /// Get direction label for UI
  String get directionLabel {
    if (currentLevel == 1) return 'Напиши на английски';
    return mode == LearningMode.enToBg
        ? 'Напиши на български'
        : 'Напиши на английски';
  }

  /// Get hint for first wrong attempt (first letter + asterisks)
  String get answerHint {
    final answer = expectedAnswer;
    if (answer == null || answer.isEmpty) return '';
    if (answer.length == 1) return answer;
    return answer[0] + '*' * (answer.length - 1);
  }

  /// Check if on first attempt with wrong answer (needs retry)
  bool get needsRetry => attemptNumber == 2 && lastAnswerCorrect == null;
}

/// Provider for training state
final trainingStateProvider =
    StateNotifierProvider<TrainingNotifier, TrainingState>((ref) {
      return TrainingNotifier(ref);
    });

/// Notifier for managing training session
class TrainingNotifier extends StateNotifier<TrainingState> {
  final Ref _ref;

  TrainingNotifier(this._ref) : super(const TrainingState());

  /// Initialize training session
  /// [targetLevel] - 1 for introduction, 2 for reinforcement. If null, uses saved progress.
  /// [category] - optional category filter
  Future<void> startSession({int? targetLevel, String? category}) async {
    state = state.copyWith(
      isLoading: true,
      levelComplete: false,
      selectedCategory: category,
      dailyGoalJustCompleted: false,
    );

    try {
      int level;
      if (targetLevel != null) {
        level = targetLevel;
      } else {
        // Get current level from user progress
        final progressRepo = _ref.read(progressRepositoryProvider);
        final userProgress = await progressRepo.getUserProgress();
        level = userProgress.currentLevel;
      }

      state = state.copyWith(currentLevel: level);

      await _loadNextWord();
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Load the next word
  Future<void> _loadNextWord() async {
    final getNextWord = _ref.read(getNextWordUseCaseProvider);

    if (state.currentLevel == 1) {
      final word = await getNextWord.getNextLevel1Word(
        category: state.selectedCategory,
      );
      if (word == null) {
        // Level 1 complete - all words introduced
        state = state.copyWith(levelComplete: true, isLoading: false);
        return;
      }
      state = state.copyWith(
        currentWord: word,
        mode: null,
        isLoading: false,
        questionStartTime: DateTime.now(),
      );
    } else {
      final result = await getNextWord.getNextLevel2Word(
        category: state.selectedCategory,
      );
      if (result == null) {
        // Level 2 complete or no words available
        state = state.copyWith(levelComplete: true, isLoading: false);
        return;
      }
      final (word, mode) = result;
      state = state.copyWith(
        currentWord: word,
        mode: mode,
        isLoading: false,
        questionStartTime: DateTime.now(),
      );
    }
  }

  /// Submit an answer
  Future<void> submitAnswer(String answer) async {
    if (state.currentWord == null || state.expectedAnswers.isEmpty) return;

    final checkAnswer = _ref.read(checkAnswerUseCaseProvider);
    final updateProgress = _ref.read(updateProgressUseCaseProvider);
    final audioService = _ref.read(audioServiceProvider);
    final dailyGoal = _ref.read(dailyGoalProvider);

    final result = checkAnswer(
      userAnswer: answer,
      expectedAnswers: state.expectedAnswers,
    );

    // Calculate response time
    int? responseTimeMs;
    if (state.questionStartTime != null) {
      responseTimeMs = DateTime.now()
          .difference(state.questionStartTime!)
          .inMilliseconds;
    }

    // Play sound and haptic feedback
    if (result.isCorrect) {
      await audioService.playCorrect();
      HapticFeedback.lightImpact();
    } else {
      await audioService.playWrong();
      HapticFeedback.mediumImpact();
    }

    // First attempt wrong - give second chance with hint
    if (!result.isCorrect && state.attemptNumber == 1) {
      state = state.copyWith(
        lastUserAnswer: result.userAnswer,
        attemptNumber: 2,
      );
      return; // Don't update progress yet
    }

    final newStreak = result.isCorrect ? state.currentStreak + 1 : 0;

    // Update state with result
    state = state.copyWith(
      lastAnswerCorrect: result.isCorrect,
      lastUserAnswer: result.userAnswer,
      currentStreak: newStreak,
    );

    // Update progress with SRS and daily goal tracking
    bool goalCompleted = false;
    if (state.currentLevel == 1) {
      goalCompleted = await updateProgress.updateLevel1Progress(
        wordId: state.currentWord!.id,
        isCorrect: result.isCorrect,
        dailyGoal: dailyGoal,
      );
    } else {
      goalCompleted = await updateProgress.updateLevel2Progress(
        wordId: state.currentWord!.id,
        isCorrect: result.isCorrect,
        mode: state.mode!,
        attemptNumber: state.attemptNumber,
        dailyGoal: dailyGoal,
        responseTimeMs: responseTimeMs,
      );
    }

    if (goalCompleted) {
      state = state.copyWith(dailyGoalJustCompleted: true);
      HapticFeedback.heavyImpact();
    }

    // Refresh stats
    _ref.invalidate(statsProvider);
  }

  /// Continue to next word
  Future<void> nextWord() async {
    state = state.copyWith(
      lastAnswerCorrect: null,
      lastUserAnswer: null,
      isLoading: true,
      wasSkipped: false,
      attemptNumber: 1,
      dailyGoalJustCompleted: false,
    );
    await _loadNextWord();
  }

  /// Skip current word (show answer, record skip, wait for user to press next)
  Future<void> skipWord() async {
    if (state.currentWord == null) return;

    final updateProgress = _ref.read(updateProgressUseCaseProvider);

    // Record the skip
    await updateProgress.recordSkip(wordId: state.currentWord!.id);

    // Reset streak and mark as skipped (shows answer)
    state = state.copyWith(currentStreak: 0, wasSkipped: true);
    HapticFeedback.mediumImpact();

    // Refresh stats
    _ref.invalidate(statsProvider);
  }
}
