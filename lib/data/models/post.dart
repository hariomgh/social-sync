import 'package:flutter/foundation.dart';

import 'media_attachment.dart';
import 'platform_content.dart';
import 'publish_result.dart';
import 'social_platform.dart';

/// Lifecycle of a post.
enum PostStatus {
  draft('Draft'),
  scheduled('Scheduled'),
  publishing('Publishing'),
  published('Published'),
  partiallyFailed('Partially failed'),
  failed('Failed');

  const PostStatus(this.label);
  final String label;

  static PostStatus fromName(String name) =>
      PostStatus.values.firstWhere((PostStatus s) => s.name == name,
          orElse: () => PostStatus.draft);
}

/// The aggregate root of the composer: one piece of shared content plus the
/// per-platform overrides, media and scheduling that describe how it should be
/// published everywhere.
@immutable
class Post {
  const Post({
    required this.id,
    required this.baseText,
    required this.media,
    required this.overrides,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.scheduledAt,
    this.outcomes = const <PublishOutcome>[],
  });

  final String id;
  final String baseText;
  final List<MediaAttachment> media;
  final Map<SocialPlatform, PlatformContent> overrides;
  final PostStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? scheduledAt;
  final List<PublishOutcome> outcomes;

  /// A blank post with every platform enabled, ready for the composer.
  factory Post.empty(String id, DateTime now) {
    return Post(
      id: id,
      baseText: '',
      media: const <MediaAttachment>[],
      overrides: <SocialPlatform, PlatformContent>{
        for (final SocialPlatform p in SocialPlatform.values)
          p: PlatformContent(platform: p),
      },
      status: PostStatus.draft,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Platforms the user has currently selected.
  List<SocialPlatform> get selectedPlatforms => SocialPlatform.values
      .where((SocialPlatform p) => overrides[p]?.enabled ?? false)
      .toList(growable: false);

  PlatformContent contentFor(SocialPlatform platform) =>
      overrides[platform] ?? PlatformContent(platform: platform);

  /// The exact text that will be published to [platform].
  String textFor(SocialPlatform platform) =>
      contentFor(platform).effectiveText(baseText);

  bool get hasMedia => media.isNotEmpty;
  bool get isEmpty => baseText.trim().isEmpty && media.isEmpty;

  Post copyWith({
    String? baseText,
    List<MediaAttachment>? media,
    Map<SocialPlatform, PlatformContent>? overrides,
    PostStatus? status,
    DateTime? updatedAt,
    DateTime? scheduledAt,
    bool clearScheduledAt = false,
    List<PublishOutcome>? outcomes,
  }) {
    return Post(
      id: id,
      baseText: baseText ?? this.baseText,
      media: media ?? this.media,
      overrides: overrides ?? this.overrides,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      scheduledAt: clearScheduledAt ? null : (scheduledAt ?? this.scheduledAt),
      outcomes: outcomes ?? this.outcomes,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'baseText': baseText,
        'media': media.map((MediaAttachment m) => m.toJson()).toList(),
        'overrides': overrides.map((SocialPlatform k, PlatformContent v) =>
            MapEntry<String, dynamic>(k.id, v.toJson())),
        'status': status.name,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'scheduledAt': scheduledAt?.toIso8601String(),
        'outcomes': outcomes.map((PublishOutcome o) => o.toJson()).toList(),
      };

  factory Post.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> rawOverrides =
        (json['overrides'] as Map<String, dynamic>? ?? <String, dynamic>{});
    return Post(
      id: json['id'] as String,
      baseText: json['baseText'] as String? ?? '',
      media: (json['media'] as List<dynamic>? ?? <dynamic>[])
          .map((dynamic e) =>
              MediaAttachment.fromJson(e as Map<String, dynamic>))
          .toList(),
      overrides: rawOverrides.map(
        (String k, dynamic v) => MapEntry<SocialPlatform, PlatformContent>(
          SocialPlatform.fromId(k),
          PlatformContent.fromJson(v as Map<String, dynamic>),
        ),
      ),
      status: PostStatus.fromName(json['status'] as String? ?? 'draft'),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      scheduledAt: json['scheduledAt'] == null
          ? null
          : DateTime.parse(json['scheduledAt'] as String),
      outcomes: (json['outcomes'] as List<dynamic>? ?? <dynamic>[])
          .map((dynamic e) =>
              PublishOutcome.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  bool operator ==(Object other) => other is Post && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
