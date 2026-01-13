/// Domain entity representing a word pair
class Word {
  final String id;
  final String en;

  /// List of Bulgarian translations (supports multiple meanings)
  final List<String> bgList;

  /// Word category (e.g., "verbs", "nouns", "adjectives")
  final String? category;

  const Word({
    required this.id,
    required this.en,
    required this.bgList,
    this.category,
  });

  /// Get the first/primary Bulgarian translation
  String get bg => bgList.first;

  /// Get all translations as comma-separated string
  String get bgDisplay => bgList.join(', ');
}
