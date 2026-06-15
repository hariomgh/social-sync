import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../core/constants/app_constants.dart';
import '../models/oauth_token.dart';
import '../models/social_platform.dart';

/// Securely persists OAuth tokens using the platform keychain / keystore.
///
/// Tokens are intentionally kept out of [SharedPreferences]; only display
/// metadata (in `SocialAccount`) is stored there.
class TokenStore {
  TokenStore([FlutterSecureStorage? storage])
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  final FlutterSecureStorage _storage;

  String _key(SocialPlatform platform) =>
      '${AppConstants.kTokenPrefix}${platform.id}';

  Future<void> save(SocialPlatform platform, OAuthToken token) {
    return _storage.write(
      key: _key(platform),
      value: jsonEncode(token.toJson()),
    );
  }

  Future<OAuthToken?> read(SocialPlatform platform) async {
    final String? raw = await _storage.read(key: _key(platform));
    if (raw == null) return null;
    return OAuthToken.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> delete(SocialPlatform platform) =>
      _storage.delete(key: _key(platform));
}
