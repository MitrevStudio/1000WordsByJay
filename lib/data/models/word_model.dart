import 'package:hive/hive.dart';

part 'word_model.g.dart';

/// Hive model for storing words (EN ↔ BG)
/// Supports multiple Bulgarian translations for one English word
@HiveType(typeId: 0)
class WordModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String en;

  /// List of Bulgarian translations (supports multiple meanings)
  /// e.g., ["помня", "спомням си"] for "remember"
  @HiveField(2)
  late List<String> bgList;

  /// Word category (e.g., "verbs", "nouns", "adjectives")
  @HiveField(3)
  String? category;

  WordModel();

  WordModel.create({
    required this.id,
    required this.en,
    required this.bgList,
    this.category,
  });

  /// Get the first/primary Bulgarian translation (for backwards compatibility)
  String get bg => bgList.first;

  /// Get all translations as comma-separated string
  String get bgDisplay => bgList.join(', ');
}
