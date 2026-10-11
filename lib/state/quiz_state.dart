import 'dart:math';

import 'package:flutter/foundation.dart';

import '../core/quiz_engine.dart';
import '../core/question.dart';
import '../core/trivia_data.dart';
import '../services/score_store.dart';

/// App-wide state: the offline question bank, current quiz session and the
/// locally stored best scores.
class QuizState extends ChangeNotifier {
  QuizState(this._store, {Random? random})
      : _engine = QuizEngine(pool: TriviaData.questions, random: random);

  final ScoreStore _store;
  final QuizEngine _engine;

  // ---- Static content ---------------------------------------------------
  List<QuizCategory> get categories => TriviaData.categories;
  int countFor(String? categoryId) => _engine.countFor(categoryId);

  Fact get factOfTheDay {
    final List<Fact> facts = TriviaData.facts;
    final DateTime now = DateTime.now();
    final int dayIndex = now.year * 372 + now.month * 31 + now.day;
    return facts[dayIndex % facts.length];
  }

  // ---- Best scores ------------------------------------------------------
  int get bestOverall => _store.bestOverall;
  int get plays => _store.plays;
  int get bestStreak => _store.bestStreak;
  int bestFor(String categoryId) => _store.bestFor(categoryId);
  Map<String, int> get allBest => _store.allBest;

  // ---- Live quiz session ------------------------------------------------
  String? _categoryId;
  List<QuizRound> _rounds = <QuizRound>[];
  final List<AnsweredRound> _answered = <AnsweredRound>[];
  int _index = 0;
  int? _chosen; // slot chosen for the current question (null = unanswered)
  int _streak = 0;
  int _bestStreakThisRun = 0;
  bool _sessionActive = false;

  bool get sessionActive => _sessionActive;
  String? get categoryId => _categoryId;
  List<QuizRound> get rounds => List<QuizRound>.unmodifiable(_rounds);
  List<AnsweredRound> get answered => List<AnsweredRound>.unmodifiable(_answered);
  int get index => _index;
  int get total => _rounds.length;
  int get streak => _streak;
  int? get chosen => _chosen;
  bool get isAnswered => _chosen != null;
  bool get isFinished => _sessionActive && _index >= _rounds.length;
  QuizRound? get current => _index < _rounds.length ? _rounds[_index] : null;

  int get correctSoFar =>
      _answered.where((AnsweredRound r) => r.correct).length;

  QuizCategory? get currentCategory {
    if (_categoryId == null) return null;
    for (final QuizCategory c in TriviaData.categories) {
      if (c.id == _categoryId) return c;
    }
    return null;
  }

  /// Starts a fresh quiz. [categoryId] null means "all categories".
  void startQuiz({String? categoryId, int count = 10}) {
    _categoryId = categoryId;
    _rounds = _engine.buildRounds(count: count, categoryId: categoryId);
    _answered.clear();
    _index = 0;
    _chosen = null;
    _streak = 0;
    _bestStreakThisRun = 0;
    _sessionActive = _rounds.isNotEmpty;
    notifyListeners();
  }

  void endQuiz() {
    _sessionActive = false;
    _rounds = <QuizRound>[];
    _answered.clear();
    _index = 0;
    _chosen = null;
    _streak = 0;
    notifyListeners();
  }

  /// Records the chosen slot for the current question (does not advance).
  void answer(int slot) {
    final QuizRound? round = current;
    if (round == null || _chosen != null) return;
    final AnsweredRound record = AnsweredRound(round: round, chosenSlot: slot);
    _answered.add(record);
    _chosen = slot;
    if (record.correct) {
      _streak++;
      if (_streak > _bestStreakThisRun) _bestStreakThisRun = _streak;
    } else {
      _streak = 0;
    }
    notifyListeners();
  }

  /// Advances to the next question (or finishes the session).
  void next() {
    if (_chosen == null) return;
    _index++;
    _chosen = null;
    if (_index >= _rounds.length) {
      _sessionActive = false;
    }
    notifyListeners();
  }

  /// The final score for the completed session.
  QuizScore get score => QuizScore.from(_answered);

  /// Persists the finished session; returns true if a new category record.
  Future<bool> finalise() async {
    final int percent = score.percent;
    final String key = _categoryId ?? 'all';
    return _store.record(
      categoryId: key,
      percent: percent,
      streak: _bestStreakThisRun,
    );
  }

  Future<void> resetScores() async {
    await _store.reset();
    notifyListeners();
  }
}
