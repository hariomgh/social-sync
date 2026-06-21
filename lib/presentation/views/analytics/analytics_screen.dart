import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/utils/extensions.dart';
import '../../../core/utils/format.dart';
import '../../../data/models/analytics_summary.dart';
import '../../viewmodels/analytics_viewmodel.dart';
import '../../widgets/section_label.dart';

/// Posting analytics derived from the user's history: volume, success rate,
/// projected engagement, 7-day activity and a per-platform breakdown.
class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<AnalyticsSummary> async =
        ref.watch(analyticsViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: ref.read(analyticsViewModelProvider.notifier).refresh,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object e, _) => Center(child: Text('Error: $e')),
        data: (AnalyticsSummary s) =>
            s.isEmpty ? const _Empty() : _Content(summary: s),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.insights_outlined,
              size: 52, color: context.colors.onSurfaceVariant),
          const SizedBox(height: 10),
          Text('No analytics yet', style: context.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text('Publish a post to start tracking performance.',
              style: context.textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.summary});
  final AnalyticsSummary summary;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
                child: _StatCard(
                    label: 'Published',
                    value: '${summary.totalPublished}',
                    icon: Icons.send_rounded)),
            const SizedBox(width: 12),
            Expanded(
                child: _StatCard(
                    label: 'Scheduled',
                    value: '${summary.totalScheduled}',
                    icon: Icons.schedule_rounded)),
            const SizedBox(width: 12),
            Expanded(
                child: _StatCard(
                    label: 'Success',
                    value: '${(summary.overallSuccessRate * 100).round()}%',
                    icon: Icons.verified_rounded)),
          ],
        ),
        const SizedBox(height: 22),
        const SectionLabel('Total engagement'),
        const SizedBox(height: 12),
        _EngagementCard(summary: summary),
        const SizedBox(height: 22),
        const SectionLabel('Last 7 days'),
        const SizedBox(height: 12),
        _ActivityChart(days: summary.last7Days),
        const SizedBox(height: 22),
        const SectionLabel('By platform'),
        const SizedBox(height: 12),
        for (final PlatformStat stat in summary.perPlatform)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _PlatformRow(stat: stat, max: _maxEngagement(summary)),
          ),
      ],
    );
  }

  int _maxEngagement(AnalyticsSummary s) {
    int max = 1;
    for (final PlatformStat p in s.perPlatform) {
      if (p.engagement.total > max) max = p.engagement.total;
    }
    return max;
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard(
      {required this.label, required this.value, required this.icon});
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 18, color: context.colors.primary),
          const SizedBox(height: 10),
          Text(value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          Text(label, style: context.textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _EngagementCard extends StatelessWidget {
  const _EngagementCard({required this.summary});
  final AnalyticsSummary summary;

  @override
  Widget build(BuildContext context) {
    final e = summary.totalEngagement;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.colors.outlineVariant),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          _Metric(label: 'Likes', value: e.likes, icon: Icons.favorite),
          _Metric(label: 'Comments', value: e.comments, icon: Icons.mode_comment),
          _Metric(label: 'Shares', value: e.shares, icon: Icons.repeat),
          _Metric(label: 'Views', value: e.views, icon: Icons.bar_chart),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric(
      {required this.label, required this.value, required this.icon});
  final String label;
  final int value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Icon(icon, size: 18, color: context.colors.primary),
        const SizedBox(height: 6),
        Text(compactCount(value),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        Text(label, style: context.textTheme.bodySmall),
      ],
    );
  }
}

class _ActivityChart extends StatelessWidget {
  const _ActivityChart({required this.days});
  final List<DailyCount> days;

  @override
  Widget build(BuildContext context) {
    final int max =
        days.fold<int>(1, (int m, DailyCount d) => d.count > m ? d.count : m);
    return Container(
      height: 150,
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 10),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.colors.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          for (final DailyCount d in days)
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Text(d.count == 0 ? '' : '${d.count}',
                      style: context.textTheme.labelSmall),
                  const SizedBox(height: 4),
                  Container(
                    height: 80 * (d.count / max).clamp(0.04, 1.0),
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: <Color>[Color(0xFF4C6FF5), Color(0xFF8A5BF6)],
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(DateFormat('E').format(d.day).substring(0, 1),
                      style: context.textTheme.labelSmall),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _PlatformRow extends StatelessWidget {
  const _PlatformRow({required this.stat, required this.max});
  final PlatformStat stat;
  final int max;

  @override
  Widget build(BuildContext context) {
    final double factor = (stat.engagement.total / max).clamp(0.02, 1.0);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(stat.platform.icon, size: 18, color: stat.platform.brandColor),
              const SizedBox(width: 8),
              Text(stat.platform.label,
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              const Spacer(),
              Text('${stat.postCount} posts',
                  style: context.textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Stack(
              children: <Widget>[
                Container(height: 8, color: context.colors.surfaceContainerHighest),
                FractionallySizedBox(
                  widthFactor: factor,
                  child: Container(height: 8, color: stat.platform.brandColor),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${compactCount(stat.engagement.total)} engagements · ${(stat.successRate * 100).round()}% delivered',
            style: context.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
