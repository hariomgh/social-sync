import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../data/models/social_account.dart';
import '../../../data/models/social_platform.dart';
import '../../viewmodels/accounts_viewmodel.dart';
import '../../viewmodels/composer_viewmodel.dart';
import 'preview_data.dart';
import 'widgets/facebook_preview.dart';
import 'widgets/instagram_preview.dart';
import 'widgets/linkedin_preview.dart';
import 'widgets/x_preview.dart';

/// Live preview surface: a platform switcher plus the mock for the active
/// platform. Reads the composer state so every keystroke and image update is
/// reflected instantly across all four networks.
class PreviewPanel extends ConsumerWidget {
  const PreviewPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ComposerState state = ref.watch(composerViewModelProvider);
    final ComposerViewModel vm = ref.read(composerViewModelProvider.notifier);
    final List<SocialAccount> accounts =
        ref.watch(accountsViewModelProvider).valueOrNull ??
            const <SocialAccount>[];

    final SocialPlatform active = state.previewPlatform;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: <Widget>[
              for (final SocialPlatform p in SocialPlatform.values)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _PreviewTab(
                    platform: p,
                    selected: p == active,
                    enabled: state.post.contentFor(p).enabled,
                    onTap: () => vm.setPreviewPlatform(p),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _DeviceFrame(
            child: _previewFor(active, _dataFor(active, state, accounts)),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  PreviewData _dataFor(
    SocialPlatform platform,
    ComposerState state,
    List<SocialAccount> accounts,
  ) {
    final SocialAccount? account =
        accounts.firstWhereOrNull((SocialAccount a) => a.platform == platform);
    final List<String> mediaPaths = state.post.media
        .map((m) => m.pathFor(platform.id))
        .toList(growable: false);
    return PreviewData(
      authorName: account?.displayName ?? AppConstants.demoAuthorName,
      authorHandle: account != null
          ? account.handle
          : '${platform.handlePrefix}${AppConstants.demoAuthorHandle}',
      text: state.post.textFor(platform),
      mediaPaths: mediaPaths,
      avatarUrl: account?.avatarUrl,
      isConnected: account != null,
    );
  }

  Widget _previewFor(SocialPlatform platform, PreviewData data) {
    return switch (platform) {
      SocialPlatform.instagram => InstagramPreview(data: data),
      SocialPlatform.facebook => FacebookPreview(data: data),
      SocialPlatform.linkedin => LinkedInPreview(data: data),
      SocialPlatform.x => XPreview(data: data),
    };
  }
}

class _PreviewTab extends StatelessWidget {
  const _PreviewTab({
    required this.platform,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final SocialPlatform platform;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? platform.brandColor : colors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? platform.brandColor : colors.outlineVariant,
          ),
        ),
        child: Row(
          children: <Widget>[
            Icon(
              platform.icon,
              size: 16,
              color: selected ? Colors.white : colors.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              platform.label,
              style: TextStyle(
                color: selected ? Colors.white : colors.onSurface,
                fontWeight: FontWeight.w600,
                decoration:
                    enabled ? null : TextDecoration.lineThrough,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A subtle phone-like frame to anchor the preview visually.
class _DeviceFrame extends StatelessWidget {
  const _DeviceFrame({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withOpacity(0.4),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: child,
    );
  }
}
