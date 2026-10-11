import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/quiz_engine.dart';
import '../state/quiz_state.dart';
import '../theme/app_theme.dart';
import '../widgets/brand.dart';
import 'results_screen.dart';

/// One-question-at-a-time quiz flow with immediate feedback.
class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key, this.categoryTitle});

  final String? categoryTitle;

  @override
  Widget build(BuildContext context) {
    final QuizState state = context.watch<QuizState>();

    if (!state.sessionActive && state.answered.isEmpty) {
      // Empty pool — nothing to play.
      return Scaffold(
        appBar: AppBar(title: Text(categoryTitle ?? 'AniWorthy')),
        body: const Center(child: Text('No questions available.')),
      );
    }
    if (!state.sessionActive) {
      return Scaffold(
        appBar: AppBar(title: Text(categoryTitle ?? 'AniWorthy')),
        body: SafeArea(
          child: ResultsView(
            onHome: () => Navigator.of(context).pop(),
            onReplay: () => context.read<QuizState>().startQuiz(
                  categoryId: state.categoryId,
                  count: 10,
                ),
          ),
        ),
      );
    }

    final QuizRound round = state.current!;
    final bool answered = state.isAnswered;
    final int? chosen = state.chosen;

    return Scaffold(
      appBar: AppBar(
        title: Text(categoryTitle ?? 'AniWorthy'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          tooltip: 'Quit',
          onPressed: () {
            context.read<QuizState>().endQuiz();
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(
                        'Question ${state.index + 1} of ${state.total}',
                        style: const TextStyle(
                          color: AppTheme.muted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      if (state.streak > 1)
                        Pill(
                          label: '🔥 ${state.streak} streak',
                          color: AppTheme.gold,
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: state.total == 0 ? 0 : state.index / state.total,
                      minHeight: 7,
                      backgroundColor: AppTheme.surface,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(AppTheme.accent),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      round.question.prompt,
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 22),
                    for (int slot = 0; slot < round.optionOrder.length; slot++)
                      _OptionTile(
                        text: round.optionText(slot),
                        state: !answered
                            ? _TileState.idle
                            : _tileStateFor(slot, chosen!, round.correctSlot),
                        onTap: answered
                            ? null
                            : () => context.read<QuizState>().answer(slot),
                      ),
                    if (answered && round.question.explanation != null) ...<
                        Widget>[
                      const SizedBox(height: 8),
                      _Explanation(text: round.question.explanation!),
                    ],
                  ],
                ),
              ),
            ),
            if (answered)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => context.read<QuizState>().next(),
                    child: Text(
                      state.index + 1 >= state.total
                          ? 'See results'
                          : 'Next question',
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  _TileState _tileStateFor(int slot, int chosen, int correctSlot) {
    if (slot == correctSlot) return _TileState.correct;
    if (slot == chosen) return _TileState.wrong;
    return _TileState.idle;
  }
}

enum _TileState { idle, correct, wrong }

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.text,
    required this.state,
    required this.onTap,
  });

  final String text;
  final _TileState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    Color border = AppTheme.divider;
    Color bg = AppTheme.surface;
    IconData? trailing;
    Color? trailingColor;

    if (state == _TileState.correct) {
      border = AppTheme.good;
      bg = AppTheme.good.withValues(alpha: 0.12);
      trailing = Icons.check_circle_rounded;
      trailingColor = AppTheme.good;
    } else if (state == _TileState.wrong) {
      border = AppTheme.bad;
      bg = AppTheme.bad.withValues(alpha: 0.12);
      trailing = Icons.cancel_rounded;
      trailingColor = AppTheme.bad;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border, width: 1.5),
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (trailing != null)
                Icon(trailing, color: trailingColor, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _Explanation extends StatelessWidget {
  const _Explanation({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceAlt,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Icon(Icons.info_outline_rounded,
              size: 18, color: AppTheme.accent2),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppTheme.muted,
                height: 1.45,
                fontSize: 13.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
