import '../../core/constants/app_constants.dart';
import '../models/post.dart';
import '../services/local_store.dart';

/// Persists posts (drafts, scheduled and published history) to local storage.
///
/// This is the single source of truth for saved posts; ViewModels read through
/// it and never touch storage directly.
class PostRepository {
  PostRepository(this._store);

  final LocalStore _store;

  Future<List<Post>> getAll() async {
    final List<Map<String, dynamic>> raw =
        _store.readJsonList(AppConstants.kPostsBox);
    final List<Post> posts =
        raw.map(Post.fromJson).toList(growable: true);
    posts.sort((Post a, Post b) => b.updatedAt.compareTo(a.updatedAt));
    return posts;
  }

  /// Inserts or updates [post] by id.
  Future<void> save(Post post) async {
    final List<Post> posts = await getAll();
    final int index = posts.indexWhere((Post p) => p.id == post.id);
    if (index >= 0) {
      posts[index] = post;
    } else {
      posts.add(post);
    }
    await _persist(posts);
  }

  Future<void> delete(String id) async {
    final List<Post> posts = await getAll()
      ..removeWhere((Post p) => p.id == id);
    await _persist(posts);
  }

  Future<void> _persist(List<Post> posts) {
    return _store.writeJsonList(
      AppConstants.kPostsBox,
      posts.map((Post p) => p.toJson()).toList(),
    );
  }
}
