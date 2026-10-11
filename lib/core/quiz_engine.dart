import 'dart:math';

import 'question.dart';

/// A selected question presented with its answer options.
class QuizRound {
  const QuizRound({required this.question, required this.optionOrder});

  final Question question;

  /// Indices into [Question.options] in the order they should be shown.
  final List<int> optionOrder;

  /// The index (within [optionOrder]) of the correct option.
  int get correctSlot => optionOrder.indexOf(question.answerIndex);

  String optionText(int slot) => question.options[optionOrder[slot]];
}

/// One answered round, kept for the review screen.
class AnsweredRound {
  const AnsweredRound({
    required this.round,
    required this.chosenSlot,
  });

  final QuizRound round;

  /// The slot the user chose, or -1 if they ran out of time / skipped.
  final int chosenSlot;

  bool get correct => chosenSlot == round.correctSlot;
}

/// Pure-Dart quiz engine: builds rounds, shuffles options reproducibly and
/// scores answers. No Flutter imports, so it is fully unit-testable.
class QuizEngine {
  QuizEngine({required List<Question> pool, Random? random})
      : _pool = List<Question>.unmodifiable(pool),
        _random = random ?? Random();

  final List<Question> _pool;
  final Random _random;

  /// Builds a quiz of up to [count] questions, optionally limited to a
  /// [categoryId]. Options are shuffled per round.
  List<QuizRound> buildRounds({int count = 10, String? categoryId}) {
    List<Question> pool = categoryId == null
        ? List<Question>.of(_pool)
        : _pool.where((Question q) => q.categoryId == categoryId).toList();
    pool = pool.where((Question q) => q.isValid).toList();
    pool.shuffle(_random);
    if (pool.length > count) {
      pool = pool.sublist(0, count);
    }
    return pool.map(_roundFrom).toList(growable: false);
  }

  QuizRound _roundFrom(Question q) {
    final List<int> order =
        List<int>.generate(q.options.length, (int i) => i)..shuffle(_random);
    return QuizRound(question: q, optionOrder: order);
  }

  /// Number of questions available for a category (null = all).
  int countFor(String? categoryId) => categoryId == null
      ? _pool.length
      : _pool.where((Question q) => q.categoryId == categoryId).length;

  List<Question> get all => _pool;
}

/// Scoring helpers for a finished quiz.
class QuizScore {
  const QuizScore({required this.correct, required this.total});

  final int correct;
  final int total;

  int get percent => total == 0 ? 0 : ((correct / total) * 100).round();

  /// A friendly grade for the results screen.
  String get grade {
    if (total == 0) return '—';
    final int p = percent;
    if (p == 100) return 'AniLegend';
    if (p >= 80) return 'Otaku Pro';
    if (p >= 60) return 'Seasoned Fan';
    if (p >= 40) return 'Casual Viewer';
    return 'Rookie';
  }

  static QuizScore from(List<AnsweredRound> rounds) {
    final int correct = rounds.where((AnsweredRound r) => r.correct).length;
    return QuizScore(correct: correct, total: rounds.length);
  }
}
