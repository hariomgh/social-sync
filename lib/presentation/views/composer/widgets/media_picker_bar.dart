import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/extensions.dart';
import '../../../../data/models/media_attachment.dart';
import '../../../providers/app_providers.dart';
import '../../../viewmodels/composer_viewmodel.dart';

/// Add and manage photos shared across all platforms.
class MediaPickerBar extends ConsumerWidget {
  const MediaPickerBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ComposerState state = ref.watch(composerViewModelProvider);
    final ComposerViewModel vm = ref.read(composerViewModelProvider.notifier);
    final List<MediaAttachment> media = state.post.media;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text('Photos', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(width: 6),
            Text('${media.length}/10',
                style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 92,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: <Widget>[
              _AddTile(
                icon: Icons.photo_library_outlined,
                label: 'Gallery',
                onTap: () => _pickFromGallery(context, ref, vm),
              ),
              const SizedBox(width: 8),
              _AddTile(
                icon: Icons.photo_camera_outlined,
                label: 'Camera',
                onTap: () => _capture(context, ref, vm),
              ),
              const SizedBox(width: 8),
              for (final MediaAttachment m in media) ...<Widget>[
                _Thumb(media: m, onRemove: () => vm.removeMedia(m.id)),
                const SizedBox(width: 8),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _pickFromGallery(
      BuildContext context, WidgetRef ref, ComposerViewModel vm) async {
    try {
      final List<MediaAttachment> picked =
          await ref.read(mediaServiceProvider).pickImages();
      if (picked.isNotEmpty) vm.addMedia(picked);
    } catch (e) {
      if (context.mounted) context.showSnack('Could not pick images', isError: true);
    }
  }

  Future<void> _capture(
      BuildContext context, WidgetRef ref, ComposerViewModel vm) async {
    try {
      final MediaAttachment? shot =
          await ref.read(mediaServiceProvider).capturePhoto();
      if (shot != null) vm.addMedia(<MediaAttachment>[shot]);
    } catch (e) {
      if (context.mounted) context.showSnack('Camera unavailable', isError: true);
    }
  }
}

class _AddTile extends StatelessWidget {
  const _AddTile({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.outlineVariant),
          color: colors.surface,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, color: colors.primary),
            const SizedBox(height: 4),
            Text(label, style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({required this.media, required this.onRemove});
  final MediaAttachment media;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.file(
            File(media.originalPath),
            width: 92,
            height: 92,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: 92,
              height: 92,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: const Icon(Icons.broken_image_outlined),
            ),
          ),
        ),
        Positioned(
          top: 2,
          right: 2,
          child: GestureDetector(
            onTap: onRemove,
            child: const CircleAvatar(
              radius: 11,
              backgroundColor: Colors.black54,
              child: Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
        if (media.crops.isNotEmpty)
          Positioned(
            bottom: 2,
            left: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('${media.crops.length} crop',
                  style: const TextStyle(color: Colors.white, fontSize: 10)),
            ),
          ),
      ],
    );
  }
}
