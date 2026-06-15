import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
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
        borderRadius: BorderRadius.circular(12),
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
                  color: AppColors.linkedin,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(data.authorName,
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                      Text('Brand · You',
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
                    maxLines: isLong ? 3 : null,
                  ),
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
            PreviewMedia(paths: data.mediaPaths, aspectRatio: 1.91),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: Row(
              children: <Widget>[
                const Icon(Icons.thumb_up, size: 14, color: AppColors.linkedin),
                const SizedBox(width: 4),
                Text('Reactions',
                    style: Theme.of(context).textTheme.bodySmall),
                const Spacer(),
                Text('Comments · Reposts',
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
