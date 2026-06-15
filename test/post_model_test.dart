import 'package:flutter_test/flutter_test.dart';
import 'package:social_media_app/data/models/platform_content.dart';
import 'package:social_media_app/data/models/post.dart';
import 'package:social_media_app/data/models/social_platform.dart';

void main() {
  group('Post', () {
    test('round-trips through JSON', () {
      final DateTime now = DateTime(2026, 1, 1);
      final Post post =
          Post.empty('id1', now).copyWith(baseText: 'Hello #world @team');

      final Post back = Post.fromJson(post.toJson());

      expect(back.id, 'id1');
      expect(back.baseText, 'Hello #world @team');
      expect(back.selectedPlatforms.length, SocialPlatform.values.length);
      expect(back.status, PostStatus.draft);
    });

    test('per-platform override changes the resolved text', () {
      final DateTime now = DateTime(2026);
      Post post = Post.empty('id', now).copyWith(baseText: 'base');

      final Map<SocialPlatform, PlatformContent> overrides =
          Map<SocialPlatform, PlatformContent>.of(post.overrides);
      overrides[SocialPlatform.x] = const PlatformContent(
        platform: SocialPlatform.x,
        customText: 'a tighter tweet',
      );
      post = post.copyWith(overrides: overrides);

      expect(post.textFor(SocialPlatform.x), 'a tighter tweet');
      expect(post.textFor(SocialPlatform.facebook), 'base');
    });

    test('toggling a platform off removes it from selectedPlatforms', () {
      final DateTime now = DateTime(2026);
      Post post = Post.empty('id', now);
      final Map<SocialPlatform, PlatformContent> overrides =
          Map<SocialPlatform, PlatformContent>.of(post.overrides);
      overrides[SocialPlatform.facebook] =
          overrides[SocialPlatform.facebook]!.copyWith(enabled: false);
      post = post.copyWith(overrides: overrides);

      expect(post.selectedPlatforms.contains(SocialPlatform.facebook), isFalse);
      expect(post.selectedPlatforms.length, SocialPlatform.values.length - 1);
    });
  });
}
