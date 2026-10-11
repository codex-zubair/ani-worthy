import 'package:flutter/foundation.dart';

/// An offline trivia category.
@immutable
class QuizCategory {
  const QuizCategory({
    required this.id,
    required this.name,
    required this.emoji,
    required this.blurb,
  });

  final String id;
  final String name;
  final String emoji;
  final String blurb;
}

/// A single multiple-choice trivia question.
///
/// Content is factual (studios, years, creators, episode counts) — never
/// verbatim dialogue, lyrics or other copyrighted text.
@immutable
class Question {
  const Question({
    required this.id,
    required this.categoryId,
    required this.prompt,
    required this.options,
    required this.answerIndex,
    this.explanation,
  });

  final String id;
  final String categoryId;
  final String prompt;
  final List<String> options;
  final int answerIndex;

  /// Short factual note shown after answering.
  final String? explanation;

  String get answer => options[answerIndex];

  /// Validates the question shape; used by tests and a startup assertion.
  bool get isValid =>
      options.length >= 2 &&
      answerIndex >= 0 &&
      answerIndex < options.length &&
      prompt.trim().isNotEmpty;

  @override
  bool operator ==(Object other) => other is Question && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// A short "did you know" fact shown on the home screen.
@immutable
class Fact {
  const Fact({required this.text, required this.categoryId});

  final String text;
  final String categoryId;
}
