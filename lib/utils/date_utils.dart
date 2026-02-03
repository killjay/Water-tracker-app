import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'constants.dart';

class AppDateUtils {
  static bool _initialized = false;
  
  /// Initialize timezone data
  static Future<void> initialize() async {
    if (!_initialized) {
      tz.initializeTimeZones();
      _initialized = true;
    }
  }
  
  /// Get the user's local timezone
  static tz.Location getLocalLocation() {
    return tz.local;
  }
  
  /// Generate dayKey in format "YYYY-MM-DD" based on user's local timezone
  static String generateDayKey([DateTime? date]) {
    final now = date ?? DateTime.now();
    final localTz = getLocalLocation();
    final localTime = tz.TZDateTime.from(now, localTz);
    
    return DateFormat(AppConstants.dayKeyFormat).format(localTime);
  }
  
  /// Get start of day in user's local timezone
  static DateTime getStartOfDay([DateTime? date]) {
    final now = date ?? DateTime.now();
    final localTz = getLocalLocation();
    final localTime = tz.TZDateTime.from(now, localTz);
    
    return tz.TZDateTime(
      localTz,
      localTime.year,
      localTime.month,
      localTime.day,
      0,
      0,
      0,
    );
  }
  
  /// Get end of day in user's local timezone
  static DateTime getEndOfDay([DateTime? date]) {
    final now = date ?? DateTime.now();
    final localTz = getLocalLocation();
    final localTime = tz.TZDateTime.from(now, localTz);
    
    return tz.TZDateTime(
      localTz,
      localTime.year,
      localTime.month,
      localTime.day,
      23,
      59,
      59,
      999,
    );
  }
  
  /// Check if two dates are on the same day (in user's local timezone)
  static bool isSameDay(DateTime date1, DateTime date2) {
    return generateDayKey(date1) == generateDayKey(date2);
  }
  
  /// Get hours remaining in current day
  static int getHoursRemainingInDay() {
    final now = DateTime.now();
    final localTz = getLocalLocation();
    final localTime = tz.TZDateTime.from(now, localTz);
    final endOfDay = getEndOfDay(now);
    
    final difference = endOfDay.difference(localTime);
    return difference.inHours;
  }
  
  /// Format date for display
  static String formatDate(DateTime date, [String format = 'MMM dd, yyyy']) {
    return DateFormat(format).format(date);
  }
  
  /// Format time for display
  static String formatTime(DateTime date) {
    return DateFormat('hh:mm a').format(date);
  }
}
