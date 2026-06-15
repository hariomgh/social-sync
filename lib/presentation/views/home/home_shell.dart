import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/navigation_provider.dart';
import '../../viewmodels/library_viewmodel.dart';
import '../accounts/accounts_screen.dart';
import '../composer/composer_screen.dart';
import '../library/library_screen.dart';

/// Root shell with three destinations. Keeps each screen alive via [IndexedStack]
/// so the composer's in-progress post survives tab switches.
class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  static const List<Widget> _screens = <Widget>[
    ComposerScreen(),
    LibraryScreen(),
    AccountsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Publish any posts whose scheduled time has already passed.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(libraryViewModelProvider.notifier).publishDuePosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final int index = ref.watch(homeTabProvider);
    return Scaffold(
      body: IndexedStack(index: index, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (int i) =>
            ref.read(homeTabProvider.notifier).state = i,
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.edit_outlined),
            selectedIcon: Icon(Icons.edit),
            label: 'Compose',
          ),
          NavigationDestination(
            icon: Icon(Icons.collections_bookmark_outlined),
            selectedIcon: Icon(Icons.collections_bookmark),
            label: 'Library',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_circle_outlined),
            selectedIcon: Icon(Icons.account_circle),
            label: 'Accounts',
          ),
        ],
      ),
    );
  }
}
