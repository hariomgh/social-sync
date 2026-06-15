import 'package:flutter_test/flutter_test.dart';
import 'package:social_media_app/core/utils/validators.dart';
import 'package:social_media_app/data/models/media_attachment.dart';
import 'package:social_media_app/data/models/platform_content.dart';
import 'package:social_media_app/data/models/post.dart';
import 'package:social_media_app/data/models/social_platform.dart';

Post _post({
  required String text,
  Set<SocialPlatform> platforms = const <SocialPlatform>{SocialPlatform.x},
}) {
  final DateTime now = DateTime(2026);
  return Post(
    id: 't',
    baseText: text,
    media: const <MediaAttachment>[],
    overrides: <SocialPlatform, PlatformContent>{
      for (final SocialPlatform p in SocialPlatform.values)
        p: PlatformContent(platform: p, enabled: platforms.contains(p)),
    },
    status: PostStatus.draft,
    createdAt: now,
    updatedAt: now,
  );
}

String _repeat(String s, int n) => List<String>.filled(n, s).join();

void main() {
  group('Validators', () {
    test('X over 280 characters produces a blocking error', () {
      final Post post =
          _post(text: _repeat('a', 300), platforms: <SocialPlatform>{SocialPlatform.x});
      final issues = Validators.validate(post);
      expect(issues[SocialPlatform.x], isNotNull);
      expect(issues[SocialPlatform.x]!.any((ValidationIssue i) => i.isError), isTrue);
      expect(Validators.canPublish(post), isFalse);
    });

    test('Instagram requires media', () {
      final Post post = _post(
        text: 'hello',
        platforms: <SocialPlatform>{SocialPlatform.instagram},
      );
      expect(Validators.canPublish(post), isFalse);
    });

    test('short text to X is publishable', () {
      final Post post =
          _post(text: 'hello world', platforms: <SocialPlatform>{SocialPlatform.x});
      expect(Validators.canPublish(post), isTrue);
    });

    test('no selected platform cannot publish', () {
      final Post post = _post(text: 'hi', platforms: const <SocialPlatform>{});
      expect(Validators.canPublish(post), isFalse);
    });
  });
}
