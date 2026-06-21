import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Uppercase, letter-spaced section header (e.g. "TARGET PLATFORMS").
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key, this.trailing});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final Text label = Text(
      text.toUpperCase(),
      style: const TextStyle(
        color: AppColors.sectionLabel,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.1,
      ),
    );
    if (trailing == null) return label;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[label, trailing!],
    );
  }
}
