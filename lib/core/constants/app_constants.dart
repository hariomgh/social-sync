/// App-wide constants and persistence keys.
abstract final class AppConstants {
  static const String appName = 'OmniPost';
  static const String appTagline = 'Compose once. Publish everywhere.';

  /// SharedPreferences keys.
  static const String kPostsBox = 'op_posts_v1';
  static const String kAccountsBox = 'op_accounts_v1';
  static const String kThemeMode = 'op_theme_mode';

  /// Secure storage key prefix for OAuth tokens (per platform id).
  static const String kTokenPrefix = 'op_token_';

  /// Default author shown in previews until a real account is connected.
  static const String demoAuthorName = 'Your Brand';
  static const String demoAuthorHandle = 'yourbrand';
}
