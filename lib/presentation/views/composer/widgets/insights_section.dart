import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/date_picker.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../data/models/insight.dart';
import '../../../viewmodels/composer_viewmodel.dart';
import '../../../widgets/insight_card.dart';

/// Surfaces the highest-priority live insight as an "Editor Insights" card with
/// functional optimization actions.
class InsightsSection extends ConsumerWidget {
  const InsightsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ComposerState state = ref.watch(composerViewModelProvider);
    final ComposerViewModel vm = ref.read(composerViewModelProvider.notifier);
    final List<Insight> insights = state.insights;
    if (insights.isEmpty) return const SizedBox.shrink();

    final Insight top = _topPriority(insights);

    return InsightCard(
      body: Text(top.message, style: Theme.of(context).textTheme.bodyMedium),
      actions: <Widget>[
        if (top.hasAction)
          InsightActionButton(
            label: top.actionLabel ?? 'Apply optimization',
            filled: true,
            onPressed: () {
              vm.applyOptimization(top.action!);
              context.showSnack('Optimization applied');
            },
          ),
        InsightActionButton(
          label: 'Reschedule',
          onPressed: () async {
            final DateTime? picked = await pickPublishDateTime(context);
            if (picked != null) vm.setCustomDateTime(picked);
          },
        ),
      ],
    );
  }

  Insight _topPriority(List<Insight> insights) {
    int rank(InsightSeverity s) => switch (s) {
          InsightSeverity.warning => 0,
          InsightSeverity.opportunity => 1,
          InsightSeverity.tip => 2,
        };
    final List<Insight> sorted = <Insight>[...insights]
      ..sort((Insight a, Insight b) => rank(a.severity).compareTo(rank(b.severity)));
    return sorted.first;
  }
}
