import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/config/api_config.dart';
import '../../models/publish_result.dart';
import '../../models/social_platform.dart';
import 'social_publisher.dart';

/// Publishes to LinkedIn via the UGC Posts API (`/v2/ugcPosts`).
///
/// The author is `urn:li:person:{id}` for personal posts (or
/// `urn:li:organization:{id}` for company pages). Image posts require a
/// three-step asset upload (registerUpload -> PUT bytes -> reference asset),
/// outlined in [_uploadImageAsset].
class LinkedInPublisher extends SocialPublisher {
  LinkedInPublisher(this._client);
  final http.Client _client;

  static const String _base = 'https://api.linkedin.com/v2';

  @override
  SocialPlatform get platform => SocialPlatform.linkedin;

  @override
  PlatformCredentials get credentials => ApiConfig.linkedin;

  @override
  Future<PublishOutcome> publishLive(PublishRequest request) async {
    final String author = 'urn:li:person:${request.account!.userId}';
    final String token = request.token!.accessToken;

    String? assetUrn;
    if (request.hasMedia) {
      assetUrn = await _uploadImageAsset(request.mediaPaths.first, author, token);
    }

    final Map<String, dynamic> payload = <String, dynamic>{
      'author': author,
      'lifecycleState': 'PUBLISHED',
      'specificContent': <String, dynamic>{
        'com.linkedin.ugc.ShareContent': <String, dynamic>{
          'shareCommentary': <String, String>{'text': request.text},
          'shareMediaCategory': assetUrn == null ? 'NONE' : 'IMAGE',
          if (assetUrn != null)
            'media': <Map<String, dynamic>>[
              <String, dynamic>{'status': 'READY', 'media': assetUrn},
            ],
        },
      },
      'visibility': <String, String>{
        'com.linkedin.ugc.MemberNetworkVisibility': 'PUBLIC',
      },
    };

    final http.Response res = await _client.post(
      Uri.parse('$_base/ugcPosts'),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'X-Restli-Protocol-Version': '2.0.0',
      },
      body: jsonEncode(payload),
    );
    if (res.statusCode != 201) {
      return PublishOutcome.failure(
          platform, 'LinkedIn API ${res.statusCode}: ${res.body}');
    }
    final String id = res.headers['x-restli-id'] ?? 'shared';
    return PublishOutcome.success(platform,
        url: 'https://www.linkedin.com/feed/update/$id');
  }

  /// INTEGRATION POINT: registerUpload -> PUT image bytes -> return asset urn.
  Future<String> _uploadImageAsset(
      String localPath, String owner, String token) async {
    throw UnimplementedError(
      'Implement LinkedIn assets registerUpload for $localPath (owner $owner).',
    );
  }
}
