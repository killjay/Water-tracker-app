class AppConstants {
  // Default values
  static const double defaultDailyGoal = 2000.0; // ml
  static const String defaultUnit = 'ml';
  
  // Standard cup sizes (in ml)
  static const Map<String, double> standardCupSizes = {
    'Small': 250.0,
    'Medium': 350.0,
    'Large': 500.0,
    'Bottle': 750.0,
  };
  
  // Firestore collections
  static const String usersCollection = 'users';
  static const String waterEntriesCollection = 'waterEntries';
  static const String dailyStatsCollection = 'dailyStats';
  
  // SharedPreferences keys
  static const String reminderEnabledKey = 'reminder_enabled';
  static const String reminderIntervalKey = 'reminder_interval';
  static const String smartTuningEnabledKey = 'smart_tuning_enabled';
  
  // Notification IDs
  static const int waterReminderNotificationId = 1;
  
  // Date format
  static const String dayKeyFormat = 'yyyy-MM-dd';
}
