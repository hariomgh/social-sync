import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/extensions.dart';
import '../../../../data/models/media_attachment.dart';
import '../../../providers/app_providers.dart';
import '../../../viewmodels/composer_viewmodel.dart';
import '../../../widgets/section_label.dart';

/// "Media Gallery" — a 2-column grid with an Add tile and image thumbnails.
class MediaPickerBar extends ConsumerWidget {
  const MediaPickerBar({super.key});

  static const int _max = 10;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ComposerState state = ref.watch(composerViewModelProvider);
    final ComposerViewModel vm = ref.read(composerViewModelProvider.notifier);
    final List<MediaAttachment> media = state.post.media;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SectionLabel(
          'Media Gallery',
          trailing: Text('${media.length}/$_max images',
              style: Theme.of(context).textTheme.bodySmall),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: <Widget>[
            if (media.length < _max)
              _AddTile(onTap: () => _showAddSheet(context, ref, vm)),
            for (final MediaAttachment m in media)
              _Thumb(media: m, onRemove: () => vm.removeMedia(m.id)),
            if (media.isEmpty) const _EmptyTile(),
          ],
        ),
      ],
    );
  }

  void _showAddSheet(BuildContext context, WidgetRef ref, ComposerViewModel vm) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext sheet) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () async {
                Navigator.pop(sheet);
                await _pickGallery(context, ref, vm);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take a photo'),
              onTap: () async {
                Navigator.pop(sheet);
                await _capture(context, ref, vm);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickGallery(
      BuildContext context, WidgetRef ref, ComposerViewModel vm) async {
    try {
      final List<MediaAttachment> picked =
          await ref.read(mediaServiceProvider).pickImages();
      if (picked.isNotEmpty) vm.addMedia(picked);
    } catch (_) {
      if (context.mounted) {
        context.showSnack('Could not pick images', isError: true);
      }
    }
  }

  Future<void> _capture(
      BuildContext context, WidgetRef ref, ComposerViewModel vm) async {
    try {
      final MediaAttachment? shot =
          await ref.read(mediaServiceProvider).capturePhoto();
      if (shot != null) vm.addMedia(<MediaAttachment>[shot]);
    } catch (_) {
      if (context.mounted) {
        context.showSnack('Camera unavailable', isError: true);
      }
    }
  }
}

class _AddTile extends StatelessWidget {
  const _AddTile({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.primary.withOpacity(0.06),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: DottedBorderBox(
          color: colors.primary.withOpacity(0.4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.add_a_photo_outlined, color: colors.primary, size: 26),
              const SizedBox(height: 8),
              Text('Add Media',
                  style: TextStyle(
                      color: colors.primary, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyTile extends StatelessWidget {
  const _EmptyTile();

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Icon(Icons.image_outlined, color: colors.outlineVariant, size: 30),
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({required this.media, required this.onRemove});
  final MediaAttachment media;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Image.file(
            File(media.originalPath),
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: const Icon(Icons.broken_image_outlined),
            ),
          ),
          Positioned(
            top: 6,
            right: 6,
            child: GestureDetector(
              onTap: onRemove,
              child: const CircleAvatar(
                radius: 13,
                backgroundColor: Colors.black54,
                child: Icon(Icons.close, size: 15, color: Colors.white),
              ),
            ),
          ),
          if (media.crops.isNotEmpty)
            Positioned(
              left: 6,
              bottom: 6,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('${media.crops.length} crop',
                    style: const TextStyle(color: Colors.white, fontSize: 10)),
              ),
            ),
        ],
      ),
    );
  }
}

/// A simple rounded box with a dashed-style border (painted as a soft outline).
class DottedBorderBox extends StatelessWidget {
  const DottedBorderBox({super.key, required this.child, required this.color});
  final Widget child;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color, width: 1.4),
      ),
      child: child,
    );
  }
}
