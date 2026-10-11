import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watchanimetv/services/score_store.dart';
import 'package:watchanimetv/state/quiz_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ScoreStore', () {
    test('records category and overall bests', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final ScoreStore store = await ScoreStore.open();

      expect(store.bestFor('studios'), 0);
      final bool record1 =
          await store.record(categoryId: 'studios', percent: 70, streak: 4);
      expect(record1, isTrue);
      expect(store.bestFor('studios'), 70);

      final bool record2 =
          await store.record(categoryId: 'studios', percent: 60, streak: 2);
      expect(record2, isFalse);
      expect(store.bestFor('studios'), 70);

      final bool record3 =
          await store.record(categoryId: 'studios', percent: 90, streak: 6);
      expect(record3, isTrue);
      expect(store.bestFor('studios'), 90);

      expect(store.bestOverall, 90);
      expect(store.bestStreak, 6);
      expect(store.plays, 3);
    });

    test('reset clears everything', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final ScoreStore store = await ScoreStore.open();
      await store.record(categoryId: 'series', percent: 50, streak: 1);
      await store.reset();
      expect(store.bestOverall, 0);
      expect(store.plays, 0);
      expect(store.bestFor('series'), 0);
    });
  });

  group('QuizState', () {
    test('runs a full session and scores it', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final ScoreStore store = await ScoreStore.open();
      final QuizState state = QuizState(store);

      state.startQuiz(categoryId: 'studios', count: 5);
      expect(state.sessionActive, isTrue);
      expect(state.total, 5);

      int guard = 0;
      while (state.sessionActive && guard < 50) {
        final round = state.current!;
        state.answer(round.correctSlot);
        expect(state.isAnswered, isTrue);
        state.next();
        guard++;
      }
      expect(state.sessionActive, isFalse);
      expect(state.answered.length, 5);
      expect(state.score.correct, 5);
      expect(state.score.percent, 100);

      final bool record = await state.finalise();
      expect(record, isTrue);
      expect(state.bestFor('studios'), 100);
    });

    test('answer only registers once per question', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final ScoreStore store = await ScoreStore.open();
      final QuizState state = QuizState(store);
      state.startQuiz(count: 3);
      state.answer(0);
      state.answer(1);
      expect(state.answered.length, 1);
    });

    test('factOfTheDay is one of the bundled facts', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final ScoreStore store = await ScoreStore.open();
      final QuizState state = QuizState(store);
      expect(
        state.categories.any((c) => c.id == state.factOfTheDay.categoryId),
        isTrue,
      );
    });
  });
}
