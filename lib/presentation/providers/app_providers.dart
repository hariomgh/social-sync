import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/repositories/account_repository.dart';
import '../../data/repositories/post_repository.dart';
import '../../data/services/local_store.dart';
import '../../data/services/media_service.dart';
import '../../data/services/oauth_service.dart';
import '../../data/services/publish_service.dart';
import '../../data/services/scheduler_service.dart';
import '../../data/services/token_store.dart';

/// Dependency-injection graph for the app.
///
/// [sharedPreferencesProvider] is overridden in `main()` after the async
/// `SharedPreferences.getInstance()` resolves, which lets every downstream
/// provider stay synchronous and easily testable (override with fakes in tests).

final Provider<SharedPreferences> sharedPreferencesProvider =
    Provider<SharedPreferences>(
  (Ref ref) => throw UnimplementedError('Override in main()'),
);

final Provider<LocalStore> localStoreProvider = Provider<LocalStore>(
  (Ref ref) => LocalStore(ref.watch(sharedPreferencesProvider)),
);

final Provider<TokenStore> tokenStoreProvider =
    Provider<TokenStore>((Ref ref) => TokenStore());

final Provider<OAuthService> oauthServiceProvider =
    Provider<OAuthService>((Ref ref) => OAuthService());

final Provider<MediaService> mediaServiceProvider =
    Provider<MediaService>((Ref ref) => MediaService());

final Provider<SchedulerService> schedulerServiceProvider =
    Provider<SchedulerService>((Ref ref) => SchedulerService());

final Provider<PublishService> publishServiceProvider =
    Provider<PublishService>(
  (Ref ref) => PublishService(tokenStore: ref.watch(tokenStoreProvider)),
);

final Provider<PostRepository> postRepositoryProvider =
    Provider<PostRepository>(
  (Ref ref) => PostRepository(ref.watch(localStoreProvider)),
);

final Provider<AccountRepository> accountRepositoryProvider =
    Provider<AccountRepository>(
  (Ref ref) => AccountRepository(
    store: ref.watch(localStoreProvider),
    oauth: ref.watch(oauthServiceProvider),
    tokenStore: ref.watch(tokenStoreProvider),
  ),
);
