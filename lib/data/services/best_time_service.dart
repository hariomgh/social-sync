import '../models/social_platform.dart';

/// Computes the next peak-engagement publishing slot for a set of platforms.
///
/// Phase-1 uses a per-platform table of high-engagement local hours (a widely
/// cited heuristic). The API is structured so it can later be driven by the
/// user's own analytics instead of static windows.
class BestTimeService {
  const BestTimeService();

  /// High-engagement local hours (24h) per platform.
  static const Map<String, List<int>> _windows = <String, List<int>>{
    'instagram': <int>[11, 13, 19],
    'facebook': <int>[9, 13, 15],
    'linkedin': <int>[8, 10, 12, 17],
    'x': <int>[8, 12, 17, 21],
  };

  /// The next slot (on the hour) that is in a peak window for any of the
  /// [platforms], at least 15 minutes from [from] (defaults to now).
  DateTime nextBestSlot(List<SocialPlatform> platforms, {DateTime? from}) {
    final DateTime now = from ?? DateTime.now();
    final Set<int> hours = <int>{};
    for (final SocialPlatform p in platforms) {
      hours.addAll(_windows[p.id] ?? const <int>[9, 12, 18]);
    }
    if (hours.isEmpty) hours.addAll(const <int>[9, 12, 18]);

    final List<int> sortedHours = hours.toList()..sort();
    final DateTime earliest = now.add(const Duration(minutes: 15));

    for (int d = 0; d < 8; d++) {
      final DateTime base = DateTime(now.year, now.month, now.day).add(
        Duration(days: d),
      );
      for (final int h in sortedHours) {
        final DateTime slot = DateTime(base.year, base.month, base.day, h);
        if (slot.isAfter(earliest)) return slot;
      }
    }
    return now.add(const Duration(hours: 1));
  }
}
