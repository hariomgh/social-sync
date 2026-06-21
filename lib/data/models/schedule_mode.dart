/// How a post's publish time is chosen in the composer.
enum ScheduleMode {
  /// The app picks the next peak-engagement slot for the selected platforms.
  bestTime('Best time', 'Optimized for highest engagement'),

  /// The user picks an exact date and time.
  custom('Custom date', 'Select your own publishing window');

  const ScheduleMode(this.title, this.subtitle);
  final String title;
  final String subtitle;
}
