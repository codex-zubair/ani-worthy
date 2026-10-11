/// App-wide constants: brand identity, links and legal pointers.
///
/// Pure Dart (no Flutter imports) so it can be unit tested and reused.
class AppInfo {
  const AppInfo._();

  static const String name = 'AniWorthy';
  static const String tagline = 'Offline Anime Trivia';
  static const String company = 'codex-zubair';
  static const String version = '1.0.0';
  static const String packageName = 'com.anivala.watchanimetv';

  /// Hosted privacy policy (central GitHub Pages site for all factory apps).
  static const String privacyPolicyUrl =
      'https://codex-zubair.github.io/all_privacy_policy/aniworthy/';

  /// Public source repository.
  static const String githubUrl =
      'https://github.com/codex-zubair/ani-worthy';

  static const String companyUrl = 'https://github.com/codex-zubair';
  static const String contactEmail = 'iam.nmzar@gmail.com';

  /// One-line privacy promise shown in the UI.
  static const String privacyPromise =
      'No internet, no ads, no tracking. Everything runs on your device and '
      'your scores stay with you.';
}
