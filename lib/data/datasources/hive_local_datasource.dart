import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import '../models/models.dart';
import '../../core/constants/asset_paths.dart';

/// Box names
class HiveBoxes {
  static const String words = 'words';
  static const String wordProgress = 'word_progress';
  static const String userProgress = 'user_progress';
  static const String settings = 'settings';
}

/// Local data source for Hive database operations
class HiveLocalDataSource {
  late Box<WordModel> _wordsBox;
  late Box<WordProgressModel> _wordProgressBox;
  late Box<UserProgressModel> _userProgressBox;
  late Box<SettingsModel> _settingsBox;

  /// Initialize Hive boxes
  Future<void> init() async {
    _wordsBox = await Hive.openBox<WordModel>(HiveBoxes.words);
    _wordProgressBox = await Hive.openBox<WordProgressModel>(
      HiveBoxes.wordProgress,
    );
    _userProgressBox = await Hive.openBox<UserProgressModel>(
      HiveBoxes.userProgress,
    );
    _settingsBox = await Hive.openBox<SettingsModel>(HiveBoxes.settings);
  }

  // ============ WORDS ============

  /// Get all words
  List<WordModel> getAllWords() {
    return _wordsBox.values.toList();
  }

  /// Get word by ID
  WordModel? getWordById(String id) {
    return _wordsBox.get(id);
  }

  /// Get total word count
  int getWordCount() {
    return _wordsBox.length;
  }

  /// Import words from JSON asset (first run only)
  Future<void> importWordsFromAsset() async {
    if (_wordsBox.isNotEmpty) return; // Already imported

    final jsonString = await rootBundle.loadString(AssetPaths.wordsJson);
    final Map<String, dynamic> data = json.decode(jsonString);
    final List<dynamic> wordsData = data['words'];

    for (int i = 0; i < wordsData.length; i++) {
      final wordData = wordsData[i];
      final id = 'word_$i';

      // Support both old format (bg as string) and new format (bg as array)
      List<String> bgList;
      final bgValue = wordData['bg'];
      if (bgValue is List) {
        bgList = bgValue.cast<String>();
      } else {
        // Old format: single string - convert to list
        bgList = [bgValue as String];
      }

      // Get category if available
      final category = wordData['category'] as String?;

      final word = WordModel.create(
        id: id,
        en: wordData['en'] as String,
        bgList: bgList,
        category: category,
      );
      await _wordsBox.put(id, word);
    }
  }

  // ============ WORD PROGRESS ============

  /// Get progress for a specific word
  WordProgressModel? getWordProgress(String wordId) {
    return _wordProgressBox.get(wordId);
  }

  /// Get all word progress entries
  List<WordProgressModel> getAllWordProgress() {
    return _wordProgressBox.values.toList();
  }

  /// Save or update word progress
  Future<void> saveWordProgress(WordProgressModel progress) async {
    await _wordProgressBox.put(progress.wordId, progress);
  }

  /// Get words not completed in Level 1
  List<WordModel> getLevel1IncompleteWords() {
    final completedWordIds = _wordProgressBox.values
        .where((p) => p.level1Completed == 1)
        .map((p) => p.wordId)
        .toSet();

    return _wordsBox.values
        .where((word) => !completedWordIds.contains(word.id))
        .toList();
  }

  /// Get words not fully learned in Level 2
  List<WordProgressModel> getLevel2IncompleteProgress() {
    return _wordProgressBox.values
        .where(
          (p) => p.correctCount < 10 || p.enToBgCount < 3 || p.bgToEnCount < 3,
        )
        .toList();
  }

  /// Count Level 1 completed words
  int countLevel1Completed() {
    return _wordProgressBox.values.where((p) => p.level1Completed == 1).length;
  }

  /// Count fully learned words
  int countLearnedWords() {
    return _wordProgressBox.values
        .where(
          (p) =>
              p.correctCount >= 10 && p.enToBgCount >= 3 && p.bgToEnCount >= 3,
        )
        .length;
  }

  // ============ USER PROGRESS ============

  /// Get or create user progress
  UserProgressModel getUserProgress() {
    var progress = _userProgressBox.get('main');
    if (progress != null) return progress;

    progress = UserProgressModel();
    _userProgressBox.put('main', progress);
    return progress;
  }

  /// Save user progress
  Future<void> saveUserProgress(UserProgressModel progress) async {
    await _userProgressBox.put('main', progress);
  }

  // ============ SETTINGS ============

  /// Get or create settings
  SettingsModel getSettings() {
    var settings = _settingsBox.get('main');
    if (settings != null) return settings;

    settings = SettingsModel();
    _settingsBox.put('main', settings);
    return settings;
  }

  /// Save settings
  Future<void> saveSettings(SettingsModel settings) async {
    await _settingsBox.put('main', settings);
  }
}
