/// Formats a count compactly: 1240 -> "1.2k", 2_300_000 -> "2.3M".
String compactCount(int value) {
  if (value < 1000) return '$value';
  if (value < 1000000) {
    final double k = value / 1000;
    return '${k.toStringAsFixed(k >= 10 ? 0 : 1)}k';
  }
  final double m = value / 1000000;
  return '${m.toStringAsFixed(m >= 10 ? 0 : 1)}M';
}
