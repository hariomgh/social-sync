import '../../core/constants/app_constants.dart';
import '../../core/utils/result.dart';
import '../models/social_account.dart';
import '../models/social_platform.dart';
import '../services/local_store.dart';
import '../services/oauth_service.dart';
import '../services/token_store.dart';

/// Manages connected social accounts: running the OAuth flow, persisting account
/// metadata, and storing/clearing tokens via [TokenStore].
class AccountRepository {
  AccountRepository({
    required LocalStore store,
    required OAuthService oauth,
    required TokenStore tokenStore,
  })  : _store = store,
        _oauth = oauth,
        _tokenStore = tokenStore;

  final LocalStore _store;
  final OAuthService _oauth;
  final TokenStore _tokenStore;

  Future<List<SocialAccount>> getAll() async {
    return _store
        .readJsonList(AppConstants.kAccountsBox)
        .map(SocialAccount.fromJson)
        .toList();
  }

  /// Starts the OAuth flow for [platform] and, on success, persists the account
  /// and its token.
  Future<Result<SocialAccount>> connect(SocialPlatform platform) async {
    final Result<OAuthResult> result = await _oauth.connect(platform);
    return result.when(
      success: (OAuthResult value) async {
        await _tokenStore.save(platform, value.token);
        await _upsert(value.account);
        return Success<SocialAccount>(value.account);
      },
      failure: (String message, Object? error) async =>
          Failure<SocialAccount>(message, error),
    );
  }

  Future<void> disconnect(SocialPlatform platform) async {
    await _tokenStore.delete(platform);
    final List<SocialAccount> accounts = await getAll()
      ..removeWhere((SocialAccount a) => a.platform == platform);
    await _persist(accounts);
  }

  Future<void> _upsert(SocialAccount account) async {
    final List<SocialAccount> accounts = await getAll();
    final int index =
        accounts.indexWhere((SocialAccount a) => a.platform == account.platform);
    if (index >= 0) {
      accounts[index] = account;
    } else {
      accounts.add(account);
    }
    await _persist(accounts);
  }

  Future<void> _persist(List<SocialAccount> accounts) {
    return _store.writeJsonList(
      AppConstants.kAccountsBox,
      accounts.map((SocialAccount a) => a.toJson()).toList(),
    );
  }
}
