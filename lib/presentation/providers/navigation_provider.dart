import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Index of the selected tab in the home shell (0=Compose, 1=Library,
/// 2=Accounts). Exposed as a provider so other screens (e.g. Library's "open in
/// composer") can switch tabs.
final StateProvider<int> homeTabProvider = StateProvider<int>((Ref ref) => 0);
