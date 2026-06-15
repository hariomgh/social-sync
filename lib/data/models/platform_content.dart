import 'package:flutter/foundation.dart';

import 'social_platform.dart';

/// Per-platform overrides layered on top of the shared post content.
///
/// When [customText] is `null` the platform inherits the post's base text; set
/// it to tailor the copy for a specific network (e.g. a punchy line for X, a
/// longer story for LinkedIn). [enabled] controls whether the post targets this
/// platform at all.
@immutable
class PlatformContent {
  const PlatformContent({
    required this.platform,
    this.enabled = true,
    this.customText,
  });

  final SocialPlatform platform;
  final bool enabled;
  final String? customText;

  /// `true` when the user has tailored copy for this platform.
  bool get hasCustomText => customText != null;

  /// Resolves the text to publish given the shared [baseText].
  String effectiveText(String baseText) => customText ?? baseText;

  PlatformContent copyWith({
    bool? enabled,
    String? customText,
    bool clearCustomText = false,
  }) {
    return PlatformContent(
      platform: platform,
      enabled: enabled ?? this.enabled,
      customText: clearCustomText ? null : (customText ?? this.customText),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'platform': platform.id,
        'enabled': enabled,
        'customText': customText,
      };

  factory PlatformContent.fromJson(Map<String, dynamic> json) {
    return PlatformContent(
      platform: SocialPlatform.fromId(json['platform'] as String),
      enabled: (json['enabled'] as bool?) ?? true,
      customText: json['customText'] as String?,
    );
  }
}
