/// Smart Tuning Engine for calculating optimal reminder intervals
/// 
/// Takes totalConsumed and hoursRemaining as inputs
/// Returns Duration for the next notification
class TuningEngine {
  /// Calculate the optimal reminder interval based on progress
  /// 
  /// [totalConsumed] - Total water consumed today in ml
  /// [hoursRemaining] - Hours remaining in the current day
  /// [dailyGoal] - Daily water intake goal in ml
  /// 
  /// Returns the Duration until the next reminder should be scheduled
  static Duration calculateNextReminderInterval({
    required double totalConsumed,
    required int hoursRemaining,
    required double dailyGoal,
  }) {
    // If goal is already achieved, remind less frequently (every 2 hours)
    if (totalConsumed >= dailyGoal) {
      return const Duration(hours: 2);
    }

    // Calculate remaining amount needed
    final remainingAmount = dailyGoal - totalConsumed;

    // If no hours remaining, remind every 30 minutes
    if (hoursRemaining <= 0) {
      return const Duration(minutes: 30);
    }

    // Calculate ideal consumption rate (ml per hour)
    final idealRatePerHour = remainingAmount / hoursRemaining;

    // Calculate how much should be consumed before next reminder
    // Aim for steady progress: consume ~10% of remaining per reminder
    final targetAmountPerReminder = remainingAmount * 0.1;

    // Calculate hours needed to consume target amount at ideal rate
    // Add some buffer to account for variations
    final hoursForTarget = targetAmountPerReminder / idealRatePerHour;

    // Clamp between 30 minutes and 2 hours
    final minutes = (hoursForTarget * 60).clamp(30.0, 120.0);

    return Duration(minutes: minutes.toInt());
  }

  /// Calculate reminder interval with smart tuning disabled
  /// Uses a fixed interval
  static Duration getFixedReminderInterval(int intervalMinutes) {
    return Duration(minutes: intervalMinutes);
  }

  /// Determine if user is on track to meet their goal
  /// 
  /// Returns true if current consumption rate is sufficient to meet goal
  static bool isOnTrack({
    required double totalConsumed,
    required int hoursRemaining,
    required double dailyGoal,
    required int hoursElapsed,
  }) {
    if (hoursElapsed <= 0) return true;

    // Calculate current consumption rate (ml per hour)
    final currentRate = totalConsumed / hoursElapsed;

    // Calculate required rate to meet goal
    final requiredRate = dailyGoal / 24; // Assuming 24-hour day

    return currentRate >= requiredRate * 0.8; // 80% of required rate is "on track"
  }
}
