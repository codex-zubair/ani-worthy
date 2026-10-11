import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watchanimetv/main.dart';
import 'package:watchanimetv/services/score_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('AniWorthy shows the offline home screen',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final ScoreStore store = await ScoreStore.open();

    await tester.pumpWidget(AniWorthyApp(store: store));
    await tester.pumpAndSettle();

    // Branding and the privacy chip are present.
    expect(find.text('AniWorthy'), findsWidgets);
    expect(find.text('Offline'), findsOneWidget);

    // Home hero and categories exist.
    expect(find.text('Start quiz'), findsOneWidget);
    expect(find.text('Studios'), findsOneWidget);

    // All three destinations exist in the bottom bar.
    expect(find.text('Quiz'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('About'), findsOneWidget);
  });

  testWidgets('starting a quiz shows the first question',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final ScoreStore store = await ScoreStore.open();

    await tester.pumpWidget(AniWorthyApp(store: store));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Start quiz'));
    await tester.pumpAndSettle();

    expect(find.text('Question 1 of 10'), findsOneWidget);
    expect(find.textContaining('Quit'), findsNothing); // icon only
    expect(find.byIcon(Icons.close_rounded), findsOneWidget);
  });

  testWidgets('About tab exposes the privacy policy button',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final ScoreStore store = await ScoreStore.open();

    await tester.pumpWidget(AniWorthyApp(store: store));
    await tester.pumpAndSettle();

    await tester.tap(find.text('About'));
    await tester.pumpAndSettle();

    expect(find.text('Read Privacy Policy'), findsOneWidget);
    expect(find.text('Private by design'), findsOneWidget);
  });
}
