import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/config/api_config.dart';
import '../../models/publish_result.dart';
import '../../models/social_platform.dart';
import 'social_publisher.dart';

/// Publishes to Instagram via the Instagram Graph API (Content Publishing).
///
/// Live flow (requires an Instagram Business/Creator account linked to a
/// Facebook Page and the `instagram_content_publish` permission):
///   1. POST /{ig-user-id}/media           -> creates a media container
///   2. POST /{ig-user-id}/media_publish    -> publishes the container
/// Images must be reachable via public HTTPS URLs, so a real integration first
/// uploads the local file to your own storage/CDN and passes that URL as
/// `image_url`. That upload step is marked below.
class InstagramPublisher extends SocialPublisher {
  InstagramPublisher(this._client);
  final http.Client _client;

  static const String _base = 'https://graph.facebook.com/v19.0';

  @override
  SocialPlatform get platform => SocialPlatform.instagram;

  @override
  PlatformCredentials get credentials => ApiConfig.instagram;

  @override
  Future<PublishOutcome> publishLive(PublishRequest request) async {
    if (!request.hasMedia) {
      return PublishOutcome.failure(platform, 'Instagram requires an image.');
    }
    final String igUserId = request.account!.userId;
    final String token = request.token!.accessToken;

    // STEP 0 (integration point): upload local image to public storage.
    final String imageUrl = await _hostImage(request.mediaPaths.first);

    // STEP 1: create media container.
    final http.Response createRes = await _client.post(
      Uri.parse('$_base/$igUserId/media'),
      body: <String, String>{
        'image_url': imageUrl,
        'caption': request.text,
        'access_token': token,
      },
    );
    if (createRes.statusCode != 200) {
      return PublishOutcome.failure(platform, _err(createRes));
    }
    final String creationId =
        (jsonDecode(createRes.body) as Map<String, dynamic>)['id'] as String;

    // STEP 2: publish the container.
    final http.Response publishRes = await _client.post(
      Uri.parse('$_base/$igUserId/media_publish'),
      body: <String, String>{
        'creation_id': creationId,
        'access_token': token,
      },
    );
    if (publishRes.statusCode != 200) {
      return PublishOutcome.failure(platform, _err(publishRes));
    }
    final String mediaId =
        (jsonDecode(publishRes.body) as Map<String, dynamic>)['id'] as String;
    return PublishOutcome.success(platform,
        url: 'https://www.instagram.com/p/$mediaId');
  }

  /// INTEGRATION POINT: upload [localPath] to your storage and return a public
  /// HTTPS URL. Replace with your S3/Firebase/Cloudinary upload.
  Future<String> _hostImage(String localPath) async {
    throw UnimplementedError(
      'Upload $localPath to public storage and return its HTTPS URL.',
    );
  }

  String _err(http.Response r) =>
      'Instagram API ${r.statusCode}: ${r.body}';
}
