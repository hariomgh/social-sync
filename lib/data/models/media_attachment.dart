import 'package:flutter/foundation.dart';

/// A single image attached to a post.
///
/// [originalPath] points at the picked file. Because each network recommends a
/// different aspect ratio, per-platform cropped copies are stored in [crops]
/// keyed by [SocialPlatform.id]; previews and publishing prefer the crop when
/// present and fall back to the original otherwise.
@immutable
class MediaAttachment {
  const MediaAttachment({
    required this.id,
    required this.originalPath,
    this.mimeType = 'image/jpeg',
    this.crops = const <String, String>{},
    this.width,
    this.height,
  });

  final String id;
  final String originalPath;
  final String mimeType;

  /// platformId -> cropped file path.
  final Map<String, String> crops;
  final int? width;
  final int? height;

  /// Best available file path for [platformId] (crop if available).
  String pathFor(String platformId) => crops[platformId] ?? originalPath;

  MediaAttachment copyWith({
    Map<String, String>? crops,
    int? width,
    int? height,
  }) {
    return MediaAttachment(
      id: id,
      originalPath: originalPath,
      mimeType: mimeType,
      crops: crops ?? this.crops,
      width: width ?? this.width,
      height: height ?? this.height,
    );
  }

  /// Returns a copy with a crop recorded for [platformId].
  MediaAttachment withCrop(String platformId, String croppedPath) {
    return copyWith(
      crops: <String, String>{...crops, platformId: croppedPath},
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'originalPath': originalPath,
        'mimeType': mimeType,
        'crops': crops,
        'width': width,
        'height': height,
      };

  factory MediaAttachment.fromJson(Map<String, dynamic> json) {
    return MediaAttachment(
      id: json['id'] as String,
      originalPath: json['originalPath'] as String,
      mimeType: (json['mimeType'] as String?) ?? 'image/jpeg',
      crops: (json['crops'] as Map<String, dynamic>? ?? <String, dynamic>{})
          .map((String k, dynamic v) => MapEntry<String, String>(k, v as String)),
      width: json['width'] as int?,
      height: json['height'] as int?,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is MediaAttachment && other.id == id && mapEquals(other.crops, crops);

  @override
  int get hashCode => Object.hash(id, Object.hashAll(crops.values));
}
