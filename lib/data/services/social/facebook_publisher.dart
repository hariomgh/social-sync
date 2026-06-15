import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/config/api_config.dart';
import '../../models/publish_result.dart';
import '../../models/social_platform.dart';
import 'social_publisher.dart';

/// Publishes to a Facebook Page via the Graph API.
///
/// Text-only posts hit `/{page-id}/feed`; posts with a photo hit
/// `/{page-id}/photos`. A Page access token with `pages_manage_posts` is
/// required (the user id here is the Page id).
class FacebookPublisher extends SocialPublisher {
  FacebookPublisher(this._client);
  final http.Client _client;

  static const String _base = 'https://graph.facebook.com/v19.0';

  @override
  SocialPlatform get platform => SocialPlatform.facebook;

  @override
  PlatformCredentials get credentials => ApiConfig.facebook;

  @override
  Future<PublishOutcome> publishLive(PublishRequest request) async {
    final String pageId = request.account!.userId;
    final String token = request.token!.accessToken;

    final Uri uri = request.hasMedia
        ? Uri.parse('$_base/$pageId/photos')
        : Uri.parse('$_base/$pageId/feed');

    final Map<String, String> body = <String, String>{
      'access_token': token,
      if (request.hasMedia) 'url': await _hostImage(request.mediaPaths.first),
      if (request.hasMedia) 'caption': request.text else 'message': request.text,
    };

    final http.Response res = await _client.post(uri, body: body);
    if (res.statusCode != 200) {
      return PublishOutcome.failure(
          platform, 'Facebook API ${res.statusCode}: ${res.body}');
    }
    final Map<String, dynamic> json =
        jsonDecode(res.body) as Map<String, dynamic>;
    final String id = (json['post_id'] ?? json['id']) as String;
    return PublishOutcome.success(platform,
        url: 'https://www.facebook.com/$id');
  }

  /// INTEGRATION POINT: upload [localPath] to public storage, return HTTPS URL.
  Future<String> _hostImage(String localPath) async {
    throw UnimplementedError(
      'Upload $localPath to public storage and return its HTTPS URL.',
    );
  }
}
