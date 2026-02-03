class GoalCalculator {
  /// Calculate daily water goal in ml based on weight, activity level and sleep window.
  /// Very simple heuristic that can be tuned later.
  static double calculateGoal({
    required double weightKg,
    required String activityLevel, // 'low', 'medium', 'high'
    required int wakeTimeMinutes,
    required int sleepTimeMinutes,
  }) {
    // Base: 35 ml per kg
    double goal = weightKg * 35.0;

    // Activity multiplier
    switch (activityLevel) {
      case 'high':
        goal *= 1.25;
        break;
      case 'medium':
        goal *= 1.1;
        break;
      case 'low':
      default:
        break;
    }

    // Adjust slightly based on awake duration (shorter awake time -> slightly lower goal)
    int awakeMinutes;
    if (sleepTimeMinutes > wakeTimeMinutes) {
      awakeMinutes = sleepTimeMinutes - wakeTimeMinutes;
    } else {
      // Sleep crosses midnight
      awakeMinutes = (24 * 60 - wakeTimeMinutes) + sleepTimeMinutes;
    }
    final awakeHours = awakeMinutes / 60.0;
    // Normalize relative to 16h awake baseline
    goal *= (awakeHours / 16.0).clamp(0.75, 1.25);

    // Clamp goal between 1200ml and 5000ml for safety
    if (goal < 1200) goal = 1200;
    if (goal > 5000) goal = 5000;

    return goal;
  }
}

