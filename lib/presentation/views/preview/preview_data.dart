import 'package:flutter/foundation.dart';

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
  });

  final String authorName;
  final String authorHandle;
  final String text;
  final List<String> mediaPaths;
  final String? avatarUrl;
  final String timeLabel;

  /// Whether a real account is connected (affects the avatar/name shown).
  final bool isConnected;

  bool get hasMedia => mediaPaths.isNotEmpty;
}
