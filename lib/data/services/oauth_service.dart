import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:app_links/app_links.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../../core/config/api_config.dart';
import '../../core/utils/result.dart';
import '../models/oauth_token.dart';
import '../models/social_account.dart';
import '../models/social_platform.dart';

/// The pair returned by a successful authorization.
@immutable
class OAuthResult {
  const OAuthResult(this.account, this.token);
  final SocialAccount account;
  final OAuthToken token;
}

/// Handles the OAuth2 Authorization Code flow with PKCE for every platform.
///
/// In demo mode (or when a platform isn't configured) it returns a simulated
/// account + token so the Accounts screen and publishing work end-to-end with
/// no developer setup. With real credentials it performs the standard flow:
/// build the authorize URL -> open the browser -> capture the redirect deep
/// link -> exchange the code for tokens -> fetch the profile.
class OAuthService {
  OAuthService({http.Client? client, AppLinks? appLinks})
      : _client = client ?? http.Client(),
        _appLinks = appLinks ?? AppLinks();

  final http.Client _client;
  final AppLinks _appLinks;

  PlatformCredentials credentialsFor(SocialPlatform platform) =>
      switch (platform) {
        SocialPlatform.instagram => ApiConfig.instagram,
        SocialPlatform.facebook => ApiConfig.facebook,
        SocialPlatform.linkedin => ApiConfig.linkedin,
        SocialPlatform.x => ApiConfig.x,
      };

  Future<Result<OAuthResult>> connect(SocialPlatform platform) async {
    final PlatformCredentials creds = credentialsFor(platform);
    if (ApiConfig.demoMode || !creds.isConfigured) {
      return Success<OAuthResult>(_demo(platform));
    }
    try {
      return await _authorize(platform, creds);
    } catch (e) {
      return Failure<OAuthResult>('Could not connect ${platform.label}', e);
    }
  }

  Future<Result<OAuthResult>> _authorize(
      SocialPlatform platform, PlatformCredentials creds) async {
    final String verifier = _randomString(64);
    final String challenge = _codeChallenge(verifier);
    final String state = _randomString(24);

    final Uri authUri = Uri.parse(creds.authorizationEndpoint).replace(
      queryParameters: <String, String>{
        'response_type': 'code',
        'client_id': creds.clientId,
        'redirect_uri': ApiConfig.redirectUri,
        'scope': creds.scopes.join(' '),
        'state': state,
        'code_challenge': challenge,
        'code_challenge_method': 'S256',
      },
    );

    // Begin listening for the redirect before launching the browser.
    final Future<Uri> redirectFuture = _appLinks.uriLinkStream
        .firstWhere((Uri uri) =>
            uri.toString().startsWith(ApiConfig.redirectUri) &&
            uri.queryParameters['state'] == state)
        .timeout(const Duration(minutes: 5));

    if (!await launchUrl(authUri, mode: LaunchMode.externalApplication)) {
      return Failure<OAuthResult>('Could not open ${platform.label} sign-in.');
    }

    final Uri redirect = await redirectFuture;
    final String? code = redirect.queryParameters['code'];
    if (code == null) {
      final String err = redirect.queryParameters['error'] ?? 'no code returned';
      return Failure<OAuthResult>('Authorization denied: $err');
    }

    final OAuthToken token =
        await _exchangeCode(creds, code: code, verifier: verifier);
    final SocialAccount account =
        await _fetchProfile(platform, token);
    return Success<OAuthResult>(OAuthResult(account, token));
  }

  Future<OAuthToken> _exchangeCode(
    PlatformCredentials creds, {
    required String code,
    required String verifier,
  }) async {
    final http.Response res = await _client.post(
      Uri.parse(creds.tokenEndpoint),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
        'Accept': 'application/json',
      },
      body: <String, String>{
        'grant_type': 'authorization_code',
        'code': code,
        'redirect_uri': ApiConfig.redirectUri,
        'client_id': creds.clientId,
        'client_secret': creds.clientSecret,
        'code_verifier': verifier,
      },
    );
    if (res.statusCode != 200) {
      throw Exception('Token exchange failed ${res.statusCode}: ${res.body}');
    }
    return OAuthToken.fromResponse(jsonDecode(res.body) as Map<String, dynamic>);
  }

  /// Fetches the connected user's profile. Endpoints differ per platform; this
  /// returns a minimal account if the profile call is not implemented.
  Future<SocialAccount> _fetchProfile(
      SocialPlatform platform, OAuthToken token) async {
    // INTEGRATION POINT: call each platform's "me" endpoint to fill in the
    // display name, username and id. Left minimal here so the flow compiles.
    return SocialAccount(
      platform: platform,
      userId: 'me',
      displayName: platform.label,
      username: platform.id,
      tokenExpiry: token.expiresAt,
    );
  }

  OAuthResult _demo(SocialPlatform platform) {
    final OAuthToken token = OAuthToken(
      accessToken: 'demo-${platform.id}-token',
      expiresAt: DateTime.now().add(const Duration(days: 60)),
    );
    final SocialAccount account = SocialAccount(
      platform: platform,
      userId: 'demo-${platform.id}',
      displayName: 'Your Brand',
      username: 'yourbrand',
      tokenExpiry: token.expiresAt,
    );
    return OAuthResult(account, token);
  }

  // --- PKCE helpers -------------------------------------------------------

  static const String _unreserved =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';

  String _randomString(int length) {
    final Random rng = Random.secure();
    return List<String>.generate(
      length,
      (_) => _unreserved[rng.nextInt(_unreserved.length)],
    ).join();
  }

  String _codeChallenge(String verifier) {
    final List<int> digest = sha256.convert(utf8.encode(verifier)).bytes;
    return base64UrlEncode(digest).replaceAll('=', '');
  }
}
