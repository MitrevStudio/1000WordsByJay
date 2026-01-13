# Copilot Instructions for Words App

## Project Overview

A Flutter vocabulary learning app teaching English-Bulgarian word pairs using a two-level learning system with spaced repetition (SM-2 algorithm). UI is in Bulgarian.

## Architecture (Clean Architecture)

```
lib/
├── core/           # Cross-cutting: theme, constants, utils (SRS, string matching, audio)
├── domain/         # Business logic: entities, repository interfaces, use cases
├── data/           # Persistence: Hive models (with .g.dart codegen), datasources, repository implementations
└── presentation/   # UI: Riverpod providers, screens, components
```

**Data Flow:** `Screen → Provider → UseCase → Repository (interface) → RepositoryImpl → DataSource → Hive`

## Key Domain Concepts

### Two-Level Learning System

- **Level 1 (Introduction):** Show EN word + BG translation → user types EN. Marks `level1Completed` on success.
- **Level 2 (Reinforcement):** Bidirectional practice (EN↔BG) with SRS. Requires 10 correct answers + 3 each direction to mark `isLearned`.

### Word Model

Words can have multiple Bulgarian translations (e.g., "get" → ["взимам", "получавам", "ставам"]). All translations are valid answers.

```dart
// Always use bgList, not bg (which returns only first)
final List<String> bgList;  // Multiple valid translations
String get bg => bgList.first;  // For display only
```

### Spaced Repetition (SM-2)

Located in [core/utils/spaced_repetition_service.dart](lib/core/utils/spaced_repetition_service.dart). Key fields on `WordProgress`: `easeFactor`, `interval`, `nextReviewDate`, `consecutiveCorrect`.

## State Management (Riverpod)

- **Provider hierarchy:** [app_providers.dart](lib/presentation/providers/app_providers.dart) wires dependencies
- `hiveProvider` → initializes DB (must complete before other providers)
- `trainingStateProvider` → `StateNotifier<TrainingState>` manages training session
- `statsProvider` → `FutureProvider<LearningStats>` for dashboard

## Persistence (Hive)

Models in `lib/data/models/` require code generation:

```powershell
flutter pub run build_runner build --delete-conflicting-outputs
```

- Register adapters in `hiveProvider` before opening boxes
- Box names defined in `HiveBoxes` class
- Words imported from `assets/data/words.json` on first run

## Answer Validation

Uses Levenshtein distance for typo tolerance (max 1 edit for words > 3 chars). See [string_utils.dart](lib/core/utils/string_utils.dart).

```dart
// Checking answers with multiple valid translations:
StringUtils.isAnswerCorrectMultiple(userAnswer, expectedAnswers);
```

## Critical Patterns

### Adding New Use Cases

1. Create in `lib/domain/usecases/`
2. Export in `usecases.dart` barrel file
3. Add provider in `app_providers.dart`

### Adding New Screens

1. Create in `lib/presentation/screens/`
2. Export in `screens.dart`
3. Use `ConsumerWidget`/`ConsumerStatefulWidget` for Riverpod access

### Modifying Hive Models

1. Update model class with new `@HiveField(n)` (increment n)
2. Run `build_runner build`
3. Never reuse deleted field indices

## Commands

```powershell
# Run app
flutter run

# Generate Hive adapters after model changes
flutter pub run build_runner build --delete-conflicting-outputs

# Analyze code
flutter analyze

# Run tests
flutter test
```

## Assets

- Words data: `assets/data/words.json` - JSON format with `id`, `en`, `bg` (string or array), optional `category`
- Audio feedback: `assets/sounds/` - correct/wrong/streak sounds

## Testing Notes

- Widget test scaffold in `test/widget_test.dart`
- Wrap widgets with `ProviderScope` for Riverpod testing
- Mock repositories at interface level for use case tests
