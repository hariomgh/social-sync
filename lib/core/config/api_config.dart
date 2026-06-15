/// Per-platform API credentials and the global demo-mode switch.
///
/// HOW THIS APP HANDLES "LIVE" POSTING
/// -----------------------------------
/// Out of the box [demoMode] is `true`, so connecting accounts and publishing
/// are *simulated*: the full composer, validation, scheduling and live previews
/// work in a simulator with zero setup. The real OAuth2 + HTTP publishing code
/// is already written in `lib/data/services/social/*` — it simply isn't called
/// while in demo mode.
///
/// TO GO LIVE
/// ----------
/// 1. Create a developer app on each platform and obtain a client id/secret.
/// 2. Register the redirect URI below as an allowed OAuth callback.
/// 3. Fill in the values in [PlatformCredentials] for each platform.
/// 4. Set [demoMode] to `false`.
/// 5. Configure the deep link scheme on iOS/Android (see README).
///
/// Never commit real secrets — keep them in `api_config.local.dart`
/// (git-ignored) or inject them at build time with `--dart-define`.
abstract final class ApiConfig {
  /// Master switch. `true` = simulate everything (safe demo).
  static const bool demoMode = true;

  /// OAuth deep-link callback handled by the app (see AndroidManifest / Info.plist).
  static const String redirectUri = 'omnipost://oauth-callback';

  static const PlatformCredentials instagram = PlatformCredentials(
    clientId: String.fromEnvironment('IG_CLIENT_ID'),
    clientSecret: String.fromEnvironment('IG_CLIENT_SECRET'),
    // Instagram content publishing runs through the Facebook Graph API.
    scopes: <String>[
      'instagram_basic',
      'instagram_content_publish',
      'pages_show_list',
    ],
    authorizationEndpoint: 'https://api.instagram.com/oauth/authorize',
    tokenEndpoint: 'https://api.instagram.com/oauth/access_token',
  );

  static const PlatformCredentials facebook = PlatformCredentials(
    clientId: String.fromEnvironment('FB_CLIENT_ID'),
    clientSecret: String.fromEnvironment('FB_CLIENT_SECRET'),
    scopes: <String>['pages_manage_posts', 'pages_read_engagement'],
    authorizationEndpoint: 'https://www.facebook.com/v19.0/dialog/oauth',
    tokenEndpoint: 'https://graph.facebook.com/v19.0/oauth/access_token',
  );

  static const PlatformCredentials linkedin = PlatformCredentials(
    clientId: String.fromEnvironment('LI_CLIENT_ID'),
    clientSecret: String.fromEnvironment('LI_CLIENT_SECRET'),
    scopes: <String>['openid', 'profile', 'w_member_social'],
    authorizationEndpoint: 'https://www.linkedin.com/oauth/v2/authorization',
    tokenEndpoint: 'https://www.linkedin.com/oauth/v2/accessToken',
  );

  static const PlatformCredentials x = PlatformCredentials(
    clientId: String.fromEnvironment('X_CLIENT_ID'),
    clientSecret: String.fromEnvironment('X_CLIENT_SECRET'),
    scopes: <String>['tweet.read', 'tweet.write', 'users.read', 'offline.access'],
    authorizationEndpoint: 'https://twitter.com/i/oauth2/authorize',
    tokenEndpoint: 'https://api.twitter.com/2/oauth2/token',
  );
}

/// Immutable bag of OAuth credentials for a single platform.
class PlatformCredentials {
  const PlatformCredentials({
    required this.clientId,
    required this.clientSecret,
    required this.scopes,
    required this.authorizationEndpoint,
    required this.tokenEndpoint,
  });

  final String clientId;
  final String clientSecret;
  final List<String> scopes;
  final String authorizationEndpoint;
  final String tokenEndpoint;

  /// Whether enough is configured to attempt a real OAuth flow.
  bool get isConfigured => clientId.isNotEmpty;
}
