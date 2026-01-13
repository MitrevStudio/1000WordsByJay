import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../../core/theme/app_theme.dart';
import 'components/streak_overlay.dart';
import 'components/animated_word_card.dart';

/// Training screen for practicing words
class TrainingScreen extends ConsumerStatefulWidget {
  final int? targetLevel;
  final String? category;

  const TrainingScreen({super.key, this.targetLevel, this.category});

  @override
  ConsumerState<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends ConsumerState<TrainingScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _showStreakOverlay = false;
  int _currentStreakCount = 0;
  bool _showDailyGoalOverlay = false;
  bool _shakeInput = false;

  @override
  void initState() {
    super.initState();

    // Intercept Enter key to prevent keyboard from closing
    _focusNode.onKeyEvent = (node, event) {
      if (event is KeyDownEvent &&
          event.logicalKey == LogicalKeyboardKey.enter) {
        // Handle Action
        final state = ref.read(trainingStateProvider);
        final hasAnswered = state.lastAnswerCorrect != null;

        if (hasAnswered) {
          _nextWord();
        } else {
          _submitAnswer();
        }

        // Prevent default behavior (which might close keyboard)
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    };

    // Start training session
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(trainingStateProvider.notifier)
          .startSession(
            targetLevel: widget.targetLevel,
            category: widget.category,
          );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submitAnswer() {
    if (_controller.text.trim().isEmpty) return;

    ref.read(trainingStateProvider.notifier).submitAnswer(_controller.text);

    // Ensure keyboard stays open with a slight delay
    Future.delayed(Duration.zero, () {
      if (mounted) _focusNode.requestFocus();
    });
  }

  void _nextWord() {
    _controller.clear();
    ref.read(trainingStateProvider.notifier).nextWord();
    // Ensure keyboard stays open
    Future.delayed(Duration.zero, () {
      if (mounted) _focusNode.requestFocus();
    });
  }

  void _skipWord() {
    ref.read(trainingStateProvider.notifier).skipWord();
  }

  @override
  Widget build(BuildContext context) {
    // Listen for Correct Answer state to auto-advance
    ref.listen(trainingStateProvider, (previous, next) {
      // If we transitioned from "no answer result" to "has answer result"
      if (previous?.lastAnswerCorrect == null &&
          next.lastAnswerCorrect != null) {
        final isCorrect = next.lastAnswerCorrect == true;

        if (isCorrect) {
          // Check for daily goal completion
          if (next.dailyGoalJustCompleted) {
            setState(() {
              _showDailyGoalOverlay = true;
            });
          }

          // Check for streak (every 5)
          if (next.currentStreak > 0 && next.currentStreak % 5 == 0) {
            setState(() {
              _showStreakOverlay = true;
              _currentStreakCount = next.currentStreak;
            });
            // Play streak celebration sound
            ref.read(audioServiceProvider).playStreak();
            // Don't auto-advance yet, wait for overlay
          } else {
            // Normal correct answer: delay then advance
            Future.delayed(const Duration(milliseconds: 800), () {
              if (mounted) _nextWord();
            });
          }
        } else {
          // Wrong answer: shake the input and keep focus
          setState(() {
            _shakeInput = true;
          });
          Future.delayed(const Duration(milliseconds: 400), () {
            if (mounted) {
              setState(() {
                _shakeInput = false;
              });
            }
          });
          Future.delayed(Duration.zero, () {
            if (mounted) _focusNode.requestFocus();
          });
        }
      }
    });

    final state = ref.watch(trainingStateProvider);
    final dailyGoal = ref.watch(dailyGoalProvider);
    final theme = Theme.of(context);

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Text('Ниво ${state.currentLevel}'),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Text(
                    '🔥 ${state.currentStreak}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : state.levelComplete
              ? _buildLevelComplete(theme, state)
              : _buildTrainingContent(theme, state),
        ),
        if (_showStreakOverlay)
          StreakOverlay(
            streakCount: _currentStreakCount,
            onAnimationComplete: () {
              setState(() {
                _showStreakOverlay = false;
              });
              _nextWord();
            },
          ),
        if (_showDailyGoalOverlay)
          DailyGoalOverlay(
            goal: dailyGoal,
            onDismiss: () {
              setState(() {
                _showDailyGoalOverlay = false;
              });
            },
          ),
      ],
    );
  }

  Widget _buildLevelComplete(ThemeData theme, TrainingState state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.celebration, size: 80, color: theme.colorScheme.primary),
            const SizedBox(height: 24),
            Text(
              state.currentLevel == 2
                  ? 'Поздравления! 🎉\nНаучи всички думи!'
                  : 'Ниво ${state.currentLevel} завършено!',
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Към началото'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrainingContent(ThemeData theme, TrainingState state) {
    final hasAnswered = state.lastAnswerCorrect != null;
    final isCorrect = state.lastAnswerCorrect == true;
    final wasSkipped = state.wasSkipped;
    final showFeedback = hasAnswered || wasSkipped || state.needsRetry;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SizedBox(
          height: MediaQuery.of(context).size.height - kToolbarHeight - 48,
          child: Column(
            children: [
              // Direction label
              Text(
                state.directionLabel,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),

              // Animated Word card
              AnimatedWordCard(
                word: state.displayWord,
                translationHint: state.translationHint,
                wordKey: ValueKey(
                  '${state.currentWord?.id}_${state.displayWord}',
                ),
              ),
              const SizedBox(height: 32),

              // Answer feedback (for answered, skipped, or needs retry)
              if (showFeedback)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: wasSkipped
                        ? Colors.orange.withValues(alpha: 0.1)
                        : state.needsRetry
                        ? Colors.amber.withValues(alpha: 0.1)
                        : (isCorrect
                              ? AppTheme.successColor.withValues(alpha: 0.1)
                              : AppTheme.errorColor.withValues(alpha: 0.1)),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: wasSkipped
                          ? Colors.orange
                          : state.needsRetry
                          ? Colors.amber
                          : (isCorrect
                                ? AppTheme.successColor
                                : AppTheme.errorColor),
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        wasSkipped
                            ? Icons.skip_next
                            : state.needsRetry
                            ? Icons.lightbulb_outline
                            : (isCorrect ? Icons.check_circle : Icons.cancel),
                        color: wasSkipped
                            ? Colors.orange
                            : state.needsRetry
                            ? Colors.amber
                            : (isCorrect
                                  ? AppTheme.successColor
                                  : AppTheme.errorColor),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          wasSkipped
                              ? 'Пропусната: ${state.expectedAnswerDisplay}'
                              : state.needsRetry
                              ? 'Подсказка: ${state.answerHint}'
                              : (isCorrect
                                    ? 'Правилно!'
                                    : 'Грешно: ${state.expectedAnswerDisplay}'),
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: wasSkipped
                                ? Colors.orange
                                : state.needsRetry
                                ? Colors.amber.shade700
                                : (isCorrect
                                      ? AppTheme.successColor
                                      : AppTheme.errorColor),
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                )
              else
                const SizedBox(height: 60), // Placeholder to keep layout stable

              const SizedBox(height: 24),

              // Input field with shake animation
              ShakeWidget(
                shake: _shakeInput,
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  enabled: !showFeedback || state.needsRetry,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.none,
                  maxLines: 1,
                  autofocus: true,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: showFeedback
                        ? (wasSkipped
                              ? Colors.orange
                              : (isCorrect
                                    ? AppTheme.successColor
                                    : AppTheme.errorColor))
                        : theme.textTheme.titleLarge?.color,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Въведи отговор...',
                    filled: true,
                    fillColor: showFeedback
                        ? (wasSkipped
                              ? Colors.orange.withOpacity(0.05)
                              : (isCorrect
                                    ? AppTheme.successColor.withOpacity(0.05)
                                    : AppTheme.errorColor.withOpacity(0.05)))
                        : null,
                    focusedBorder: showFeedback
                        ? OutlineInputBorder(
                            borderSide: BorderSide(
                              color: wasSkipped
                                  ? Colors.orange
                                  : (isCorrect
                                        ? AppTheme.successColor
                                        : AppTheme.errorColor),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          )
                        : null,
                    enabledBorder: showFeedback
                        ? OutlineInputBorder(
                            borderSide: BorderSide(
                              color: wasSkipped
                                  ? Colors.orange
                                  : (isCorrect
                                        ? AppTheme.successColor
                                        : AppTheme.errorColor),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          )
                        : null,
                    disabledBorder: showFeedback
                        ? OutlineInputBorder(
                            borderSide: BorderSide(
                              color: wasSkipped
                                  ? Colors.orange
                                  : (isCorrect
                                        ? AppTheme.successColor
                                        : AppTheme.errorColor),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          )
                        : null,
                    suffixIcon: showFeedback
                        ? IconButton(
                            icon: const Icon(Icons.arrow_forward),
                            onPressed: _nextWord,
                          )
                        : IconButton(
                            icon: const Icon(Icons.send),
                            onPressed: _submitAnswer,
                          ),
                  ),
                ),
              ),
              const Spacer(),

              // Buttons based on state
              if (showFeedback && !state.needsRetry)
                FilledButton.icon(
                  onPressed: _nextWord,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Следваща дума'),
                )
              else if (state.needsRetry)
                Column(
                  children: [
                    FilledButton(
                      onPressed: _submitAnswer,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 8,
                        ),
                        child: Text('Опитай пак'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: _skipWord,
                      icon: const Icon(Icons.skip_next),
                      label: const Text('Пропусни'),
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    FilledButton(
                      onPressed: _submitAnswer,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 8,
                        ),
                        child: Text('Провери'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: _skipWord,
                      icon: const Icon(Icons.skip_next),
                      label: const Text('Пропусни'),
                    ),
                  ],
                ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
