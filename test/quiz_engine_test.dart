import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:watchanimetv/core/quiz_engine.dart';
import 'package:watchanimetv/core/trivia_data.dart';

void main() {
  group('TriviaData integrity', () {
    test('every category has at least 8 questions', () {
      final QuizEngine engine = QuizEngine(pool: TriviaData.questions);
      for (final category in TriviaData.categories) {
        expect(
          engine.countFor(category.id),
          greaterThanOrEqualTo(8),
          reason: 'category ${category.id} needs enough questions',
        );
      }
    });

    test('all questions are valid and ids are unique', () {
      final Set<String> ids = <String>{};
      for (final q in TriviaData.questions) {
        expect(q.isValid, isTrue, reason: 'invalid question ${q.id}');
        expect(ids.add(q.id), isTrue, reason: 'duplicate id ${q.id}');
        expect(q.options.length, greaterThanOrEqualTo(2));
        expect(q.answerIndex, inInclusiveRange(0, q.options.length - 1));
      }
    });

    test('question bank is large enough for a 10-question quiz', () {
      expect(TriviaData.questions.length, greaterThanOrEqualTo(60));
    });

    test('facts reference real categories', () {
      final Set<String> catIds =
          TriviaData.categories.map((c) => c.id).toSet();
      for (final f in TriviaData.facts) {
        expect(catIds.contains(f.categoryId), isTrue);
      }
    });
  });

  group('QuizEngine.buildRounds', () {
    test('respects the requested count', () {
      final QuizEngine engine =
          QuizEngine(pool: TriviaData.questions, random: Random(1));
      final rounds = engine.buildRounds(count: 10);
      expect(rounds.length, 10);
    });

    test('caps at the pool size', () {
      final QuizEngine engine =
          QuizEngine(pool: TriviaData.questions, random: Random(1));
      final rounds =
          engine.buildRounds(count: 9999, categoryId: 'studios');
      expect(rounds.length, engine.countFor('studios'));
    });

    test('filters by category', () {
      final QuizEngine engine =
          QuizEngine(pool: TriviaData.questions, random: Random(2));
      final rounds = engine.buildRounds(count: 20, categoryId: 'general');
      expect(rounds.every((r) => r.question.categoryId == 'general'), isTrue);
    });

    test('options preserve the correct answer after shuffling', () {
      final QuizEngine engine =
          QuizEngine(pool: TriviaData.questions, random: Random(3));
      for (final round in engine.buildRounds(count: 30)) {
        expect(round.optionOrder.length, round.question.options.length);
        expect(round.correctSlot, isNot(-1));
        expect(
          round.optionText(round.correctSlot),
          round.question.answer,
        );
        // optionOrder is a permutation of all indices.
        expect(round.optionOrder.toSet().length, round.optionOrder.length);
      }
    });
  });

  group('QuizScore', () {
    test('percent and grade', () {
      expect(const QuizScore(correct: 10, total: 10).percent, 100);
      expect(const QuizScore(correct: 10, total: 10).grade, 'AniLegend');
      expect(const QuizScore(correct: 8, total: 10).grade, 'Otaku Pro');
      expect(const QuizScore(correct: 6, total: 10).grade, 'Seasoned Fan');
      expect(const QuizScore(correct: 4, total: 10).grade, 'Casual Viewer');
      expect(const QuizScore(correct: 1, total: 10).grade, 'Rookie');
      expect(const QuizScore(correct: 0, total: 0).percent, 0);
      expect(const QuizScore(correct: 0, total: 0).grade, '—');
    });
  });
}
