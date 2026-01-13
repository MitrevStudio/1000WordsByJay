import '../../domain/entities/entities.dart';
import '../../domain/repositories/progress_repository.dart';
import '../datasources/hive_local_datasource.dart';
import '../models/models.dart';

/// Implementation of ProgressRepository using Hive
class ProgressRepositoryImpl implements ProgressRepository {
  final HiveLocalDataSource _dataSource;

  ProgressRepositoryImpl(this._dataSource);

  @override
  Future<WordProgress?> getWordProgress(String wordId) async {
    final model = _dataSource.getWordProgress(wordId);
    return model != null ? _toWordProgressEntity(model) : null;
  }

  @override
  Future<List<WordProgress>> getAllWordProgress() async {
    final models = _dataSource.getAllWordProgress();
    return models.map(_toWordProgressEntity).toList();
  }

  @override
  Future<void> saveWordProgress(WordProgress progress) async {
    var existing = _dataSource.getWordProgress(progress.wordId);

    final WordProgressModel model;
    if (existing != null) {
      model = existing;
    } else {
      model = WordProgressModel.create(wordId: progress.wordId);
    }

    model.level1Completed = progress.level1Completed ? 1 : 0;
    model.correctCount = progress.correctCount;
    model.enToBgCount = progress.enToBgCount;
    model.bgToEnCount = progress.bgToEnCount;
    model.lastAnswered = progress.lastAnswered;
    model.skipCount = progress.skipCount;
    model.easeFactor = progress.easeFactor;
    model.interval = progress.interval;
    model.nextReviewDate = progress.nextReviewDate;
    model.consecutiveCorrect = progress.consecutiveCorrect;

    await _dataSource.saveWordProgress(model);
  }

  @override
  Future<UserProgress> getUserProgress() async {
    final model = _dataSource.getUserProgress();
    return _toUserProgressEntity(model);
  }

  @override
  Future<void> saveUserProgress(UserProgress progress) async {
    final model = _dataSource.getUserProgress();
    model.currentLevel = progress.currentLevel;
    model.totalCorrect = progress.totalCorrect;
    model.level1WordsCompleted = progress.level1WordsCompleted;
    model.level2WordsLearned = progress.level2WordsLearned;
    model.todayCorrect = progress.todayCorrect;
    model.lastPracticeDate = progress.lastPracticeDate;
    model.dayStreak = progress.dayStreak;
    await _dataSource.saveUserProgress(model);
  }

  @override
  Future<List<Word>> getLevel1IncompleteWords() async {
    final models = _dataSource.getLevel1IncompleteWords();
    return models
        .map(
          (m) =>
              Word(id: m.id, en: m.en, bgList: m.bgList, category: m.category),
        )
        .toList();
  }

  @override
  Future<List<WordProgress>> getLevel2IncompleteProgress() async {
    final models = _dataSource.getLevel2IncompleteProgress();
    return models.map(_toWordProgressEntity).toList();
  }

  @override
  Future<int> countLevel1Completed() async {
    return _dataSource.countLevel1Completed();
  }

  @override
  Future<int> countLearnedWords() async {
    return _dataSource.countLearnedWords();
  }

  WordProgress _toWordProgressEntity(WordProgressModel model) {
    return WordProgress(
      wordId: model.wordId,
      level1Completed: model.level1Completed == 1,
      correctCount: model.correctCount,
      enToBgCount: model.enToBgCount,
      bgToEnCount: model.bgToEnCount,
      lastAnswered: model.lastAnswered,
      skipCount: model.skipCount,
      easeFactor: model.easeFactor,
      interval: model.interval,
      nextReviewDate: model.nextReviewDate,
      consecutiveCorrect: model.consecutiveCorrect,
    );
  }

  UserProgress _toUserProgressEntity(UserProgressModel model) {
    return UserProgress(
      currentLevel: model.currentLevel,
      totalCorrect: model.totalCorrect,
      level1WordsCompleted: model.level1WordsCompleted,
      level2WordsLearned: model.level2WordsLearned,
      todayCorrect: model.todayCorrect,
      lastPracticeDate: model.lastPracticeDate,
      dayStreak: model.dayStreak,
    );
  }
}
