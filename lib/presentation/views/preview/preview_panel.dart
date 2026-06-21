import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/extensions.dart';
import '../../../data/models/social_account.dart';
import '../../../data/models/social_platform.dart';
import '../../providers/app_providers.dart';
import '../../viewmodels/accounts_viewmodel.dart';
import '../../viewmodels/composer_viewmodel.dart';
import '../../viewmodels/library_viewmodel.dart';
import '../../widgets/badges.dart';
import '../../widgets/device_frame.dart';
import '../../widgets/gradient_button.dart';
import '../composer/widgets/insights_section.dart';
import 'preview_data.dart';
import 'widgets/facebook_preview.dart';
import 'widgets/instagram_preview.dart';
import 'widgets/linkedin_preview.dart';
import 'widgets/x_preview.dart';

/// Mobile-feed-simulation preview: a platform switcher, a device-framed feed
/// card, the resolved publishing time + schedule action, and live insights.
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
    final PreviewData data = _dataFor(ref, active, state, accounts);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      children: <Widget>[
        Row(
          children: <Widget>[
            const PreviewModeLabel(text: 'Mobile feed simulation'),
            const Spacer(),
            const LiveBadge(),
          ],
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
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
        const SizedBox(height: 18),
        DeviceFrame(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 34, 12, 16),
            child: _previewFor(active, data),
          ),
        ),
        const SizedBox(height: 18),
        _PublishingRow(
          when: vm.resolveScheduledAt(),
          onSchedule: () => _schedule(context, ref, vm),
        ),
        const SizedBox(height: 20),
        const InsightsSection(),
        const SizedBox(height: 16),
        SecondaryButton(
          label: 'Expand ${active.label} preview',
          icon: Icons.open_in_full,
          onPressed: () => _openExpanded(context, ref, active, data),
        ),
      ],
    );
  }

  PreviewData _dataFor(
    WidgetRef ref,
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
      engagement:
          ref.read(engagementProjectorProvider).project(state.post, platform),
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

  Future<void> _schedule(
      BuildContext context, WidgetRef ref, ComposerViewModel vm) async {
    final DateTime when = (await vm.schedule()).scheduledAt ?? DateTime.now();
    ref.invalidate(libraryViewModelProvider);
    if (context.mounted) {
      context.showSnack('Scheduled for ${DateFormat('MMM d, h:mm a').format(when)}');
    }
  }

  void _openExpanded(BuildContext context, WidgetRef ref, SocialPlatform platform,
      PreviewData data) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (BuildContext sheet) => Padding(
        padding: EdgeInsets.fromLTRB(
            16, 0, 16, MediaQuery.of(sheet).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Text('${platform.label} feed preview',
                    style: sheet.textTheme.titleLarge),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(sheet),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Flexible(
              child: SingleChildScrollView(child: _previewFor(platform, data)),
            ),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                Expanded(
                  child: SecondaryButton(
                    label: 'Edit content',
                    onPressed: () => Navigator.pop(sheet),
                    height: 50,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GradientButton(
                    label: 'Schedule now',
                    height: 50,
                    onPressed: () {
                      Navigator.pop(sheet);
                      _schedule(context, ref,
                          ref.read(composerViewModelProvider.notifier));
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PublishingRow extends StatelessWidget {
  const _PublishingRow({required this.when, required this.onSchedule});
  final DateTime when;
  final VoidCallback onSchedule;

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final bool isToday =
        when.year == now.year && when.month == now.month && when.day == now.day;
    final String label = isToday
        ? 'Today, ${DateFormat('h:mm a').format(when)}'
        : DateFormat('EEE MMM d, h:mm a').format(when);

    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Text('Publishing Date',
                style: context.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const Spacer(),
            Text(label,
                style: TextStyle(
                    color: context.colors.primary,
                    fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 14),
        GradientButton(
          label: 'Schedule Post',
          icon: Icons.calendar_today_rounded,
          onPressed: onSchedule,
        ),
      ],
    );
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? platform.brandColor : colors.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selected ? platform.brandColor : colors.outlineVariant,
          ),
        ),
        child: Row(
          children: <Widget>[
            Icon(platform.icon,
                size: 16,
                color: selected ? Colors.white : colors.onSurfaceVariant),
            const SizedBox(width: 6),
            Text(
              platform.label,
              style: TextStyle(
                color: selected ? Colors.white : colors.onSurface,
                fontWeight: FontWeight.w600,
                decoration: enabled ? null : TextDecoration.lineThrough,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
