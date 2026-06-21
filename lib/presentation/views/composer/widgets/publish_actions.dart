import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/extensions.dart';
import '../../../../data/models/post.dart';
import '../../../../data/models/publish_result.dart';
import '../../../viewmodels/analytics_viewmodel.dart';
import '../../../viewmodels/composer_viewmodel.dart';
import '../../../viewmodels/library_viewmodel.dart';
import '../../../widgets/gradient_button.dart';

/// The commit actions on the Create screen: a gradient "Publish Now" and a
/// soft "Schedule for Later" (which uses the chosen best-time / custom slot).
class PublishActions extends ConsumerWidget {
  const PublishActions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ComposerState state = ref.watch(composerViewModelProvider);
    final ComposerViewModel vm = ref.read(composerViewModelProvider.notifier);
    final bool enabled = state.canPublish;

    return Column(
      children: <Widget>[
        GradientButton(
          label: 'Publish Now',
          icon: Icons.send_rounded,
          loading: state.isPublishing,
          onPressed: enabled ? () => _publish(context, ref, vm) : null,
        ),
        const SizedBox(height: 12),
        SecondaryButton(
          label: 'Schedule for Later',
          icon: Icons.schedule_rounded,
          onPressed:
              enabled && !state.isPublishing ? () => _schedule(context, ref, vm) : null,
        ),
      ],
    );
  }

  Future<void> _publish(
      BuildContext context, WidgetRef ref, ComposerViewModel vm) async {
    final List<PublishOutcome> outcomes = await vm.publish();
    ref.invalidate(libraryViewModelProvider);
    ref.invalidate(analyticsViewModelProvider);
    if (context.mounted) _showResults(context, outcomes);
  }

  Future<void> _schedule(
      BuildContext context, WidgetRef ref, ComposerViewModel vm) async {
    final Post scheduled = await vm.schedule();
    ref.invalidate(libraryViewModelProvider);
    if (context.mounted && scheduled.scheduledAt != null) {
      context.showSnack(
          'Scheduled for ${DateFormat('MMM d, h:mm a').format(scheduled.scheduledAt!)}');
    }
  }

  void _showResults(BuildContext context, List<PublishOutcome> outcomes) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
