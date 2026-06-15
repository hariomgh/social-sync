import 'package:flutter/material.dart';

/// Convenience accessors on [BuildContext].
extension BuildContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colors => Theme.of(this).colorScheme;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  void showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: isError ? colors.error : null,
        ),
      );
  }
}

/// String helpers used across the composer and previews.
extension StringX on String {
  /// Truncates to [max] characters, appending an ellipsis when cut.
  String truncate(int max) =>
      length <= max ? this : '${substring(0, max).trimRight()}…';

  /// Extracts unique hashtags (e.g. `#flutter`) preserving order.
  List<String> get hashtags {
    final RegExp re = RegExp(r'(?<!\w)#(\w+)');
    final List<String> out = <String>[];
    for (final RegExpMatch m in re.allMatches(this)) {
      final String tag = m.group(0)!;
      if (!out.contains(tag)) out.add(tag);
    }
    return out;
  }

  /// Extracts unique @mentions preserving order.
  List<String> get mentions {
    final RegExp re = RegExp(r'(?<!\w)@(\w+)');
    final List<String> out = <String>[];
    for (final RegExpMatch m in re.allMatches(this)) {
      final String mention = m.group(0)!;
      if (!out.contains(mention)) out.add(mention);
    }
    return out;
  }
}

/// DateTime formatting helpers.
extension DateTimeX on DateTime {
  /// Short, human relative label such as "in 2h" or "3d ago".
  String get relativeLabel {
    final Duration diff = difference(DateTime.now());
    final bool future = !diff.isNegative;
    final Duration abs = diff.abs();
    final String value;
    if (abs.inMinutes < 1) {
      value = 'now';
      return value;
    } else if (abs.inHours < 1) {
      value = '${abs.inMinutes}m';
    } else if (abs.inDays < 1) {
      value = '${abs.inHours}h';
    } else if (abs.inDays < 7) {
      value = '${abs.inDays}d';
    } else {
      value = '${(abs.inDays / 7).floor()}w';
    }
    return future ? 'in $value' : '$value ago';
  }
}
