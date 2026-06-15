import 'package:flutter/material.dart';

import '../../../widgets/avatars.dart';
import '../preview_data.dart';
import 'preview_media.dart';

/// Timeline-accurate X (Twitter) post preview.
class XPreview extends StatelessWidget {
  const XPreview({super.key, required this.data});

  final PreviewData data;

  static const Color _accent = Color(0xFF1D9BF0);

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AuthorAvatar(
            name: data.authorName,
            imageUrl: data.avatarUrl,
            color: Colors.black,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        data.authorName,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.verified, size: 15, color: _accent),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        '${data.authorHandle} · ${data.timeLabel}',
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.more_horiz, size: 18),
                  ],
                ),
                const SizedBox(height: 2),
                PreviewText(text: data.text, accent: _accent),
                if (data.hasMedia) ...<Widget>[
                  const SizedBox(height: 10),
                  PreviewMedia(
                    paths: data.mediaPaths,
                    aspectRatio: 16 / 9,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ],
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    _xIcon(Icons.mode_comment_outlined),
                    _xIcon(Icons.repeat),
                    _xIcon(Icons.favorite_border),
                    _xIcon(Icons.bar_chart),
                    _xIcon(Icons.bookmark_border),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _xIcon(IconData icon) => Icon(icon, size: 18, color: Colors.grey);
}
