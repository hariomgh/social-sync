import 'dart:math';

import '../models/engagement_stats.dart';
import '../models/post.dart';
import '../models/social_platform.dart';

/// Produces a deterministic engagement projection for a post on a platform.
///
/// This is a transparent heuristic (not a real prediction): values respond to
/// content signals — media count, hashtags, text length — and are seeded by the
/// post id so they stay stable across rebuilds. Swap in real metrics from the
/// platform APIs in Phase 2.
class EngagementProjector {
  const EngagementProjector();

  static const Map<String, double> _baseReach = <String, double>{
    'instagram': 1200,
    'facebook': 850,
    'linkedin': 520,
    'x': 900,
  };

  static const Map<String, double> _likeRate = <String, double>{
    'instagram': 0.11,
    'facebook': 0.07,
    'linkedin': 0.09,
    'x': 0.08,
  };

  EngagementStats project(Post post, SocialPlatform platform) {
    final String text = post.textFor(platform);
    final int seed = (post.id.hashCode ^ platform.id.hashCode) & 0x7fffffff;
    final Random rng = Random(seed);

    double mult = 1;
    if (post.media.isNotEmpty) {
      mult += 0.4 + 0.1 * min(post.media.length, 4);
    } else if (platform == SocialPlatform.instagram) {
      mult -= 0.5; // IG without media barely reaches
    }

    final int tags = RegExp(r'(?<!\w)#\w+').allMatches(text).length;
    mult += min(tags, 5) * 0.05;

    final int len = text.trim().length;
    if (len >= 80 && len <= 600) {
      mult += 0.15;
    } else if (len > 1500) {
      mult -= 0.1;
    } else if (len == 0) {
      mult -= 0.3;
    }
    mult = mult.clamp(0.2, 2.5);

    final double base = _baseReach[platform.id] ?? 700;
    final double jitter = 0.85 + rng.nextDouble() * 0.3;
    final double reach = base * mult * jitter;

    final double likeRate = _likeRate[platform.id] ?? 0.08;
    final int likes = (reach * likeRate).round();
    final int comments = (likes * (0.06 + rng.nextDouble() * 0.05)).round();
    final int shares = (likes * (0.03 + rng.nextDouble() * 0.05)).round();
    final int views = platform == SocialPlatform.x ? (reach * 1.6).round() : 0;

    return EngagementStats(
      likes: likes,
      comments: comments,
      shares: shares,
      views: views,
    );
  }
}
