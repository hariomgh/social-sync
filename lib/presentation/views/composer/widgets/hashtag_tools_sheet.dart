import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/extensions.dart';
import '../../../../data/models/social_platform.dart';
import '../../../viewmodels/composer_viewmodel.dart';

/// Opens the hashtag & mention helper.
Future<void> showHashtagTools(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (BuildContext _) => const _HashtagToolsSheet(),
  );
}

class _HashtagToolsSheet extends ConsumerStatefulWidget {
  const _HashtagToolsSheet();

  @override
  ConsumerState<_HashtagToolsSheet> createState() => _HashtagToolsSheetState();
}

class _HashtagToolsSheetState extends ConsumerState<_HashtagToolsSheet> {
  final TextEditingController _input = TextEditingController();

  static const List<String> _suggested = <String>[
    '#marketing', '#smallbusiness', '#startup', '#branding', '#design',
    '#socialmedia', '#contentcreator', '#community', '#innovation', '#growth',
    '#motivation', '#tech',
  ];

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _insert(String token) {
    ref.read(composerViewModelProvider.notifier).appendToBaseText(token);
  }

  @override
  Widget build(BuildContext context) {
    final ComposerState state = ref.watch(composerViewModelProvider);
    final List<String> current = state.post.baseText.hashtags;
    final List<SocialPlatform> selected = state.post.selectedPlatforms;
    final int? tightest = selected.isEmpty
        ? null
        : selected
            .map((SocialPlatform p) => p.maxHashtags)
            .reduce((int a, int b) => a < b ? a : b);

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 4,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Hashtags & mentions',
              style: context.textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(
            tightest == null
                ? 'Tap to add to your content.'
                : '${current.length} used · tightest limit is $tightest (${selected.map((p) => p.label).join(", ")})',
            style: context.textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: _input,
                  decoration: const InputDecoration(
                    hintText: 'Add #hashtag or @mention',
                    isDense: true,
                  ),
                  onSubmitted: (_) => _addFromInput(),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(onPressed: _addFromInput, child: const Text('Add')),
            ],
          ),
          const SizedBox(height: 16),
          Text('Suggestions', style: context.textTheme.labelLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              for (final String tag in _suggested)
                ActionChip(
                  label: Text(tag),
                  onPressed: current.contains(tag) ? null : () => _insert(tag),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _addFromInput() {
    String value = _input.text.trim();
    if (value.isEmpty) return;
    if (!value.startsWith('#') && !value.startsWith('@')) value = '#$value';
    value = value.replaceAll(RegExp(r'\s+'), '');
    _insert(value);
    _input.clear();
  }
}
