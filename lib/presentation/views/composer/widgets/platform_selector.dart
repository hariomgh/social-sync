import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/models/social_platform.dart';
import '../../../viewmodels/composer_viewmodel.dart';
import '../../../widgets/section_label.dart';

/// "TARGET PLATFORMS" — pill toggles selecting which networks the post targets.
class PlatformSelector extends ConsumerWidget {
  const PlatformSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ComposerState state = ref.watch(composerViewModelProvider);
    final ComposerViewModel vm = ref.read(composerViewModelProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SectionLabel('Target platforms'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: <Widget>[
            for (final SocialPlatform p in SocialPlatform.values)
              _PlatformPill(
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

class _PlatformPill extends StatelessWidget {
  const _PlatformPill({
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? platform.brandColor.withOpacity(0.12)
              : colors.surface,
          borderRadius: BorderRadius.circular(24),
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
              size: 17,
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
            if (selected) ...<Widget>[
              const SizedBox(width: 6),
              Icon(Icons.check_circle, size: 15, color: platform.brandColor),
            ],
          ],
        ),
      ),
    );
  }
}
