import 'package:flutter/foundation.dart';

import 'social_platform.dart';

/// The outcome of publishing a post to a single platform.
@immutable
class PublishOutcome {
  const PublishOutcome({
    required this.platform,
    required this.success,
    this.postUrl,
    this.error,
    required this.timestamp,
  });

  final SocialPlatform platform;
  final bool success;
  final String? postUrl;
  final String? error;
  final DateTime timestamp;

  factory PublishOutcome.success(SocialPlatform platform, {String? url}) {
    return PublishOutcome(
      platform: platform,
      success: true,
      postUrl: url,
      timestamp: DateTime.now(),
    );
  }

  factory PublishOutcome.failure(SocialPlatform platform, String error) {
    return PublishOutcome(
      platform: platform,
      success: false,
      error: error,
      timestamp: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'platform': platform.id,
        'success': success,
        'postUrl': postUrl,
        'error': error,
        'timestamp': timestamp.toIso8601String(),
      };

  factory PublishOutcome.fromJson(Map<String, dynamic> json) {
    return PublishOutcome(
      platform: SocialPlatform.fromId(json['platform'] as String),
      success: json['success'] as bool,
      postUrl: json['postUrl'] as String?,
      error: json['error'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}
