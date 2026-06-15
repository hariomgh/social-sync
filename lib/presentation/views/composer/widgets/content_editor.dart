import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/models/social_platform.dart';
import '../../../viewmodels/composer_viewmodel.dart';

/// The shared content field — write once here and every platform inherits it
/// unless individually overridden. Shows a count against the tightest selected
/// platform limit so you know when copy will be cut somewhere.
class ContentEditor extends ConsumerStatefulWidget {
  const ContentEditor({super.key});

  @override
  ConsumerState<ContentEditor> createState() => _ContentEditorState();
}

class _ContentEditorState extends ConsumerState<ContentEditor> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: ref.read(composerViewModelProvider).post.baseText,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ComposerViewModel vm =
        ref.read(composerViewModelProvider.notifier);

    // Keep the field in sync when text changes externally (draft load, reset,
    // hashtag insertion) without disturbing the cursor during normal typing.
    ref.listen<String>(
      composerViewModelProvider.select((ComposerState s) => s.post.baseText),
      (String? _, String next) {
        if (next != _controller.text) {
          _controller.value = TextEditingValue(
            text: next,
            selection: TextSelection.collapsed(offset: next.length),
          );
        }
      },
    );

    final ComposerState state = ref.watch(composerViewModelProvider);
    final List<SocialPlatform> selected = state.post.selectedPlatforms;
    final int length = _controller.text.characters.length;
    final int? tightest = selected.isEmpty
        ? null
        : selected
            .map((SocialPlatform p) => p.maxCharacters)
            .reduce((int a, int b) => a < b ? a : b);
    final bool over = tightest != null && length > tightest;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        TextField(
          controller: _controller,
          onChanged: vm.updateBaseText,
          maxLines: 6,
          minLines: 4,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            hintText: "What's on your mind? Write it once…",
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: <Widget>[
            Icon(Icons.text_fields,
                size: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(width: 4),
            Text('$length characters',
                style: Theme.of(context).textTheme.bodySmall),
            const Spacer(),
            if (tightest != null)
              Text(
                over
                    ? 'Over $tightest (tightest limit)'
                    : 'Fits all selected',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: over
                          ? Theme.of(context).colorScheme.error
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: over ? FontWeight.w600 : null,
                    ),
              ),
          ],
        ),
      ],
    );
  }
}
