import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/models/social_platform.dart';
import '../../../viewmodels/composer_viewmodel.dart';

/// Row of toggle chips that select which networks the post targets.
class PlatformSelector extends ConsumerWidget {
  const PlatformSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ComposerState state = ref.watch(composerViewModelProvider);
    final ComposerViewModel vm = ref.read(composerViewModelProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Publish to',
            style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            for (final SocialPlatform p in SocialPlatform.values)
              _PlatformChip(
                platform: p,
                selected: state.post.contentFor(p).enabled,
                onTap: () => vm.togglePlatform(p),
              ),
          ],
        ),
      ],
    );
  }
}

class _PlatformChip extends StatelessWidget {
  const _PlatformChip({
    required this.platform,
    required this.selected,
    required this.onTap,
  });

  final SocialPlatform platform;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? platform.brandColor.withOpacity(0.12)
              : colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? platform.brandColor : colors.outlineVariant,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              platform.icon,
              size: 18,
              color: selected ? platform.brandColor : colors.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              platform.label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: selected ? platform.brandColor : colors.onSurface,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              selected ? Icons.check_circle : Icons.add_circle_outline,
              size: 16,
              color: selected ? platform.brandColor : colors.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
