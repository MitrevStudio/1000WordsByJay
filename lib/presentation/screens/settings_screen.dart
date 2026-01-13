import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';

/// Settings screen for app configuration
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final soundEnabled = ref.watch(soundEnabledProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: ListView(
        children: [
          // Theme section
          _SectionHeader(title: 'Тема'),
          RadioListTile<ThemeMode>(
            title: const Text('Системна'),
            subtitle: const Text('Следва системните настройки'),
            value: ThemeMode.system,
            groupValue: themeMode,
            onChanged: (value) {
              if (value != null) {
                ref.read(themeModeProvider.notifier).setThemeMode(value);
              }
            },
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Светла'),
            value: ThemeMode.light,
            groupValue: themeMode,
            onChanged: (value) {
              if (value != null) {
                ref.read(themeModeProvider.notifier).setThemeMode(value);
              }
            },
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Тъмна'),
            value: ThemeMode.dark,
            groupValue: themeMode,
            onChanged: (value) {
              if (value != null) {
                ref.read(themeModeProvider.notifier).setThemeMode(value);
              }
            },
          ),
          const Divider(),

          // Sound section
          _SectionHeader(title: 'Звук'),
          SwitchListTile(
            title: const Text('Звукови ефекти'),
            subtitle: const Text('Звук при правилен/грешен отговор'),
            value: soundEnabled,
            onChanged: (value) {
              ref.read(soundEnabledProvider.notifier).setSoundEnabled(value);
            },
          ),
          const Divider(),

          // Daily Goal section
          _SectionHeader(title: 'Дневна цел'),
          _DailyGoalSelector(),
          const Divider(),

          // About section
          _SectionHeader(title: 'За приложението'),
          ListTile(
            title: const Text(''),
            subtitle: const Text('Научи 1000 EN↔BG думи офлайн'),
            leading: Icon(Icons.school, color: theme.colorScheme.primary),
          ),
          ListTile(
            title: const Text('Версия'),
            subtitle: const Text('1.0.0'),
            leading: const Icon(Icons.info_outline),
          ),
        ],
      ),
    );
  }
}

class _DailyGoalSelector extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dailyGoal = ref.watch(dailyGoalProvider);
    final theme = Theme.of(context);

    return ListTile(
      title: const Text('Думи на ден'),
      subtitle: Text('$dailyGoal думи'),
      leading: const Icon(Icons.flag),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: dailyGoal > 5
                ? () => ref
                      .read(dailyGoalProvider.notifier)
                      .setDailyGoal(dailyGoal - 5)
                : null,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$dailyGoal',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: dailyGoal < 50
                ? () => ref
                      .read(dailyGoalProvider.notifier)
                      .setDailyGoal(dailyGoal + 5)
                : null,
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
