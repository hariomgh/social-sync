import 'package:characters/characters.dart';

import '../../data/models/post.dart';
import '../../data/models/social_platform.dart';
import 'extensions.dart';

/// A single validation finding for a platform.
class ValidationIssue {
  const ValidationIssue(this.message, {this.isError = true});
  final String message;

  /// Errors block publishing; warnings are advisory.
  final bool isError;
}

/// Stateless per-platform validation derived from each [SocialPlatform]'s rules.
abstract final class Validators {
  /// Returns issues for every selected platform in [post].
  static Map<SocialPlatform, List<ValidationIssue>> validate(Post post) {
    final Map<SocialPlatform, List<ValidationIssue>> result =
        <SocialPlatform, List<ValidationIssue>>{};

    for (final SocialPlatform platform in post.selectedPlatforms) {
      final List<ValidationIssue> issues = <ValidationIssue>[];
      final String text = post.textFor(platform);
      final int length = text.characters.length;

      if (length > platform.maxCharacters) {
        issues.add(ValidationIssue(
          'Over the ${platform.maxCharacters}-character limit by '
          '${length - platform.maxCharacters}.',
        ));
      }
      if (platform.requiresMedia && !post.hasMedia) {
        issues.add(const ValidationIssue('Needs at least one image.'));
      }
      if (post.media.length > platform.maxImages) {
        issues.add(ValidationIssue(
          'Only ${platform.maxImages} images allowed; '
          '${post.media.length} attached.',
        ));
      }
      if (text.trim().isEmpty && !post.hasMedia) {
        issues.add(const ValidationIssue('Post is empty.'));
      }
      final int tags = text.hashtags.length;
      if (tags > platform.maxHashtags) {
        issues.add(ValidationIssue(
          'More than ${platform.maxHashtags} hashtags may look spammy.',
          isError: false,
        ));
      }
      if (issues.isNotEmpty) result[platform] = issues;
    }
    return result;
  }

  /// `true` when every selected platform is free of blocking errors.
  static bool canPublish(Post post) {
    if (post.selectedPlatforms.isEmpty) return false;
    final Map<SocialPlatform, List<ValidationIssue>> issues = validate(post);
    return !issues.values
        .any((List<ValidationIssue> list) => list.any((i) => i.isError));
  }
}
