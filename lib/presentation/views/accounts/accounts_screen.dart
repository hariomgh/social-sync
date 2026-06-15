import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/api_config.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/utils/result.dart';
import '../../../data/models/social_account.dart';
import '../../../data/models/social_platform.dart';
import '../../viewmodels/accounts_viewmodel.dart';
import '../../widgets/avatars.dart';

/// Connect and manage the social accounts posts are published to.
class AccountsScreen extends ConsumerStatefulWidget {
  const AccountsScreen({super.key});

  @override
  ConsumerState<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends ConsumerState<AccountsScreen> {
  SocialPlatform? _busy;

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<SocialAccount>> accountsAsync =
        ref.watch(accountsViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Accounts')),
      body: accountsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object e, _) => Center(child: Text('Error: $e')),
        data: (List<SocialAccount> accounts) => ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            if (ApiConfig.demoMode) const _DemoBanner(),
            for (final SocialPlatform p in SocialPlatform.values)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _AccountCard(
                  platform: p,
                  account: accounts
                      .firstWhereOrNull((SocialAccount a) => a.platform == p),
                  busy: _busy == p,
                  onConnect: () => _connect(p),
                  onDisconnect: () => _disconnect(p),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _connect(SocialPlatform platform) async {
    setState(() => _busy = platform);
    final Result<SocialAccount> result =
        await ref.read(accountsViewModelProvider.notifier).connect(platform);
    if (!mounted) return;
    setState(() => _busy = null);
    result.when(
      success: (SocialAccount a) =>
          context.showSnack('Connected ${a.platform.label}'),
      failure: (String m, _) => context.showSnack(m, isError: true),
    );
  }

  Future<void> _disconnect(SocialPlatform platform) async {
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('Disconnect ${platform.label}?'),
        content: const Text('You can reconnect anytime.'),
        actions: <Widget>[
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Disconnect')),
        ],
      ),
    );
    if (ok ?? false) {
      await ref.read(accountsViewModelProvider.notifier).disconnect(platform);
      if (mounted) context.showSnack('${platform.label} disconnected');
    }
  }
}

class _DemoBanner extends StatelessWidget {
  const _DemoBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.colors.tertiaryContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.science_outlined),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Demo mode is on — connecting and publishing are simulated. '
              'Add API credentials and turn off demoMode in api_config.dart to go live.',
              style: context.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({
    required this.platform,
    required this.account,
    required this.busy,
    required this.onConnect,
    required this.onDisconnect,
  });

  final SocialPlatform platform;
  final SocialAccount? account;
  final bool busy;
  final VoidCallback onConnect;
  final VoidCallback onDisconnect;

  @override
  Widget build(BuildContext context) {
    final bool connected = account != null;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.outlineVariant),
      ),
      child: Row(
        children: <Widget>[
          PlatformBadge(platform: platform, size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(platform.label,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(
                  connected ? 'Connected · ${account!.handle}' : 'Not connected',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: connected
                        ? context.colors.primary
                        : context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (busy)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else if (connected)
            TextButton(onPressed: onDisconnect, child: const Text('Disconnect'))
          else
            FilledButton(onPressed: onConnect, child: const Text('Connect')),
        ],
      ),
    );
  }
}
