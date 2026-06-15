import 'package:flutter/foundation.dart';

import '../../../core/config/api_config.dart';
import '../../models/oauth_token.dart';
import '../../models/publish_result.dart';
import '../../models/social_account.dart';
import '../../models/social_platform.dart';

/// Everything a publisher needs to push one post to one platform.
@immutable
class PublishRequest {
  const PublishRequest({
    required this.text,
    required this.mediaPaths,
    this.account,
    this.token,
  });

  /// Resolved (already per-platform) text.
  final String text;

  /// Local file paths of the (already cropped) images.
  final List<String> mediaPaths;
  final SocialAccount? account;
  final OAuthToken? token;

  bool get hasMedia => mediaPaths.isNotEmpty;
}

/// Contract every platform publisher implements.
///
/// [publish] applies the demo/live decision so individual implementations only
/// have to provide [publishLive]. When [ApiConfig.demoMode] is on, or the
/// platform isn't configured, publishing is simulated so the app is fully
/// demoable without developer accounts.
abstract class SocialPublisher {
  SocialPlatform get platform;
  PlatformCredentials get credentials;

  Future<PublishOutcome> publish(PublishRequest request) async {
    if (ApiConfig.demoMode || !credentials.isConfigured) {
      return _simulate(request);
    }
    if (request.token == null) {
      return PublishOutcome.failure(
        platform,
        '${platform.label} is not connected. Connect it in Accounts first.',
      );
    }
    try {
      return await publishLive(request);
    } catch (e) {
      return PublishOutcome.failure(platform, 'Publish failed: $e');
    }
  }

  /// Real network publish. Implemented per platform.
  @protected
  Future<PublishOutcome> publishLive(PublishRequest request);

  Future<PublishOutcome> _simulate(PublishRequest request) async {
    // Mimic realistic latency and occasional differences between networks.
    await Future<void>.delayed(const Duration(milliseconds: 700));
    final String slug = DateTime.now().millisecondsSinceEpoch.toString();
    return PublishOutcome.success(
      platform,
      url: 'https://${platform.id}.example/p/$slug',
    );
  }
}
