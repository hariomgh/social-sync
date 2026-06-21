import 'package:flutter/material.dart';

/// Shows a date picker followed by a time picker and returns the combined
/// [DateTime], or null if the user cancels either step.
Future<DateTime?> pickPublishDateTime(BuildContext context) async {
  final DateTime now = DateTime.now();
  final DateTime initial = now.add(const Duration(hours: 1));
  final DateTime? date = await showDatePicker(
    context: context,
    initialDate: initial,
    firstDate: now,
    lastDate: now.add(const Duration(days: 365)),
  );
  if (date == null || !context.mounted) return null;
  final TimeOfDay? time = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.fromDateTime(initial),
  );
  if (time == null) return null;
  return DateTime(date.year, date.month, date.day, time.hour, time.minute);
}
