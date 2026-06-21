import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/format.dart';
import '../../../widgets/avatars.dart';
import '../preview_data.dart';
import 'preview_media.dart';

/// Feed-accurate LinkedIn post preview.
class LinkedInPreview extends StatelessWidget {
  const LinkedInPreview({super.key, required this.data});

  final PreviewData data;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final bool isLong = data.text.length > 140;
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: <Widget>[
                AuthorAvatar(
                    name: data.authorName,
                    imageUrl: data.avatarUrl,
                    size: 44,
                    color: AppColors.linkedin),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(data.authorName,
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                      Text('Creative Director • 2nd',
                          style: Theme.of(context).textTheme.bodySmall),
                      Row(
                        children: <Widget>[
                          Text(data.timeLabel,
                              style: Theme.of(context).textTheme.bodySmall),
                          const SizedBox(width: 4),
                          Icon(Icons.public,
                              size: 12, color: colors.onSurfaceVariant),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.more_horiz),
              ],
            ),
          ),
          if (data.text.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  PreviewText(
                      text: data.text,
                      accent: AppColors.linkedin,
                      maxLines: isLong ? 3 : null),
                  if (isLong)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text('…see more',
                          style: TextStyle(color: colors.onSurfaceVariant)),
                    ),
                ],
              ),
            ),
          if (data.hasMedia)
            PreviewMediaGrid(
                paths: data.mediaPaths,
                aspectRatio: 1.5,
                borderRadius: BorderRadius.zero),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
            child: Row(
              children: <Widget>[
                const _LiReactions(),
                const SizedBox(width: 6),
                Text(compactCount(data.engagement.likes),
                    style: Theme.of(context).textTheme.bodySmall),
                const Spacer(),
                Text(
                    '${compactCount(data.engagement.comments)} comments · ${compactCount(data.engagement.shares)} reposts',
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          Divider(height: 1, color: colors.outlineVariant),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                _LiAction(icon: Icons.thumb_up_outlined, label: 'Like'),
                _LiAction(icon: Icons.mode_comment_outlined, label: 'Comment'),
                _LiAction(icon: Icons.repeat, label: 'Repost'),
                _LiAction(icon: Icons.send_outlined, label: 'Send'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LiReactions extends StatelessWidget {
  const _LiReactions();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50,
      height: 18,
      child: Stack(
        children: <Widget>[
          _dot(AppColors.linkedin, Icons.thumb_up, 0),
          _dot(AppColors.success, Icons.volunteer_activism, 14),
          _dot(AppColors.danger, Icons.favorite, 28),
        ],
      ),
    );
  }

  Widget _dot(Color color, IconData icon, double left) => Positioned(
        left: left,
        child: Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 1.5),
          ),
          child: Icon(icon, size: 9, color: Colors.white),
        ),
      );
}

class _LiAction extends StatelessWidget {
  const _LiAction({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final Color c = Theme.of(context).colorScheme.onSurfaceVariant;
    return Row(
      children: <Widget>[
        Icon(icon, size: 18, color: c),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(color: c, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
