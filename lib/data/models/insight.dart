import 'package:flutter/foundation.dart';

/// Severity controls how an insight is presented.
enum InsightSeverity { tip, opportunity, warning }

/// A concrete optimization the composer can apply when the user taps the
/// insight's action button.
enum OptimizationAction { switchToBestTime, trimForX, addHashtags }

/// A single, actionable recommendation produced by the insights engine.
@immutable
class Insight {
  const Insight({
    required this.title,
    required this.message,
    this.severity = InsightSeverity.opportunity,
    this.action,
    this.actionLabel,
  });

  final String title;
  final String message;
  final InsightSeverity severity;
  final OptimizationAction? action;
  final String? actionLabel;

  bool get hasAction => action != null;
}
