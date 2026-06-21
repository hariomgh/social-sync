import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../viewmodels/composer_viewmodel.dart';
import 'hashtag_tools_sheet.dart';

/// The shared "story" card — write once here and every platform inherits it
/// unless individually overridden. Includes quick emoji / mention / hashtag
/// actions, styled to match the design mockups.
class ContentEditor extends ConsumerStatefulWidget {
  const ContentEditor({super.key});

  @override
  ConsumerState<ContentEditor> createState() => _ContentEditorState();
}

class _ContentEditorState extends ConsumerState<ContentEditor> {
  late final TextEditingController _controller;

  static const List<String> _emojis = <String>[
    '😀', '🔥', '🚀', '✨', '💡', '🎉', '❤️', '👍', '📣', '🙌',
  ];

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

  void _insert(String snippet) {
    final String text = _controller.text;
    ref.read(composerViewModelProvider.notifier).updateBaseText('$text$snippet');
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final ComposerViewModel vm = ref.read(composerViewModelProvider.notifier);

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

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.outlineVariant),
      ),
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextField(
            controller: _controller,
            onChanged: vm.updateBaseText,
            maxLines: 6,
            minLines: 4,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              hintText: "What's the story today?",
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              filled: false,
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 8),
            ),
          ),
          Row(
            children: <Widget>[
              PopupMenuButton<String>(
                tooltip: 'Emoji',
                icon: Icon(Icons.emoji_emotions_outlined,
                    color: colors.onSurfaceVariant, size: 22),
                onSelected: _insert,
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    enabled: false,
                    child: Wrap(
                      spacing: 4,
                      children: <Widget>[
                        for (final String e in _emojis)
                          IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _insert(e);
                            },
                            icon: Text(e, style: const TextStyle(fontSize: 20)),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              IconButton(
                tooltip: 'Mention',
                onPressed: () => _insert('@'),
                icon: Icon(Icons.alternate_email,
                    color: colors.onSurfaceVariant, size: 22),
              ),
              IconButton(
                tooltip: 'Hashtags',
                onPressed: () => showHashtagTools(context),
                icon: Icon(Icons.tag,
                    color: colors.onSurfaceVariant, size: 22),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
