import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/extensions.dart';
import '../../viewmodels/composer_viewmodel.dart';
import '../preview/preview_panel.dart';
import 'widgets/content_editor.dart';
import 'widgets/hashtag_tools_sheet.dart';
import 'widgets/media_picker_bar.dart';
import 'widgets/per_platform_customizer.dart';
import 'widgets/platform_selector.dart';
import 'widgets/publish_actions.dart';

/// The compose screen: write once (Edit tab), then see it everywhere (Preview
/// tab). The publish bar is always visible so the primary action is one tap away.
class ComposerScreen extends ConsumerWidget {
  const ComposerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(AppConstants.appName),
          bottom: const TabBar(
            tabs: <Widget>[
              Tab(text: 'Edit', icon: Icon(Icons.edit_outlined)),
              Tab(text: 'Preview', icon: Icon(Icons.visibility_outlined)),
            ],
          ),
          actions: <Widget>[
            IconButton(
              tooltip: 'New post',
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () => _confirmReset(context, ref),
            ),
          ],
        ),
        body: const TabBarView(
          children: <Widget>[
            _EditTab(),
            SingleChildScrollView(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: PreviewPanel(),
            ),
          ],
        ),
        bottomNavigationBar: const PublishActions(),
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    final ComposerState state = ref.read(composerViewModelProvider);
    if (state.post.isEmpty) {
      ref.read(composerViewModelProvider.notifier).reset();
      return;
    }
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Start a new post?'),
        content: const Text('Unsaved changes will be cleared.'),
        actions: <Widget>[
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('New post')),
        ],
      ),
    );
    if (ok ?? false) {
      ref.read(composerViewModelProvider.notifier).reset();
    }
  }
}

class _EditTab extends StatelessWidget {
  const _EditTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: <Widget>[
        const PlatformSelector(),
        const SizedBox(height: 20),
        Text('Content', style: context.textTheme.labelLarge),
        const SizedBox(height: 8),
        const ContentEditor(),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => showHashtagTools(context),
          icon: const Icon(Icons.tag, size: 18),
          label: const Text('Add hashtags & mentions'),
        ),
        const SizedBox(height: 20),
        const MediaPickerBar(),
        const SizedBox(height: 24),
        Text('Per-platform', style: context.textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(
          'Fine-tune copy and crops for each network.',
          style: context.textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        const PerPlatformCustomizer(),
      ],
    );
  }
}
