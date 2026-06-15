import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../widgets/avatars.dart';
import '../preview_data.dart';
import 'preview_media.dart';

/// Feed-accurate Facebook post preview.
class FacebookPreview extends StatelessWidget {
  const FacebookPreview({super.key, required this.data});

  final PreviewData data;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
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
                  color: AppColors.facebook,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(data.authorName,
                          style: const TextStyle(fontWeight: FontWeight.w700)),
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
              child: PreviewText(
                text: data.text,
                accent: AppColors.facebook,
                maxLines: 5,
              ),
            ),
          if (data.hasMedia)
            PreviewMedia(paths: data.mediaPaths, aspectRatio: 1.91),
          // Counts
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
            child: Row(
              children: <Widget>[
                const Icon(Icons.thumb_up, size: 14, color: AppColors.facebook),
                const SizedBox(width: 4),
                Text('You and others',
                    style: Theme.of(context).textTheme.bodySmall),
                const Spacer(),
                Text('Comments · Shares',
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
                _FbAction(icon: Icons.thumb_up_outlined, label: 'Like'),
                _FbAction(icon: Icons.mode_comment_outlined, label: 'Comment'),
                _FbAction(icon: Icons.share_outlined, label: 'Share'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FbAction extends StatelessWidget {
  const _FbAction({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final Color c = Theme.of(context).colorScheme.onSurfaceVariant;
    return Row(
      children: <Widget>[
        Icon(icon, size: 18, color: c),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(color: c, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
