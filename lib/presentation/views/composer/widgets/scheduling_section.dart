import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_picker.dart';
import '../../../../data/models/schedule_mode.dart';
import '../../../providers/app_providers.dart';
import '../../../viewmodels/composer_viewmodel.dart';
import '../../../widgets/section_label.dart';
import '../../../widgets/selectable_option_card.dart';

/// "SCHEDULING" — choose between best-time and a custom date.
class SchedulingSection extends ConsumerWidget {
  const SchedulingSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ComposerState state = ref.watch(composerViewModelProvider);
    final ComposerViewModel vm = ref.read(composerViewModelProvider.notifier);

    final DateTime bestSlot = ref
        .read(bestTimeServiceProvider)
        .nextBestSlot(state.post.selectedPlatforms);
    final String bestLabel = DateFormat('EEE, h:mm a').format(bestSlot);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SectionLabel('Scheduling'),
        const SizedBox(height: 12),
        SelectableOptionCard(
          icon: Icons.bolt,
          iconColor: AppColors.danger,
          title: ScheduleMode.bestTime.title,
          subtitle: ScheduleMode.bestTime.subtitle,
          selected: state.scheduleMode == ScheduleMode.bestTime,
          onTap: () => vm.setScheduleMode(ScheduleMode.bestTime),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.lavenderFill,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('Next: $bestLabel',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary)),
          ),
        ),
        const SizedBox(height: 10),
        SelectableOptionCard(
          icon: Icons.calendar_today_rounded,
          iconColor: Theme.of(context).colorScheme.primary,
          title: ScheduleMode.custom.title,
          subtitle: state.customScheduledAt == null
              ? ScheduleMode.custom.subtitle
              : DateFormat('MMM d, yyyy · h:mm a').format(state.customScheduledAt!),
          selected: state.scheduleMode == ScheduleMode.custom,
          onTap: () async {
            final DateTime? picked = await pickPublishDateTime(context);
            if (picked != null) {
              vm.setCustomDateTime(picked);
            } else {
              vm.setScheduleMode(ScheduleMode.custom);
            }
          },
        ),
      ],
    );
  }
}
