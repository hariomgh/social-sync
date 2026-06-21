import 'package:flutter/foundation.dart';

import 'engagement_stats.dart';
import 'social_platform.dart';

/// Per-platform rollup used by the analytics screen.
@immutable
class PlatformStat {
  const PlatformStat({
    required this.platform,
    required this.postCount,
    required this.engagement,
    required this.successRate,
  });

  final SocialPlatform platform;
  final int postCount;
  final EngagementStats engagement;
  final double successRate; // 0..1
}

/// Count of posts published on a given day (for the activity chart).
@immutable
class DailyCount {
  const DailyCount(this.day, this.count);
  final DateTime day;
  final int count;
}

/// Aggregated analytics across the user's posting history.
@immutable
class AnalyticsSummary {
  const AnalyticsSummary({
    required this.totalPublished,
    required this.totalScheduled,
    required this.totalDrafts,
    required this.overallSuccessRate,
    required this.perPlatform,
    required this.last7Days,
    required this.totalEngagement,
  });

  final int totalPublished;
  final int totalScheduled;
  final int totalDrafts;
  final double overallSuccessRate;
  final List<PlatformStat> perPlatform;
  final List<DailyCount> last7Days;
  final EngagementStats totalEngagement;

  bool get isEmpty => totalPublished == 0 && totalScheduled == 0 && totalDrafts == 0;

  /// Platform with the highest total engagement, if any.
  PlatformStat? get topPlatform {
    if (perPlatform.isEmpty) return null;
    final List<PlatformStat> sorted = <PlatformStat>[...perPlatform]
      ..sort((PlatformStat a, PlatformStat b) =>
          b.engagement.total.compareTo(a.engagement.total));
    return sorted.first.engagement.total > 0 ? sorted.first : null;
  }

  static const AnalyticsSummary empty = AnalyticsSummary(
    totalPublished: 0,
    totalScheduled: 0,
    totalDrafts: 0,
    overallSuccessRate: 0,
    perPlatform: <PlatformStat>[],
    last7Days: <DailyCount>[],
    totalEngagement: EngagementStats.zero,
  );
}
