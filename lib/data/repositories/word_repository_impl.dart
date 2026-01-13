import '../../domain/entities/entities.dart';
import '../../domain/repositories/word_repository.dart';
import '../datasources/hive_local_datasource.dart';
import '../models/models.dart';

/// Implementation of WordRepository using Hive
class WordRepositoryImpl implements WordRepository {
  final HiveLocalDataSource _dataSource;

  WordRepositoryImpl(this._dataSource);

  @override
  Future<List<Word>> getAllWords() async {
    final models = _dataSource.getAllWords();
    return models.map(_toEntity).toList();
  }

  @override
  Future<Word?> getWordById(String id) async {
    final model = _dataSource.getWordById(id);
    return model != null ? _toEntity(model) : null;
  }

  @override
  Future<int> getWordCount() async {
    return _dataSource.getWordCount();
  }

  @override
  Future<void> importWords() async {
    await _dataSource.importWordsFromAsset();
  }

  Word _toEntity(WordModel model) {
    return Word(
      id: model.id,
      en: model.en,
      bgList: model.bgList,
      category: model.category,
    );
  }
}
