import 'package:flutter/material.dart';

import '../../data/models/social_platform.dart';

/// A circular author avatar. Shows the brand image when available, otherwise
/// renders initials on a tinted background — used across all previews.
class AuthorAvatar extends StatelessWidget {
  const AuthorAvatar({
    super.key,
    required this.name,
    this.imageUrl,
    this.size = 40,
    this.color,
  });

  final String name;
  final String? imageUrl;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final Color bg = color ?? Theme.of(context).colorScheme.primary;
    final String initials = name.trim().isEmpty
        ? '?'
        : name.trim().split(RegExp(r'\s+')).take(2).map((String w) => w[0]).join();
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bg.withOpacity(0.15),
        image: imageUrl != null
            ? DecorationImage(
                image: NetworkImage(imageUrl!), fit: BoxFit.cover)
            : null,
      ),
      alignment: Alignment.center,
      child: imageUrl == null
          ? Text(
              initials.toUpperCase(),
              style: TextStyle(
                color: bg,
                fontWeight: FontWeight.w700,
                fontSize: size * 0.4,
              ),
            )
          : null,
    );
  }
}

/// Small rounded badge showing a platform's icon in its brand color.
class PlatformBadge extends StatelessWidget {
  const PlatformBadge({super.key, required this.platform, this.size = 28});

  final SocialPlatform platform;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: platform.brandColor,
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: Icon(platform.icon, color: Colors.white, size: size * 0.6),
    );
  }
}
