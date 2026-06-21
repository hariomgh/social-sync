import '../models/analytics_summary.dart';
import '../models/engagement_stats.dart';
import '../models/post.dart';
import '../models/publish_result.dart';
import '../models/social_platform.dart';
import 'engagement_projector.dart';

/// Builds an [AnalyticsSummary] from the user's posting history.
///
/// Counts and success rates come from real saved posts/outcomes; engagement is
/// derived from [EngagementProjector] until live platform metrics are wired in.
class AnalyticsService {
  const AnalyticsService([this._projector = const EngagementProjector()]);

  final EngagementProjector _projector;

  AnalyticsSummary summarize(List<Post> posts) {
    final List<Post> published = posts
        .where((Post p) =>
            p.status == PostStatus.published ||
            p.status == PostStatus.partiallyFailed)
        .toList();

    final int scheduled =
        posts.where((Post p) => p.status == PostStatus.scheduled).length;
    final int drafts =
        posts.where((Post p) => p.status == PostStatus.draft).length;

    int totalOutcomes = 0;
    int totalSuccess = 0;
    EngagementStats grandTotal = EngagementStats.zero;

    final Map<SocialPlatform, int> counts = <SocialPlatform, int>{};
    final Map<SocialPlatform, int> okCounts = <SocialPlatform, int>{};
    final Map<SocialPlatform, int> attempts = <SocialPlatform, int>{};
    final Map<SocialPlatform, EngagementStats> eng =
        <SocialPlatform, EngagementStats>{};

    for (final Post post in published) {
      for (final PublishOutcome o in post.outcomes) {
        totalOutcomes++;
        attempts[o.platform] = (attempts[o.platform] ?? 0) + 1;
        if (o.success) {
          totalSuccess++;
          okCounts[o.platform] = (okCounts[o.platform] ?? 0) + 1;
          counts[o.platform] = (counts[o.platform] ?? 0) + 1;
          final EngagementStats stats = _projector.project(post, o.platform);
          eng[o.platform] = (eng[o.platform] ?? EngagementStats.zero) + stats;
          grandTotal = grandTotal + stats;
        }
      }
    }

    final List<PlatformStat> perPlatform = <PlatformStat>[];
    for (final SocialPlatform p in SocialPlatform.values) {
      final int attempted = attempts[p] ?? 0;
      if (attempted == 0) continue;
      perPlatform.add(PlatformStat(
        platform: p,
        postCount: counts[p] ?? 0,
        engagement: eng[p] ?? EngagementStats.zero,
        successRate: attempted == 0 ? 0 : (okCounts[p] ?? 0) / attempted,
      ));
    }

    return AnalyticsSummary(
      totalPublished: published.length,
      totalScheduled: scheduled,
      totalDrafts: drafts,
      overallSuccessRate:
          totalOutcomes == 0 ? 0 : totalSuccess / totalOutcomes,
      perPlatform: perPlatform,
      last7Days: _activity(published),
      totalEngagement: grandTotal,
    );
  }

  List<DailyCount> _activity(List<Post> published) {
    final DateTime today = DateTime.now();
    final DateTime start = DateTime(today.year, today.month, today.day);
    final List<DailyCount> days = <DailyCount>[];
    for (int i = 6; i >= 0; i--) {
      final DateTime day = start.subtract(Duration(days: i));
      final int count = published.where((Post p) {
        final DateTime u = p.updatedAt;
        return u.year == day.year && u.month == day.month && u.day == day.day;
      }).length;
      days.add(DailyCount(day, count));
    }
    return days;
  }
}
