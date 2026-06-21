import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/analytics_summary.dart';
import '../../data/models/post.dart';
import '../providers/app_providers.dart';

/// Builds the analytics summary from saved posts. Recompute with [refresh]
/// after publishing.
class AnalyticsViewModel extends AsyncNotifier<AnalyticsSummary> {
  @override
  Future<AnalyticsSummary> build() => _load();

  Future<AnalyticsSummary> _load() async {
    final List<Post> posts = await ref.read(postRepositoryProvider).getAll();
    return ref.read(analyticsServiceProvider).summarize(posts);
  }

  Future<void> refresh() async {
    state = const AsyncValue<AnalyticsSummary>.loading();
    state = await AsyncValue.guard(_load);
  }
}

final AsyncNotifierProvider<AnalyticsViewModel, AnalyticsSummary>
    analyticsViewModelProvider =
    AsyncNotifierProvider<AnalyticsViewModel, AnalyticsSummary>(
        AnalyticsViewModel.new);
