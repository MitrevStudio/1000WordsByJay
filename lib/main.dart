import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'presentation/providers/providers.dart';
import 'presentation/screens/screens.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: WordsApp()));
}

/// Main application widget
class WordsApp extends ConsumerWidget {
  const WordsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final hiveAsync = ref.watch(hiveProvider);

    return MaterialApp(
      title: '1000 Words',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: hiveAsync.when(
        loading: () => const _LoadingScreen(),
        error: (e, _) => _ErrorScreen(error: e.toString()),
        data: (_) => const _InitializationWrapper(),
      ),
    );
  }
}

/// Shows loading indicator while Hive initializes
class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 24),
            Text('Зареждане...'),
          ],
        ),
      ),
    );
  }
}

/// Shows error if database fails
class _ErrorScreen extends StatelessWidget {
  final String error;

  const _ErrorScreen({required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Грешка при зареждане',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(error, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

/// Initializes words data and shows home screen
class _InitializationWrapper extends ConsumerStatefulWidget {
  const _InitializationWrapper();

  @override
  ConsumerState<_InitializationWrapper> createState() =>
      _InitializationWrapperState();
}

class _InitializationWrapperState
    extends ConsumerState<_InitializationWrapper> {
  bool _initialized = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final wordRepo = ref.read(wordRepositoryProvider);
      await wordRepo.importWords();
      setState(() => _initialized = true);
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return _ErrorScreen(error: _error!);
    }

    if (!_initialized) {
      return const _LoadingScreen();
    }

    return const HomeScreen();
  }
}
