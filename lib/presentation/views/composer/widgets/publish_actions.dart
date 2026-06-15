import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../../data/models/publish_result.dart';
import '../../../viewmodels/composer_viewmodel.dart';
import '../../../viewmodels/library_viewmodel.dart';

/// Sticky bottom bar with the three commit actions: save draft, schedule and
/// publish. Surfaces a readiness summary and disables publish until every
/// selected platform validates.
class PublishActions extends ConsumerWidget {
  const PublishActions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ComposerState state = ref.watch(composerViewModelProvider);
    final ComposerViewModel vm = ref.read(composerViewModelProvider.notifier);
    final int selectedCount = state.post.selectedPlatforms.length;
    final int errorCount = state.issues.values
        .expand((List<ValidationIssue> l) => l)
        .where((ValidationIssue i) => i.isError)
        .length;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        decoration: BoxDecoration(
          color: context.colors.surface,
          border: Border(top: BorderSide(color: context.colors.outlineVariant)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(
                  errorCount == 0 ? Icons.check_circle : Icons.error_outline,
                  size: 16,
                  color: errorCount == 0
                      ? context.colors.primary
                      : context.colors.error,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    selectedCount == 0
                        ? 'No platforms selected'
                        : errorCount == 0
                            ? 'Ready for $selectedCount platform${selectedCount == 1 ? '' : 's'}'
                            : '$errorCount issue${errorCount == 1 ? '' : 's'} to fix',
                    style: context.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: state.isPublishing
                        ? null
                        : () => _saveDraft(context, ref, vm),
                    icon: const Icon(Icons.bookmark_border, size: 18),
                    label: const Text('Draft'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: state.isPublishing || !state.canPublish
                        ? null
                        : () => _schedule(context, ref, vm),
                    icon: const Icon(Icons.schedule, size: 18),
                    label: const Text('Schedule'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    onPressed:
                        state.canPublish ? () => _publish(context, ref, vm) : null,
                    icon: state.isPublishing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.send, size: 18),
                    label: Text(state.isPublishing ? 'Publishing…' : 'Publish now'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveDraft(
      BuildContext context, WidgetRef ref, ComposerViewModel vm) async {
    await vm.saveDraft();
    ref.invalidate(libraryViewModelProvider);
    if (context.mounted) context.showSnack('Saved to drafts');
  }

  Future<void> _schedule(
      BuildContext context, WidgetRef ref, ComposerViewModel vm) async {
    final DateTime? at = await _pickDateTime(context);
    if (at == null) return;
    await vm.schedule(at);
    ref.invalidate(libraryViewModelProvider);
    if (context.mounted) {
      context.showSnack(
          'Scheduled for ${DateFormat('MMM d, h:mm a').format(at)}');
    }
  }

  Future<void> _publish(
      BuildContext context, WidgetRef ref, ComposerViewModel vm) async {
    final List<PublishOutcome> outcomes = await vm.publish();
    ref.invalidate(libraryViewModelProvider);
    if (context.mounted) _showResults(context, outcomes);
  }

  Future<DateTime?> _pickDateTime(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime initial = now.add(const Duration(hours: 1));
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null || !context.mounted) return null;
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  void _showResults(BuildContext context, List<PublishOutcome> outcomes) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Publish results'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            for (final PublishOutcome o in outcomes)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  o.success ? Icons.check_circle : Icons.cancel,
                  color: o.success
                      ? context.colors.primary
                      : context.colors.error,
                ),
                title: Text(o.platform.label),
                subtitle: Text(
                  o.success ? (o.postUrl ?? 'Posted') : (o.error ?? 'Failed'),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}
