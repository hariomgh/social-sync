import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/config/api_config.dart';
import '../../models/publish_result.dart';
import '../../models/social_platform.dart';
import 'social_publisher.dart';

/// Publishes to X (Twitter) via API v2 `POST /2/tweets`.
///
/// Text posts send `{ "text": ... }` with a Bearer user token. Media must be
/// uploaded first through the v1.1 `media/upload` endpoint; the returned
/// `media_ids` are then attached (see [_uploadMedia]). Note: X's API is a paid
/// product — a project with write access is required.
class XPublisher extends SocialPublisher {
  XPublisher(this._client);
  final http.Client _client;

  static const String _base = 'https://api.twitter.com/2';

  @override
  SocialPlatform get platform => SocialPlatform.x;

  @override
  PlatformCredentials get credentials => ApiConfig.x;

  @override
  Future<PublishOutcome> publishLive(PublishRequest request) async {
    final String token = request.token!.accessToken;

    final List<String> mediaIds = <String>[];
    if (request.hasMedia) {
      for (final String path in request.mediaPaths) {
        mediaIds.add(await _uploadMedia(path, token));
      }
    }

    final Map<String, dynamic> payload = <String, dynamic>{
      'text': request.text,
      if (mediaIds.isNotEmpty)
        'media': <String, dynamic>{'media_ids': mediaIds},
    };

    final http.Response res = await _client.post(
      Uri.parse('$_base/tweets'),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(payload),
    );
    if (res.statusCode != 201) {
      return PublishOutcome.failure(
          platform, 'X API ${res.statusCode}: ${res.body}');
    }
    final Map<String, dynamic> data =
        (jsonDecode(res.body) as Map<String, dynamic>)['data']
            as Map<String, dynamic>;
    final String id = data['id'] as String;
    final String user = request.account?.username ?? 'i';
    return PublishOutcome.success(platform,
        url: 'https://x.com/$user/status/$id');
  }

  /// INTEGRATION POINT: upload bytes to v1.1 media/upload, return media_id_string.
  Future<String> _uploadMedia(String localPath, String token) async {
    throw UnimplementedError(
      'Implement X v1.1 media/upload for $localPath.',
    );
  }
}
