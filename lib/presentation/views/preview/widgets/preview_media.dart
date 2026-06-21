import 'dart:io';

import 'package:flutter/material.dart';

/// Renders a single attached image at [aspectRatio] with a graceful fallback.
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
    return ClipRRect(
      borderRadius: borderRadius,
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: _Img(path: paths.first),
      ),
    );
  }
}

/// Renders up to four images in a 2-column grid with a "+N" overlay, mirroring
/// how LinkedIn and X collapse multi-image posts.
class PreviewMediaGrid extends StatelessWidget {
  const PreviewMediaGrid({
    super.key,
    required this.paths,
    this.aspectRatio = 1.5,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
  });

  final List<String> paths;
  final double aspectRatio;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    if (paths.isEmpty) return const SizedBox.shrink();
    if (paths.length == 1) {
      return ClipRRect(
        borderRadius: borderRadius,
        child: AspectRatio(aspectRatio: aspectRatio, child: _Img(path: paths.first)),
      );
    }
    final List<String> show = paths.take(4).toList();
    final int extra = paths.length - show.length;
    return ClipRRect(
      borderRadius: borderRadius,
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 3,
          crossAxisSpacing: 3,
          physics: const NeverScrollableScrollPhysics(),
          children: <Widget>[
            for (int i = 0; i < show.length; i++)
              Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  _Img(path: show[i]),
                  if (i == show.length - 1 && extra > 0)
                    Container(
                      color: Colors.black54,
                      alignment: Alignment.center,
                      child: Text('+$extra',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w700)),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _Img extends StatelessWidget {
  const _Img({required this.path});
  final String path;

  @override
  Widget build(BuildContext context) {
    return Image.file(
      File(path),
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => ColoredBox(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: Icon(Icons.image_outlined,
            color: Theme.of(context).colorScheme.onSurfaceVariant, size: 36),
      ),
    );
  }
}

/// Renders post text with hashtags/mentions highlighted in [accent].
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
    final TextStyle base = style ?? Theme.of(context).textTheme.bodyMedium!;
    final RegExp token = RegExp(r'([#@]\w+)');
    final List<InlineSpan> spans = <InlineSpan>[];
    int last = 0;
    for (final RegExpMatch m in token.allMatches(text)) {
      if (m.start > last) spans.add(TextSpan(text: text.substring(last, m.start)));
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
