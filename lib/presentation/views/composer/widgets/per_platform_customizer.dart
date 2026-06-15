import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../../data/models/media_attachment.dart';
import '../../../../data/models/platform_content.dart';
import '../../../../data/models/social_platform.dart';
import '../../../providers/app_providers.dart';
import '../../../viewmodels/composer_viewmodel.dart';
import '../../../widgets/avatars.dart';

/// One expandable card per selected platform: tailor copy, see the live
/// character budget, fix validation issues and crop images to that platform's
/// aspect ratio — i.e. "manage how the content looks on each platform".
class PerPlatformCustomizer extends ConsumerWidget {
  const PerPlatformCustomizer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ComposerState state = ref.watch(composerViewModelProvider);
    final List<SocialPlatform> selected = state.post.selectedPlatforms;

    if (selected.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.colors.outlineVariant),
        ),
        child: Row(
          children: <Widget>[
            Icon(Icons.info_outline, color: context.colors.onSurfaceVariant),
            const SizedBox(width: 10),
            const Expanded(
              child: Text('Select at least one platform above to customize it.'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: <Widget>[
        for (final SocialPlatform p in selected)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _PlatformCard(platform: p),
          ),
      ],
    );
  }
}

class _PlatformCard extends ConsumerWidget {
  const _PlatformCard({required this.platform});
  final SocialPlatform platform;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ComposerState state = ref.watch(composerViewModelProvider);
    final ComposerViewModel vm = ref.read(composerViewModelProvider.notifier);
    final PlatformContent content = state.post.contentFor(platform);
    final String effective = state.post.textFor(platform);
    final int length = effective.characters.length;
    final bool over = length > platform.maxCharacters;
    final List<ValidationIssue> issues =
        state.issues[platform] ?? const <ValidationIssue>[];

    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.outlineVariant),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          leading: PlatformBadge(platform: platform),
          title: Text(platform.label,
              style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Text(
            '$length / ${platform.maxCharacters} characters',
            style: context.textTheme.bodySmall?.copyWith(
              color: over ? context.colors.error : context.colors.onSurfaceVariant,
              fontWeight: over ? FontWeight.w600 : null,
            ),
          ),
          trailing: content.hasCustomText
              ? Icon(Icons.edit, size: 18, color: platform.brandColor)
              : const Icon(Icons.expand_more),
          children: <Widget>[
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              value: content.hasCustomText,
              onChanged: (bool v) => vm.enableCustomText(platform, v),
              title: const Text('Tailor copy for this platform'),
              subtitle: Text(
                content.hasCustomText
                    ? 'Editing a separate version'
                    : 'Using the shared content',
                style: context.textTheme.bodySmall,
              ),
            ),
            if (content.hasCustomText)
              _OverrideField(platform: platform, initial: content.customText ?? ''),
            if (issues.isNotEmpty) ...<Widget>[
              const SizedBox(height: 8),
              ...issues.map((ValidationIssue i) => _IssueRow(issue: i)),
            ],
            if (state.post.hasMedia) ...<Widget>[
              const SizedBox(height: 8),
              _CropRow(platform: platform),
            ],
          ],
        ),
      ),
    );
  }
}

class _OverrideField extends ConsumerStatefulWidget {
  const _OverrideField({required this.platform, required this.initial});
  final SocialPlatform platform;
  final String initial;

  @override
  ConsumerState<_OverrideField> createState() => _OverrideFieldState();
}

class _OverrideFieldState extends ConsumerState<_OverrideField> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: TextField(
        controller: _controller,
        onChanged: (String v) => ref
            .read(composerViewModelProvider.notifier)
            .setCustomText(widget.platform, v),
        maxLines: 5,
        minLines: 3,
        decoration: InputDecoration(
          hintText: 'Custom text for ${widget.platform.label}…',
        ),
      ),
    );
  }
}

class _IssueRow extends StatelessWidget {
  const _IssueRow({required this.issue});
  final ValidationIssue issue;

  @override
  Widget build(BuildContext context) {
    final Color color =
        issue.isError ? context.colors.error : const Color(0xFFB8860B);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(issue.isError ? Icons.error_outline : Icons.warning_amber_rounded,
              size: 16, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Text(issue.message,
                style: context.textTheme.bodySmall?.copyWith(color: color)),
          ),
        ],
      ),
    );
  }
}

class _CropRow extends ConsumerWidget {
  const _CropRow({required this.platform});
  final SocialPlatform platform;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Align(
      alignment: Alignment.centerLeft,
      child: PopupMenuButton<AspectRatioOption>(
        onSelected: (AspectRatioOption option) =>
            _cropAll(context, ref, option),
        itemBuilder: (BuildContext context) => <PopupMenuEntry<AspectRatioOption>>[
          for (final AspectRatioOption o in platform.aspectRatios)
            PopupMenuItem<AspectRatioOption>(value: o, child: Text(o.label)),
        ],
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: platform.brandColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.crop, size: 16, color: platform.brandColor),
              const SizedBox(width: 6),
              Text('Crop photos for ${platform.label}',
                  style: TextStyle(
                      color: platform.brandColor, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _cropAll(
      BuildContext context, WidgetRef ref, AspectRatioOption option) async {
    final ComposerViewModel vm = ref.read(composerViewModelProvider.notifier);
    final List<MediaAttachment> media =
        ref.read(composerViewModelProvider).post.media;
    try {
      for (final MediaAttachment m in media) {
        final MediaAttachment cropped =
            await ref.read(mediaServiceProvider).cropFor(m, platform, option);
        vm.replaceMedia(cropped);
      }
    } catch (e) {
      if (context.mounted) {
        context.showSnack('Cropping unavailable here', isError: true);
      }
    }
  }
}
