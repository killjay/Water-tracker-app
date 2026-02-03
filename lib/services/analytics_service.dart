import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  // Log water entry added
  Future<void> logWaterEntryAdded({
    required double amount,
    String? cupSize,
  }) async {
    await _analytics.logEvent(
      name: 'water_entry_added',
      parameters: {
        'amount': amount,
        'cup_size': cupSize ?? 'custom',
      },
    );
  }

  // Log water entry deleted
  Future<void> logWaterEntryDeleted() async {
    await _analytics.logEvent(name: 'water_entry_deleted');
  }

  // Log goal achieved
  Future<void> logGoalAchieved({required double totalAmount}) async {
    await _analytics.logEvent(
      name: 'goal_achieved',
      parameters: {
        'total_amount': totalAmount,
      },
    );
  }

  // Log goal updated
  Future<void> logGoalUpdated({required double newGoal}) async {
    await _analytics.logEvent(
      name: 'goal_updated',
      parameters: {
        'new_goal': newGoal,
      },
    );
  }

  // Log reminder enabled/disabled
  Future<void> logReminderToggled({required bool enabled}) async {
    await _analytics.logEvent(
      name: 'reminder_toggled',
      parameters: {
        'enabled': enabled,
      },
    );
  }

  // Log smart tuning enabled/disabled
  Future<void> logSmartTuningToggled({required bool enabled}) async {
    await _analytics.logEvent(
      name: 'smart_tuning_toggled',
      parameters: {
        'enabled': enabled,
      },
    );
  }

  // Set user property
  Future<void> setUserProperty({
    required String name,
    required String value,
  }) async {
    await _analytics.setUserProperty(name: name, value: value);
  }

  // Set user ID
  Future<void> setUserId(String userId) async {
    await _analytics.setUserId(id: userId);
  }

  // Log screen view
  Future<void> logScreenView(String screenName) async {
    await _analytics.logScreenView(screenName: screenName);
  }
}
