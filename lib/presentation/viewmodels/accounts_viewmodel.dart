import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/result.dart';
import '../../data/models/social_account.dart';
import '../../data/models/social_platform.dart';
import '../providers/app_providers.dart';

/// ViewModel for the Accounts screen. Exposes the connected accounts and the
/// connect/disconnect intents, refreshing itself after each change.
class AccountsViewModel extends AsyncNotifier<List<SocialAccount>> {
  @override
  Future<List<SocialAccount>> build() =>
      ref.read(accountRepositoryProvider).getAll();

  SocialAccount? accountFor(SocialPlatform platform) =>
      state.valueOrNull?.firstWhereOrNull((a) => a.platform == platform);

  bool isConnected(SocialPlatform platform) => accountFor(platform) != null;

  Future<Result<SocialAccount>> connect(SocialPlatform platform) async {
    final Result<SocialAccount> result =
        await ref.read(accountRepositoryProvider).connect(platform);
    if (result.isSuccess) await _refresh();
    return result;
  }

  Future<void> disconnect(SocialPlatform platform) async {
    await ref.read(accountRepositoryProvider).disconnect(platform);
    await _refresh();
  }

  Future<void> _refresh() async {
    state = const AsyncValue<List<SocialAccount>>.loading();
    state = await AsyncValue.guard(
      () => ref.read(accountRepositoryProvider).getAll(),
    );
  }
}

final AsyncNotifierProvider<AccountsViewModel, List<SocialAccount>>
    accountsViewModelProvider =
    AsyncNotifierProvider<AccountsViewModel, List<SocialAccount>>(
        AccountsViewModel.new);
