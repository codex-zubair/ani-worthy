import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/root_shell.dart';
import 'services/score_store.dart';
import 'state/quiz_state.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final ScoreStore store = await ScoreStore.open();
  runApp(AniWorthyApp(store: store));
}

/// AniWorthy — a fully offline, ad-free anime trivia app.
class AniWorthyApp extends StatelessWidget {
  const AniWorthyApp({super.key, required this.store, this.state});

  final ScoreStore store;
  final QuizState? state;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<QuizState>(
      create: (_) => state ?? QuizState(store),
      child: MaterialApp(
        title: 'AniWorthy',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark(),
        home: const RootShell(),
      ),
    );
  }
}
