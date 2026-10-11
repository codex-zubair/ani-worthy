import 'package:shared_preferences/shared_preferences.dart';

/// Stores best scores and simple preferences locally using the platform's
/// private preferences store. Nothing is ever uploaded — AniWorthy requests
/// no permissions and no internet access.
class ScoreStore {
  ScoreStore(this._prefs);

  final SharedPreferences _prefs;

  static const String _kBest = 'aniworthy.best.v1'; // per-category best %
  static const String _kBestAll = 'aniworthy.best.all.v1'; // overall best %
  static const String _kPlays = 'aniworthy.plays.v1';
  static const String _kBestStreak = 'aniworthy.streak.best.v1';

  static Future<ScoreStore> open() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return ScoreStore(prefs);
  }

  int bestFor(String categoryId) => _prefs.getInt('$_kBest.$categoryId') ?? 0;

  int get bestOverall => _prefs.getInt(_kBestAll) ?? 0;

  int get plays => _prefs.getInt(_kPlays) ?? 0;

  int get bestStreak => _prefs.getInt(_kBestStreak) ?? 0;

  Map<String, int> get allBest {
    final Map<String, int> out = <String, int>{};
    for (final String key in _prefs.getKeys()) {
      if (key.startsWith('$_kBest.')) {
        final String cat = key.substring('$_kBest.'.length);
        out[cat] = _prefs.getInt(key) ?? 0;
      }
    }
    return out;
  }

  /// Records a finished quiz. Returns true if it set a new category record.
  Future<bool> record({
    required String categoryId,
    required int percent,
    required int streak,
  }) async {
    final int prev = bestFor(categoryId);
    final bool isRecord = percent > prev;
    if (isRecord) {
      await _prefs.setInt('$_kBest.$categoryId', percent);
    }
    if (percent > bestOverall) {
      await _prefs.setInt(_kBestAll, percent);
    }
    if (streak > bestStreak) {
      await _prefs.setInt(_kBestStreak, streak);
    }
    await _prefs.setInt(_kPlays, plays + 1);
    return isRecord;
  }

  Future<void> reset() async {
    for (final String key in _prefs.getKeys().toList()) {
      if (key.startsWith('aniworthy.')) {
        await _prefs.remove(key);
      }
    }
  }
}
