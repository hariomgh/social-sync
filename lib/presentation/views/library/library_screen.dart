import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/extensions.dart';
import '../../../data/models/post.dart';
import '../../providers/navigation_provider.dart';
import '../../viewmodels/composer_viewmodel.dart';
import '../../viewmodels/library_viewmodel.dart';
import 'widgets/post_tile.dart';

/// Drafts, the scheduled queue and published history in one place.
class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Post>> async = ref.watch(libraryViewModelProvider);
    final LibraryViewModel vm = ref.read(libraryViewModelProvider.notifier);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Library'),
          bottom: const TabBar(
            tabs: <Widget>[
              Tab(text: 'Drafts'),
              Tab(text: 'Scheduled'),
              Tab(text: 'History'),
            ],
          ),
          actions: <Widget>[
            IconButton(
              tooltip: 'Refresh',
              icon: const Icon(Icons.refresh),
              onPressed: vm.refresh,
            ),
          ],
        ),
        body: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (Object e, _) => Center(child: Text('Error: $e')),
          data: (_) => TabBarView(
            children: <Widget>[
              _PostList(
                posts: vm.drafts,
                emptyLabel: 'No drafts yet.',
                onEdit: (Post p) => _open(context, ref, p),
                onDelete: (Post p) => vm.delete(p.id),
              ),
              _PostList(
                posts: vm.scheduled,
                emptyLabel: 'Nothing scheduled.',
                onEdit: (Post p) => _open(context, ref, p),
                onDelete: (Post p) => vm.delete(p.id),
              ),
              _PostList(
                posts: vm.history,
                emptyLabel: 'No published posts yet.',
                onEdit: (Post p) => _open(context, ref, p),
                onDelete: (Post p) => vm.delete(p.id),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _open(BuildContext context, WidgetRef ref, Post post) {
    ref.read(composerViewModelProvider.notifier).loadPost(post);
    ref.read(homeTabProvider.notifier).state = 0;
    context.showSnack('Opened in composer');
  }
}

class _PostList extends StatelessWidget {
  const _PostList({
    required this.posts,
    required this.emptyLabel,
    required this.onEdit,
    required this.onDelete,
  });

  final List<Post> posts;
  final String emptyLabel;
  final ValueChanged<Post> onEdit;
  final ValueChanged<Post> onDelete;

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.inbox_outlined,
                size: 48, color: context.colors.onSurfaceVariant),
            const SizedBox(height: 8),
            Text(emptyLabel, style: context.textTheme.bodyMedium),
          ],
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        for (final Post p in posts)
          PostTile(
            post: p,
            onEdit: () => onEdit(p),
            onDelete: () => onDelete(p),
          ),
      ],
    );
  }
}
