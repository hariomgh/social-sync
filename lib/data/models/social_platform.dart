import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// A recommended crop ratio offered for a platform.
@immutable
class AspectRatioOption {
  const AspectRatioOption(this.label, this.ratio);

  /// Human label, e.g. "Square (1:1)".
  final String label;

  /// width / height.
  final double ratio;
}

/// The social networks this app can publish to.
///
/// Each value carries the platform's publishing rules (character limit, media
/// limits, recommended crop ratios) so the composer, validators and previews
/// all read from one source of truth.
enum SocialPlatform {
  instagram(
    id: 'instagram',
    label: 'Instagram',
    handlePrefix: '@',
    brandColor: AppColors.instagram,
    maxCharacters: 2200,
    maxImages: 10,
    requiresMedia: true,
    maxHashtags: 30,
    aspectRatios: <AspectRatioOption>[
      AspectRatioOption('Portrait (4:5)', 4 / 5),
      AspectRatioOption('Square (1:1)', 1),
      AspectRatioOption('Landscape (1.91:1)', 1.91),
    ],
  ),
  facebook(
    id: 'facebook',
    label: 'Facebook',
    handlePrefix: '@',
    brandColor: AppColors.facebook,
    maxCharacters: 63206,
    maxImages: 10,
    requiresMedia: false,
    maxHashtags: 30,
    aspectRatios: <AspectRatioOption>[
      AspectRatioOption('Landscape (1.91:1)', 1.91),
      AspectRatioOption('Square (1:1)', 1),
    ],
  ),
  linkedin(
    id: 'linkedin',
    label: 'LinkedIn',
    handlePrefix: '@',
    brandColor: AppColors.linkedin,
    maxCharacters: 3000,
    maxImages: 9,
    requiresMedia: false,
    maxHashtags: 30,
    aspectRatios: <AspectRatioOption>[
      AspectRatioOption('Landscape (1.91:1)', 1.91),
      AspectRatioOption('Square (1:1)', 1),
    ],
  ),
  x(
    id: 'x',
    label: 'X',
    handlePrefix: '@',
    brandColor: AppColors.x,
    maxCharacters: 280,
    maxImages: 4,
    requiresMedia: false,
    maxHashtags: 10,
    aspectRatios: <AspectRatioOption>[
      AspectRatioOption('Landscape (16:9)', 16 / 9),
      AspectRatioOption('Square (1:1)', 1),
    ],
  );

  const SocialPlatform({
    required this.id,
    required this.label,
    required this.handlePrefix,
    required this.brandColor,
    required this.maxCharacters,
    required this.maxImages,
    required this.requiresMedia,
    required this.maxHashtags,
    required this.aspectRatios,
  });

  final String id;
  final String label;
  final String handlePrefix;
  final Color brandColor;
  final int maxCharacters;
  final int maxImages;

  /// Instagram cannot publish a text-only post.
  final bool requiresMedia;
  final int maxHashtags;
  final List<AspectRatioOption> aspectRatios;

  /// The default crop ratio used when adding media for this platform.
  double get defaultAspectRatio => aspectRatios.first.ratio;

  IconData get icon => switch (this) {
        SocialPlatform.instagram => Icons.camera_alt_rounded,
        SocialPlatform.facebook => Icons.facebook_rounded,
        SocialPlatform.linkedin => Icons.work_rounded,
        SocialPlatform.x => Icons.tag_rounded,
      };

  static SocialPlatform fromId(String id) =>
      SocialPlatform.values.firstWhere((SocialPlatform p) => p.id == id);
}
