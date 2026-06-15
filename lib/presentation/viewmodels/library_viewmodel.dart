import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/post.dart';
import '../../data/models/publish_result.dart';
import '../../data/models/social_account.dart';
import '../../data/models/social_platform.dart';
import '../../data/services/publish_service.dart';
import '../providers/app_providers.dart';

/// ViewModel backing the Library (drafts, scheduled queue, published history).
class LibraryViewModel extends AsyncNotifier<List<Post>> {
  @override
  Future<List<Post>> build() => ref.read(postRepositoryProvider).getAll();

  List<Post> get _all => state.valueOrNull ?? const <Post>[];

  List<Post> get drafts =>
      _all.where((Post p) => p.status == PostStatus.draft).toList();

  List<Post> get scheduled => _all
      .where((Post p) => p.status == PostStatus.scheduled)
      .toList()
    ..sort((Post a, Post b) =>
        (a.scheduledAt ?? a.updatedAt).compareTo(b.scheduledAt ?? b.updatedAt));

  List<Post> get history => _all
      .where((Post p) => const <PostStatus>{
            PostStatus.published,
            PostStatus.partiallyFailed,
            PostStatus.failed,
          }.contains(p.status))
      .toList();

  Future<void> refresh() async {
    state = const AsyncValue<List<Post>>.loading();
    state = await AsyncValue.guard(
      () => ref.read(postRepositoryProvider).getAll(),
    );
  }

  Future<void> delete(String id) async {
    await ref.read(postRepositoryProvider).delete(id);
    await refresh();
  }

  /// Publishes any scheduled posts whose time has arrived. Call on app start /
  /// resume. Returns the number of posts published.
  Future<int> publishDuePosts() async {
    final List<Post> due = scheduled
        .where((Post p) =>
            p.scheduledAt != null && !p.scheduledAt!.isAfter(DateTime.now()))
        .toList();
    if (due.isEmpty) return 0;

    final List<SocialAccount> accounts =
        await ref.read(accountRepositoryProvider).getAll();
    final Map<SocialPlatform, SocialAccount> accountMap =
        <SocialPlatform, SocialAccount>{
      for (final SocialAccount a in accounts) a.platform: a,
    };
    final PublishService publisher = ref.read(publishServiceProvider);

    for (final Post post in due) {
      final List<PublishOutcome> outcomes =
          await publisher.publish(post, accounts: accountMap);
      await ref.read(postRepositoryProvider).save(
            post.copyWith(
              status: PublishService.statusFrom(outcomes),
              outcomes: outcomes,
              updatedAt: DateTime.now(),
            ),
          );
    }
    await refresh();
    return due.length;
  }
}

final AsyncNotifierProvider<LibraryViewModel, List<Post>>
    libraryViewModelProvider =
    AsyncNotifierProvider<LibraryViewModel, List<Post>>(LibraryViewModel.new);
