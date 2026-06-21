import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// The lavender "Editor Insights" callout. Holds a labelled body and a row of
/// action buttons (e.g. "Apply Optimization" / "Reschedule").
class InsightCard extends StatelessWidget {
  const InsightCard({
    super.key,
    required this.body,
    this.label = 'EDITOR INSIGHTS',
    this.icon = Icons.auto_awesome,
    this.actions = const <Widget>[],
  });

  final Widget body;
  final String label;
  final IconData icon;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final Color accent = Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lavenderFill.withOpacity(0.6),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withOpacity(0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(icon, size: 16, color: accent),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: accent,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          body,
          if (actions.isNotEmpty) ...<Widget>[
            const SizedBox(height: 14),
            Row(children: _spaced(actions)),
          ],
        ],
      ),
    );
  }

  List<Widget> _spaced(List<Widget> items) {
    final List<Widget> out = <Widget>[];
    for (int i = 0; i < items.length; i++) {
      out.add(Expanded(child: items[i]));
      if (i != items.length - 1) out.add(const SizedBox(width: 10));
    }
    return out;
  }
}

/// Compact pill button used inside [InsightCard] action rows.
class InsightActionButton extends StatelessWidget {
  const InsightActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.filled = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final Color accent = Theme.of(context).colorScheme.primary;
    return Material(
      color: filled ? accent : Colors.transparent,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: filled ? null : Border.all(color: accent.withOpacity(0.5)),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: filled ? Colors.white : accent,
              fontWeight: FontWeight.w700,
              fontSize: 13.5,
            ),
          ),
        ),
      ),
    );
  }
}
