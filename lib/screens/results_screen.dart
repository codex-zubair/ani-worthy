import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/quiz_engine.dart';
import '../state/quiz_state.dart';
import '../theme/app_theme.dart';
import '../widgets/brand.dart';

/// Results body shown inside [QuizScreen] after the last question. It saves
/// the score once and offers replay / home.
class ResultsView extends StatefulWidget {
  const ResultsView({super.key, required this.onHome, required this.onReplay});

  final VoidCallback onHome;
  final VoidCallback onReplay;

  @override
  State<ResultsView> createState() => _ResultsViewState();
}

class _ResultsViewState extends State<ResultsView> {
  bool _record = false;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final bool record = await context.read<QuizState>().finalise();
      if (mounted) {
        setState(() {
          _record = record;
          _saved = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final QuizState state = context.watch<QuizState>();
    final QuizScore score = state.score;
    final List<AnsweredRound> answered = state.answered;

    return Column(
      children: <Widget>[
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            children: <Widget>[
              _ScoreCard(score: score, showRecord: _record && _saved),
              const SizedBox(height: 18),
              const _SectionTitle('Review'),
              for (final AnsweredRound r in answered) _ReviewRow(answered: r),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
          child: Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onHome,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: AppTheme.divider),
                    foregroundColor: AppTheme.text,
                  ),
                  child: const Text('Home'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: widget.onReplay,
                  child: const Text('Play again'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({required this.score, required this.showRecord});

  final QuizScore score;
  final bool showRecord;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            AppTheme.accent.withValues(alpha: 0.26),
            AppTheme.accent2.withValues(alpha: 0.20),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.accent.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: <Widget>[
          if (showRecord)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Pill(
                label: 'New personal best!',
                color: AppTheme.gold,
                icon: Icons.emoji_events_rounded,
              ),
            ),
          Text(
            '${score.percent}%',
            style: const TextStyle(fontSize: 56, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Text(
            '${score.correct} of ${score.total} correct',
            style: const TextStyle(color: AppTheme.muted, fontSize: 15),
          ),
          const SizedBox(height: 14),
          Pill(label: score.grade, color: AppTheme.accent2),
        ],
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({required this.answered});

  final AnsweredRound answered;

  @override
  Widget build(BuildContext context) {
    final bool ok = answered.correct;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: ok
              ? AppTheme.good.withValues(alpha: 0.4)
              : AppTheme.bad.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            ok ? Icons.check_circle_rounded : Icons.cancel_rounded,
            color: ok ? AppTheme.good : AppTheme.bad,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  answered.round.question.prompt,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Answer: ${answered.round.question.answer}',
                  style: const TextStyle(
                    color: AppTheme.good,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (!ok && answered.chosenSlot >= 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Text(
                      'You chose: '
                      '${answered.round.optionText(answered.chosenSlot)}',
                      style: const TextStyle(color: AppTheme.bad, fontSize: 13),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10, top: 4),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          color: AppTheme.muted,
          fontSize: 11.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.4,
        ),
      ),
    );
  }
}
