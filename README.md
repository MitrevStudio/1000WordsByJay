# 1000 Words by Jay

A vocabulary learning app for English-Bulgarian word pairs using a two-level learning system with spaced repetition (SM-2 algorithm).

## Features

- **Two-Level Learning System**
  - Level 1: Word introduction - see the English word with Bulgarian translation, type the English word
  - Level 2: Reinforcement - bidirectional practice (EN↔BG) with spaced repetition
- **Spaced Repetition (SM-2)** - Optimizes review timing for long-term retention
- **Typo Tolerance** - Levenshtein distance algorithm allows minor typos
- **Multiple Translations** - Words can have multiple valid Bulgarian translations
- **Daily Goals & Streaks** - Track your progress and maintain learning habits
- **Dark/Light Theme** - Comfortable learning in any lighting

## Download

### Available Now

| Platform | Download                                |
| -------- | --------------------------------------- |
| Android  | [Latest APK](../../releases/latest)     |
| Windows  | [Latest Release](../../releases/latest) |
| Linux    | [Latest Release](../../releases/latest) |
| Web      | [Coming Soon]                           |

### Coming Soon 🍎

- **iOS** - App Store release planned
- **macOS** - Mac App Store release planned

## Build from Source

```bash
# Clone the repository
git clone https://github.com/MitrevStudio/1000WordsByJay.git
cd 1000WordsByJay

# Install dependencies
flutter pub get

# Generate Hive adapters
flutter pub run build_runner build --delete-conflicting-outputs

# Run
flutter run
```

### Build for specific platforms

```bash
# Android APK
flutter build apk --release

# Windows
flutter build windows --release

# Linux
flutter build linux --release

# Web
flutter build web --release
```

## Requirements

- Flutter SDK 3.10+
- Dart SDK 3.0+

## Architecture

Clean Architecture with Riverpod state management:

```
lib/
├── core/           # Theme, constants, utilities (SRS, string matching, audio)
├── domain/         # Entities, repository interfaces, use cases
├── data/           # Hive models, datasources, repository implementations
└── presentation/   # Providers, screens, components
```

## License

MIT License - see [LICENSE](LICENSE) for details.

## Contributing

Contributions welcome! Please read the contribution guidelines before submitting a PR.
