import 'package:flutter/foundation.dart';

import '../../../data/models/engagement_stats.dart';

/// Immutable bundle of everything a preview card needs to render. Keeping the
/// preview widgets "dumb" (data in, UI out) makes them trivial to snapshot-test
/// and reuse.
@immutable
class PreviewData {
  const PreviewData({
    required this.authorName,
    required this.authorHandle,
    required this.text,
    required this.mediaPaths,
    this.avatarUrl,
    this.timeLabel = 'Just now',
    this.isConnected = false,
    this.engagement = EngagementStats.zero,
  });

  final String authorName;
  final String authorHandle;
  final String text;
  final List<String> mediaPaths;
  final String? avatarUrl;
  final String timeLabel;

  /// Whether a real account is connected (affects the avatar/name shown).
  final bool isConnected;

  /// Projected engagement shown on the preview card.
  final EngagementStats engagement;

  bool get hasMedia => mediaPaths.isNotEmpty;
}
