import 'package:flutter/foundation.dart';

/// An OAuth2 token set returned by a platform's token endpoint.
@immutable
class OAuthToken {
  const OAuthToken({
    required this.accessToken,
    this.refreshToken,
    this.tokenType = 'Bearer',
    this.expiresAt,
    this.scope,
  });

  final String accessToken;
  final String? refreshToken;
  final String tokenType;
  final DateTime? expiresAt;
  final String? scope;

  bool get isExpired =>
      expiresAt != null && expiresAt!.isBefore(DateTime.now());

  Map<String, dynamic> toJson() => <String, dynamic>{
        'accessToken': accessToken,
        'refreshToken': refreshToken,
        'tokenType': tokenType,
        'expiresAt': expiresAt?.toIso8601String(),
        'scope': scope,
      };

  factory OAuthToken.fromJson(Map<String, dynamic> json) {
    return OAuthToken(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String?,
      tokenType: json['tokenType'] as String? ?? 'Bearer',
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.parse(json['expiresAt'] as String),
      scope: json['scope'] as String?,
    );
  }

  /// Builds a token from a standard OAuth2 token-endpoint response body.
  factory OAuthToken.fromResponse(Map<String, dynamic> body) {
    final int? expiresIn = (body['expires_in'] as num?)?.toInt();
    return OAuthToken(
      accessToken: body['access_token'] as String,
      refreshToken: body['refresh_token'] as String?,
      tokenType: body['token_type'] as String? ?? 'Bearer',
      expiresAt: expiresIn == null
          ? null
          : DateTime.now().add(Duration(seconds: expiresIn)),
      scope: body['scope'] as String?,
    );
  }
}
