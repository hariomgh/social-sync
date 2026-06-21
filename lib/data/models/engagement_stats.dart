import 'package:flutter/foundation.dart';

/// Projected or actual engagement for a post on a platform.
@immutable
class EngagementStats {
  const EngagementStats({
    this.likes = 0,
    this.comments = 0,
    this.shares = 0,
    this.views = 0,
  });

  final int likes;
  final int comments;
  final int shares;
  final int views;

  /// Primary interactions (excludes passive views).
  int get total => likes + comments + shares;

  static const EngagementStats zero = EngagementStats();

  EngagementStats operator +(EngagementStats other) => EngagementStats(
        likes: likes + other.likes,
        comments: comments + other.comments,
        shares: shares + other.shares,
        views: views + other.views,
      );
}
