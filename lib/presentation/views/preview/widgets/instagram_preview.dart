import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/format.dart';
import '../../../widgets/avatars.dart';
import '../preview_data.dart';
import 'preview_media.dart';

/// Feed-accurate Instagram post preview.
class InstagramPreview extends StatelessWidget {
  const InstagramPreview({super.key, required this.data});

  final PreviewData data;
  static const Color _link = Color(0xFF3897F0);

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
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
          // App chrome
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Row(
              children: <Widget>[
                Text('Instagram',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.italic,
                      color: colors.onSurface,
                    )),
                const Spacer(),
                const Icon(Icons.favorite_border, size: 22),
                const SizedBox(width: 16),
                Icon(Icons.send_outlined, size: 21, color: colors.onSurface),
              ],
            ),
          ),
          // Author row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: AppColors.instagramGradient),
                  ),
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: colors.surface,
                    child: AuthorAvatar(
                      name: data.authorName,
                      imageUrl: data.avatarUrl,
                      size: 28,
                      color: AppColors.instagram,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(data.authorHandle.replaceAll('@', ''),
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 13)),
                      Text('Original audio',
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                const Icon(Icons.more_vert, size: 18),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Media
          if (data.hasMedia)
            Stack(
              children: <Widget>[
                PreviewMedia(paths: data.mediaPaths, aspectRatio: 1),
                if (data.mediaPaths.length > 1)
                  const Positioned(
                    top: 10,
                    right: 10,
                    child: Icon(Icons.collections, color: Colors.white, size: 18),
                  ),
              ],
            )
          else
            AspectRatio(
              aspectRatio: 1,
              child: Container(
                color: colors.surfaceContainerHighest,
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(Icons.add_a_photo_outlined,
                        color: colors.onSurfaceVariant, size: 30),
                    const SizedBox(height: 8),
                    Text('Add a photo — Instagram needs one',
                        style: TextStyle(color: colors.onSurfaceVariant)),
                  ],
                ),
              ),
            ),
          // Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: <Widget>[
                const Icon(Icons.favorite_border, size: 24),
                const SizedBox(width: 16),
                const Icon(Icons.mode_comment_outlined, size: 22),
                const SizedBox(width: 16),
                Icon(Icons.send_outlined, size: 22, color: colors.onSurface),
                const Spacer(),
                const Icon(Icons.bookmark_border, size: 24),
              ],
            ),
          ),
          // Likes + caption
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('${compactCount(data.engagement.likes)} likes',
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                RichText(
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodyMedium,
                    children: <InlineSpan>[
                      TextSpan(
                        text: '${data.authorHandle.replaceAll('@', '')} ',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      ..._caption(),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text('2 HOURS AGO',
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall
                        ?.copyWith(letterSpacing: 0.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<InlineSpan> _caption() {
    final RegExp token = RegExp(r'([#@]\w+)');
    final List<InlineSpan> spans = <InlineSpan>[];
    final String text = data.text;
    int last = 0;
    for (final RegExpMatch m in token.allMatches(text)) {
      if (m.start > last) spans.add(TextSpan(text: text.substring(last, m.start)));
      spans.add(TextSpan(text: m.group(0), style: const TextStyle(color: _link)));
      last = m.end;
    }
    if (last < text.length) spans.add(TextSpan(text: text.substring(last)));
    return spans;
  }
}
