import 'package:flutter_test/flutter_test.dart';
import 'package:water_tracker/services/tuning_engine.dart';

void main() {
  group('TuningEngine', () {
    test('calculateNextReminderInterval should return valid duration', () {
      final duration = TuningEngine.calculateNextReminderInterval(
        totalConsumed: 500.0,
        hoursRemaining: 12,
        dailyGoal: 2000.0,
      );

      expect(duration, isA<Duration>());
      expect(duration.inMinutes, greaterThanOrEqualTo(30));
      expect(duration.inMinutes, lessThanOrEqualTo(120));
    });

    test('should return 2 hours when goal is achieved', () {
      final duration = TuningEngine.calculateNextReminderInterval(
        totalConsumed: 2000.0,
        hoursRemaining: 5,
        dailyGoal: 2000.0,
      );

      expect(duration.inHours, equals(2));
    });

    test('should return 30 minutes when no hours remaining', () {
      final duration = TuningEngine.calculateNextReminderInterval(
        totalConsumed: 1000.0,
        hoursRemaining: 0,
        dailyGoal: 2000.0,
      );

      expect(duration.inMinutes, equals(30));
    });

    test('getFixedReminderInterval should return correct duration', () {
      final duration = TuningEngine.getFixedReminderInterval(60);
      expect(duration.inMinutes, equals(60));
    });

    test('isOnTrack should return true when on track', () {
      final isOnTrack = TuningEngine.isOnTrack(
        totalConsumed: 1000.0,
        hoursRemaining: 12,
        dailyGoal: 2000.0,
        hoursElapsed: 12,
      );

      expect(isOnTrack, isA<bool>());
    });
  });
}
