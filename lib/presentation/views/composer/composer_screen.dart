import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/extensions.dart';
import '../../viewmodels/composer_viewmodel.dart';
import '../preview/preview_panel.dart';
import 'widgets/content_editor.dart';
import 'widgets/insights_section.dart';
import 'widgets/media_picker_bar.dart';
import 'widgets/per_platform_customizer.dart';
import 'widgets/platform_selector.dart';
import 'widgets/publish_actions.dart';
import 'widgets/scheduling_section.dart';

/// Create screen: a single compose form (mockup-styled) plus a live Preview tab.
class ComposerScreen extends ConsumerWidget {
  const ComposerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Create'),
          actions: <Widget>[
            IconButton(
              tooltip: 'New post',
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () => _confirmReset(context, ref),
            ),
            const SizedBox(width: 4),
          ],
          bottom: const TabBar(
            tabs: <Widget>[
              Tab(text: 'Compose', icon: Icon(Icons.edit_outlined)),
              Tab(text: 'Preview', icon: Icon(Icons.visibility_outlined)),
            ],
          ),
        ),
        body: const TabBarView(
          children: <Widget>[
            _CreateTab(),
            PreviewPanel(),
          ],
        ),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
    if (ok ?? false) ref.read(composerViewModelProvider.notifier).reset();
  }
}

class _CreateTab extends StatelessWidget {
  const _CreateTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      children: <Widget>[
        const MediaPickerBar(),
        const SizedBox(height: 22),
        const ContentEditor(),
        const SizedBox(height: 22),
        const PlatformSelector(),
        const SizedBox(height: 16),
        _PerPlatformExpander(),
        const SizedBox(height: 22),
        const InsightsSection(),
        const SizedBox(height: 22),
        const SchedulingSection(),
        const SizedBox(height: 28),
        const PublishActions(),
      ],
    );
  }
}

class _PerPlatformExpander extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.colors.outlineVariant),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          shape: const Border(),
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Icon(Icons.tune, color: context.colors.primary),
          title: const Text('Customize per platform',
              style: TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Text('Tailor copy & crops for each network',
              style: context.textTheme.bodySmall),
          children: const <Widget>[PerPlatformCustomizer()],
        ),
      ),
    );
  }
}
