import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/quiz_state.dart';
import '../theme/app_theme.dart';

/// Simple settings: view and reset locally stored scores.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final QuizState state = context.watch<QuizState>();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: <Widget>[
        const _SectionTitle('Your scores'),
        _Card(
          children: <Widget>[
            _Row(
              icon: Icons.emoji_events_rounded,
              title: 'Best overall',
              value: '${state.bestOverall}%',
            ),
            _Row(
              icon: Icons.play_circle_outline_rounded,
              title: 'Quizzes played',
              value: '${state.plays}',
            ),
            _Row(
              icon: Icons.local_fire_department_rounded,
              title: 'Best streak',
              value: '${state.bestStreak}',
            ),
          ],
        ),
        const SizedBox(height: 18),
        const _SectionTitle('Categories'),
        _Card(
          children: <Widget>[
            for (final dynamic c in state.categories)
              _Row(
                icon: Icons.quiz_outlined,
                title: '${c.emoji}  ${c.name}',
                value: '${state.bestFor(c.id as String)}%',
              ),
          ],
        ),
        const SizedBox(height: 18),
        _Card(
          children: <Widget>[
            _Row(
              icon: Icons.delete_sweep_outlined,
              title: 'Reset all scores',
              subtitle: 'Clears best scores stored on this device',
              onTap: () => _confirmReset(context, state),
            ),
          ],
        ),
        const SizedBox(height: 18),
        const _SectionTitle('Privacy'),
        const _Card(
          children: <Widget>[
            _InfoRow(
              icon: Icons.wifi_off_rounded,
              text: 'No internet permission. AniWorthy cannot reach the network.',
            ),
            _InfoRow(
              icon: Icons.block_rounded,
              text: 'No ads, no analytics, no trackers.',
            ),
            _InfoRow(
              icon: Icons.phone_android_rounded,
              text: 'Questions are bundled in the app; scores never leave it.',
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _confirmReset(BuildContext context, QuizState state) async {
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Reset all scores?'),
        content: const Text(
          'This clears your best scores and quiz count from this device. '
          'It cannot be undone.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (ok ?? false) {
      await state.resetScores();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Scores reset.')),
        );
      }
    }
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10, top: 6),
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

class _Card extends StatelessWidget {
  const _Card({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(children: children),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.icon,
    required this.title,
    this.value,
    this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? value;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        child: Row(
          children: <Widget>[
            Icon(icon, size: 20, color: AppTheme.accent2),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(title,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  if (subtitle != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        subtitle!,
                        style: const TextStyle(
                            color: AppTheme.muted, fontSize: 12),
                      ),
                    ),
                ],
              ),
            ),
            if (value != null)
              Text(
                value!,
                style: const TextStyle(
                  color: AppTheme.muted,
                  fontWeight: FontWeight.w800,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 18, color: AppTheme.accent),
          const SizedBox(width: 14),
          Expanded(
            child: Text(text,
                style: const TextStyle(color: AppTheme.muted, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
