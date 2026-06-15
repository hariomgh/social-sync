import 'dart:io';

import 'package:flutter/material.dart';

/// Renders attached media inside a preview at the given [aspectRatio].
///
/// Shows the first image full-bleed with a "+N" overlay when more images are
/// attached, mirroring how the networks collapse carousels in the feed. Falls
/// back to a neutral placeholder when no media is present or a file is missing.
class PreviewMedia extends StatelessWidget {
  const PreviewMedia({
    super.key,
    required this.paths,
    required this.aspectRatio,
    this.borderRadius = BorderRadius.zero,
  });

  final List<String> paths;
  final double aspectRatio;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    if (paths.isEmpty) return const SizedBox.shrink();
    final ColorScheme colors = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: borderRadius,
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Image.file(
              File(paths.first),
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => ColoredBox(
                color: colors.surfaceContainerHighest,
                child: Icon(Icons.image_outlined,
                    color: colors.onSurfaceVariant, size: 40),
              ),
            ),
            if (paths.length > 1)
              Positioned(
                right: 8,
                bottom: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '+${paths.length - 1}',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Renders post text with hashtags/mentions highlighted in the platform's
/// accent color, optionally truncated with a "more" affordance.
class PreviewText extends StatelessWidget {
  const PreviewText({
    super.key,
    required this.text,
    required this.accent,
    this.maxLines,
    this.style,
  });

  final String text;
  final Color accent;
  final int? maxLines;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    if (text.trim().isEmpty) return const SizedBox.shrink();
    final TextStyle base =
        style ?? Theme.of(context).textTheme.bodyMedium!;
    final RegExp token = RegExp(r'([#@]\w+)');
    final List<InlineSpan> spans = <InlineSpan>[];
    int last = 0;
    for (final RegExpMatch m in token.allMatches(text)) {
      if (m.start > last) {
        spans.add(TextSpan(text: text.substring(last, m.start)));
      }
      spans.add(TextSpan(
        text: m.group(0),
        style: TextStyle(color: accent, fontWeight: FontWeight.w600),
      ));
      last = m.end;
    }
    if (last < text.length) spans.add(TextSpan(text: text.substring(last)));

    return RichText(
      maxLines: maxLines,
      overflow: maxLines == null ? TextOverflow.clip : TextOverflow.ellipsis,
      text: TextSpan(style: base, children: spans),
    );
  }
}
