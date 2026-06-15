import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../widgets/avatars.dart';
import '../preview_data.dart';
import 'preview_media.dart';

/// Feed-accurate Instagram post preview.
class InstagramPreview extends StatelessWidget {
  const InstagramPreview({super.key, required this.data});

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
          // Header
          Padding(
            padding: const EdgeInsets.all(10),
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
                  child: Text(
                    data.authorHandle,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                const Icon(Icons.more_horiz, size: 20),
              ],
            ),
          ),
          // Media (Instagram requires media)
          if (data.hasMedia)
            PreviewMedia(paths: data.mediaPaths, aspectRatio: 1)
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
                        color: colors.onSurfaceVariant, size: 32),
                    const SizedBox(height: 8),
                    Text('Add a photo — Instagram needs one',
                        style: TextStyle(color: colors.onSurfaceVariant)),
                  ],
                ),
              ),
            ),
          // Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: const <Widget>[
                Icon(Icons.favorite_border, size: 24),
                SizedBox(width: 16),
                Icon(Icons.mode_comment_outlined, size: 22),
                SizedBox(width: 16),
                Icon(Icons.send_outlined, size: 22),
                Spacer(),
                Icon(Icons.bookmark_border, size: 24),
              ],
            ),
          ),
          // Caption
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Liked by others',
                    style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 4),
                RichText(
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodyMedium,
                    children: <InlineSpan>[
                      TextSpan(
                        text: '${data.authorHandle} ',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      ..._captionSpans(context),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<InlineSpan> _captionSpans(BuildContext context) {
    final RegExp token = RegExp(r'([#@]\w+)');
    final List<InlineSpan> spans = <InlineSpan>[];
    final String text = data.text;
    int last = 0;
    for (final RegExpMatch m in token.allMatches(text)) {
      if (m.start > last) spans.add(TextSpan(text: text.substring(last, m.start)));
      spans.add(TextSpan(
        text: m.group(0),
        style: const TextStyle(color: Color(0xFF3897F0)),
      ));
      last = m.end;
    }
    if (last < text.length) spans.add(TextSpan(text: text.substring(last)));
    return spans;
  }
}
