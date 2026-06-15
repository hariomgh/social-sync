import '../models/post.dart';
import '../models/publish_result.dart';
import '../models/social_account.dart';
import '../models/social_platform.dart';
import 'social/facebook_publisher.dart';
import 'social/instagram_publisher.dart';
import 'social/linkedin_publisher.dart';
import 'social/social_publisher.dart';
import 'social/x_publisher.dart';
import 'token_store.dart';

import 'package:http/http.dart' as http;

/// Fans a [Post] out to every selected platform and aggregates the results.
///
/// Per platform it resolves the tailored text, the per-platform cropped media,
/// and the stored OAuth token, then delegates to the matching [SocialPublisher].
class PublishService {
  PublishService({
    required TokenStore tokenStore,
    http.Client? client,
    Map<SocialPlatform, SocialPublisher>? publishers,
  })  : _tokenStore = tokenStore,
        _publishers = publishers ?? _defaultPublishers(client ?? http.Client());

  final TokenStore _tokenStore;
  final Map<SocialPlatform, SocialPublisher> _publishers;

  static Map<SocialPlatform, SocialPublisher> _defaultPublishers(
      http.Client client) {
    return <SocialPlatform, SocialPublisher>{
      SocialPlatform.instagram: InstagramPublisher(client),
      SocialPlatform.facebook: FacebookPublisher(client),
      SocialPlatform.linkedin: LinkedInPublisher(client),
      SocialPlatform.x: XPublisher(client),
    };
  }

  /// Publishes [post] to all its selected platforms.
  ///
  /// [accounts] maps a platform to its connected account (if any). Returns one
  /// [PublishOutcome] per attempted platform.
  Future<List<PublishOutcome>> publish(
    Post post, {
    required Map<SocialPlatform, SocialAccount> accounts,
  }) async {
    final List<Future<PublishOutcome>> jobs = <Future<PublishOutcome>>[];

    for (final SocialPlatform platform in post.selectedPlatforms) {
      final SocialPublisher publisher = _publishers[platform]!;
      final List<String> mediaPaths = post.media
          .map((m) => m.pathFor(platform.id))
          .toList(growable: false);

      jobs.add(_tokenStore.read(platform).then((token) {
        final request = PublishRequest(
          text: post.textFor(platform),
          mediaPaths: mediaPaths,
          account: accounts[platform],
          token: token,
        );
        return publisher.publish(request);
      }));
    }

    return Future.wait(jobs);
  }

  /// Derives the overall post status from a set of outcomes.
  static PostStatus statusFrom(List<PublishOutcome> outcomes) {
    if (outcomes.isEmpty) return PostStatus.failed;
    final bool anySuccess = outcomes.any((o) => o.success);
    final bool anyFailure = outcomes.any((o) => !o.success);
    if (anySuccess && anyFailure) return PostStatus.partiallyFailed;
    return anySuccess ? PostStatus.published : PostStatus.failed;
  }
}
