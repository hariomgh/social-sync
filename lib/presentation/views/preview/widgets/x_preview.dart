import 'package:flutter/material.dart';

import '../../../../core/utils/format.dart';
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AuthorAvatar(
              name: data.authorName,
              imageUrl: data.avatarUrl,
              color: Colors.black),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Flexible(
                      child: Text(data.authorName,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.verified, size: 15, color: _accent),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text('${data.authorHandle} · ${data.timeLabel}',
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall),
                    ),
                    const Spacer(),
                    const Icon(Icons.more_horiz, size: 18),
                  ],
                ),
                const SizedBox(height: 2),
                PreviewText(text: data.text, accent: _accent),
                if (data.hasMedia) ...<Widget>[
                  const SizedBox(height: 10),
                  PreviewMediaGrid(
                    paths: data.mediaPaths,
                    aspectRatio: data.mediaPaths.length == 1 ? 16 / 9 : 2,
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    _metric(Icons.mode_comment_outlined,
                        compactCount(data.engagement.comments)),
                    _metric(Icons.repeat, compactCount(data.engagement.shares)),
                    _metric(Icons.favorite_border,
                        compactCount(data.engagement.likes)),
                    _metric(Icons.bar_chart, compactCount(data.engagement.views)),
                    const Icon(Icons.bookmark_border, size: 17, color: Colors.grey),
                    const Icon(Icons.share_outlined, size: 17, color: Colors.grey),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metric(IconData icon, String value) {
    return Row(
      children: <Widget>[
        Icon(icon, size: 17, color: Colors.grey),
        const SizedBox(width: 4),
        Text(value, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}
