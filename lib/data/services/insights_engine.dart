import '../models/insight.dart';
import '../models/post.dart';
import '../models/social_platform.dart';

/// Analyzes a composed [Post] and returns actionable, rule-based insights.
///
/// Pure and dependency-free so it can run on every keystroke and be unit
/// tested. Each insight may carry an [OptimizationAction] the composer applies.
abstract final class InsightsEngine {
  static final RegExp _hashtag = RegExp(r'(?<!\w)#\w+');

  static List<Insight> analyze(Post post) {
    final List<Insight> out = <Insight>[];
    final List<SocialPlatform> selected = post.selectedPlatforms;
    if (selected.isEmpty) return out;

    // X length
    if (selected.contains(SocialPlatform.x) &&
        post.textFor(SocialPlatform.x).length > SocialPlatform.x.maxCharacters) {
      out.add(const Insight(
        title: 'Trim for X',
        message:
            "Your text is over X's 280-character limit, so it can't publish there. Trim it to fit.",
        severity: InsightSeverity.warning,
        action: OptimizationAction.trimForX,
        actionLabel: 'Trim for X',
      ));
    }

    // Instagram needs media
    if (selected.contains(SocialPlatform.instagram) && !post.hasMedia) {
      out.add(const Insight(
        title: 'Instagram needs an image',
        message: 'Add at least one photo so this post can publish to Instagram.',
        severity: InsightSeverity.warning,
      ));
    }

    // LinkedIn multi-image grid
    if (selected.contains(SocialPlatform.linkedin)) {
      if (post.media.length >= 2) {
        out.add(const Insight(
          title: 'Strong multi-image post',
          message:
              'LinkedIn users engage 45% more with posts that feature multi-image grids. Make sure your first image has the highest visual impact to stop the scroll.',
          severity: InsightSeverity.opportunity,
        ));
      } else if (post.media.length == 1) {
        out.add(const Insight(
          title: 'Try a multi-image grid',
          message:
              'Add another image — LinkedIn multi-image posts see about 45% more engagement.',
          severity: InsightSeverity.tip,
        ));
      }
    }

    // Hashtags
    if (post.baseText.trim().isNotEmpty &&
        _hashtag.allMatches(post.baseText).isEmpty) {
      out.add(const Insight(
        title: 'Add hashtags',
        message:
            'Posts with 3–5 relevant hashtags reach more people. Add a few to boost discovery.',
        severity: InsightSeverity.opportunity,
        action: OptimizationAction.addHashtags,
        actionLabel: 'Add hashtags',
      ));
    }

    // Best time
    out.add(const Insight(
      title: 'Post at peak time',
      message:
          'Publishing inside a peak-engagement window can lift reach. Switch to Best-time scheduling.',
      severity: InsightSeverity.opportunity,
      action: OptimizationAction.switchToBestTime,
      actionLabel: 'Use best time',
    ));

    return out;
  }
}
