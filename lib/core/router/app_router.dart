import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/views/home/home_shell.dart';

/// App routing. The home shell hosts the tabbed destinations; additional
/// top-level routes (e.g. onboarding, a full-screen preview) can be added here.
final Provider<GoRouter> routerProvider = Provider<GoRouter>((Ref ref) {
  return GoRouter(
    initialLocation: '/',
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        name: 'home',
        builder: (BuildContext context, GoRouterState state) =>
            const HomeShell(),
      ),
    ],
  );
});
