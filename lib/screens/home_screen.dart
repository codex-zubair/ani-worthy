import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/question.dart';
import '../state/quiz_state.dart';
import '../theme/app_theme.dart';
import '../widgets/brand.dart';
import 'quiz_screen.dart';

/// Home: pick a quiz or a category, see personal bests and the fact of the day.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _start(BuildContext context, {String? categoryId, String? title}) {
    context.read<QuizState>().startQuiz(categoryId: categoryId, count: 10);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => QuizScreen(categoryTitle: title),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final QuizState state = context.watch<QuizState>();
    final Fact fact = state.factOfTheDay;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: <Widget>[
        _HeroCard(
          bestOverall: state.bestOverall,
          plays: state.plays,
          onPlay: () => _start(context, title: 'All categories'),
        ),
        const SizedBox(height: 20),
        const _SectionTitle('Categories'),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.35,
          children: state.categories
              .map((QuizCategory c) => _CategoryCard(
                    category: c,
                    best: state.bestFor(c.id),
                    onTap: () => _start(context, categoryId: c.id, title: c.name),
                  ))
              .toList(),
        ),
        const SizedBox(height: 22),
        const _SectionTitle('Did you know?'),
        _FactCard(fact: fact),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.bestOverall,
    required this.plays,
    required this.onPlay,
  });

  final int bestOverall;
  final int plays;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            AppTheme.accent.withValues(alpha: 0.28),
            AppTheme.accent2.withValues(alpha: 0.20),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.accent.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: const <Widget>[
              Text('🎌', style: TextStyle(fontSize: 26)),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Test your anime knowledge',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            '10 quick questions, all offline. How high can you score?',
            style: TextStyle(color: AppTheme.muted, height: 1.45),
          ),
          const SizedBox(height: 18),
          Row(
            children: <Widget>[
              _Stat(label: 'Best', value: '$bestOverall%'),
              const SizedBox(width: 18),
              _Stat(label: 'Quizzes', value: '$plays'),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onPlay,
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Start quiz'),
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: <Widget>[
        Text(
          value,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: AppTheme.muted, fontSize: 13)),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.category,
    required this.best,
    required this.onTap,
  });

  final QuizCategory category;
  final int best;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(category.emoji, style: const TextStyle(fontSize: 26)),
            const Spacer(),
            Text(
              category.name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 2),
            Text(
              category.blurb,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppTheme.muted, fontSize: 11.5),
            ),
            if (best > 0) ...<Widget>[
              const SizedBox(height: 8),
              Pill(label: 'Best $best%', color: AppTheme.gold, icon: Icons.star_rounded),
            ],
          ],
        ),
      ),
    );
  }
}

class _FactCard extends StatelessWidget {
  const _FactCard({required this.fact});

  final Fact fact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Icon(Icons.lightbulb_outline_rounded, color: AppTheme.gold),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              fact.text,
              style: const TextStyle(height: 1.5),
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
      padding: const EdgeInsets.only(left: 4, bottom: 12, top: 6),
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
