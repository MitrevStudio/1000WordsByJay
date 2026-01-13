import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import 'training_screen.dart';
import 'stats_screen.dart';
import 'settings_screen.dart';

/// Home screen with progress overview and navigation
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('1000 Думи от Джей'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const StatsScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Грешка: $e')),
        data: (stats) => SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Daily progress card
                Card(
                  color: stats.dailyGoalMet
                      ? theme.colorScheme.primaryContainer
                      : null,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        // Circular daily progress
                        SizedBox(
                          width: 70,
                          height: 70,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              CircularProgressIndicator(
                                value: stats.dailyProgress,
                                strokeWidth: 6,
                                backgroundColor:
                                    theme.colorScheme.surfaceContainerHighest,
                                color: stats.dailyGoalMet
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.secondary,
                              ),
                              Center(
                                child: Text(
                                  stats.dailyGoalMet
                                      ? '✓'
                                      : '${stats.todayCorrect}',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: stats.dailyGoalMet
                                        ? theme.colorScheme.primary
                                        : null,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                stats.dailyGoalMet
                                    ? 'Дневна цел постигната! 🎉'
                                    : 'Дневна цел',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${stats.todayCorrect}/${stats.dailyGoal} думи днес',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              if (stats.dayStreak > 0) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Text(
                                      '🔥',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${stats.dayStreak} дни поред',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: Colors.orange,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Overall Progress card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        Text('Общ прогрес', style: theme.textTheme.titleMedium),
                        const SizedBox(height: 16),
                        LinearProgressIndicator(
                          value: stats.overallProgressPercent,
                          minHeight: 12,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${(stats.overallProgressPercent * 100).toStringAsFixed(1)}%',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _StatItem(
                              label: 'Въведени',
                              value:
                                  '${stats.level1Completed}/${stats.totalWords}',
                            ),
                            _StatItem(
                              label: 'Научени',
                              value:
                                  '${stats.level2Learned}/${stats.totalWords}',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Level selection buttons
                FilledButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TrainingScreen(targetLevel: 1),
                      ),
                    );
                  },
                  icon: const Icon(Icons.school),
                  label: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'Ниво 1: Научи нови думи (${stats.level1Completed}/${stats.totalWords})',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: stats.level1Completed > 0
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const TrainingScreen(targetLevel: 2),
                            ),
                          );
                        }
                      : null,
                  icon: const Icon(Icons.refresh),
                  label: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      stats.level1Completed > 0
                          ? 'Ниво 2: Упражнявай се (${stats.level2Learned}/${stats.level1Completed})'
                          : 'Ниво 2: Първо научи думи в Ниво 1',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
