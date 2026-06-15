import 'package:flutter/foundation.dart';

import 'social_platform.dart';

/// A connected social account. OAuth tokens are NOT stored here — they live in
/// secure storage keyed by platform id; this model only holds display metadata
/// and connection status that is safe to persist in plain preferences.
@immutable
class SocialAccount {
  const SocialAccount({
    required this.platform,
    required this.userId,
    required this.displayName,
    required this.username,
    this.avatarUrl,
    this.tokenExpiry,
  });

  final SocialPlatform platform;
  final String userId;
  final String displayName;
  final String username;
  final String? avatarUrl;
  final DateTime? tokenExpiry;

  bool get isExpired =>
      tokenExpiry != null && tokenExpiry!.isBefore(DateTime.now());

  String get handle => '${platform.handlePrefix}$username';

  SocialAccount copyWith({
    String? displayName,
    String? username,
    String? avatarUrl,
    DateTime? tokenExpiry,
  }) {
    return SocialAccount(
      platform: platform,
      userId: userId,
      displayName: displayName ?? this.displayName,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      tokenExpiry: tokenExpiry ?? this.tokenExpiry,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'platform': platform.id,
        'userId': userId,
        'displayName': displayName,
        'username': username,
        'avatarUrl': avatarUrl,
        'tokenExpiry': tokenExpiry?.toIso8601String(),
      };

  factory SocialAccount.fromJson(Map<String, dynamic> json) {
    return SocialAccount(
      platform: SocialPlatform.fromId(json['platform'] as String),
      userId: json['userId'] as String,
      displayName: json['displayName'] as String,
      username: json['username'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      tokenExpiry: json['tokenExpiry'] == null
          ? null
          : DateTime.parse(json['tokenExpiry'] as String),
    );
  }
}
