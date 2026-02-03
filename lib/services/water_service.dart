import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/water_entry_model.dart';
import '../models/daily_stats_model.dart';
import '../utils/constants.dart';
import '../utils/date_utils.dart';

class WaterService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Enable offline persistence
  static Future<void> enableOfflinePersistence() async {
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
    );
  }

  // Add water entry
  Future<WaterEntryModel> addWaterEntry({
    required String userId,
    required double amount,
    String? cupSize,
  }) async {
    try {
      // Generate dayKey from current timestamp
      final now = DateTime.now();
      final dayKey = AppDateUtils.generateDayKey(now);

      final entry = WaterEntryModel(
        id: '', // Will be set by Firestore
        userId: userId,
        timestamp: now,
        amount: amount,
        cupSize: cupSize,
        dayKey: dayKey,
      );

      // Add entry to Firestore
      final docRef = await _firestore
          .collection(AppConstants.waterEntriesCollection)
          .add(entry.toMap());

      // Update daily stats transactionally
      await _updateDailyStats(userId, dayKey, amount, increment: true);

      return entry.copyWith(id: docRef.id);
    } catch (e) {
      throw Exception('Error adding water entry: $e');
    }
  }

  // Delete water entry (transactional)
  Future<void> deleteWaterEntry({
    required String userId,
    required String entryId,
    required double amount,
    required String dayKey,
  }) async {
    try {
      // Use transaction to ensure atomicity
      await _firestore.runTransaction((transaction) async {
        // Delete the entry
        final entryRef = _firestore
            .collection(AppConstants.waterEntriesCollection)
            .doc(entryId);

        transaction.delete(entryRef);

        // Decrement daily stats
        final statsRef = _firestore
            .collection(AppConstants.dailyStatsCollection)
            .doc(userId)
            .collection('stats')
            .doc(dayKey);

        final statsDoc = await transaction.get(statsRef);

        if (statsDoc.exists) {
          final currentTotal = (statsDoc.data()!['totalAmount'] as num?)?.toDouble() ?? 0.0;
          final currentCount = statsDoc.data()!['entryCount'] ?? 0;

          transaction.update(statsRef, {
            'totalAmount': (currentTotal - amount).clamp(0.0, double.infinity),
            'entryCount': (currentCount - 1).clamp(0, 999999),
          });
        }
      });
    } catch (e) {
      throw Exception('Error deleting water entry: $e');
    }
  }

  // Get water entries for a specific day
  Future<List<WaterEntryModel>> getWaterEntriesForDay({
    required String userId,
    required String dayKey,
  }) async {
    try {
      // Query without orderBy to avoid index requirement during index building
      // We'll sort in memory instead
      final querySnapshot = await _firestore
          .collection(AppConstants.waterEntriesCollection)
          .where('userId', isEqualTo: userId)
          .where('dayKey', isEqualTo: dayKey)
          .get();

      final entries = querySnapshot.docs
          .map((doc) => WaterEntryModel.fromMap(doc.data(), doc.id))
          .toList();
      
      // Sort by timestamp descending in memory
      entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      return entries;
    } catch (e) {
      throw Exception('Error fetching water entries: $e');
    }
  }

  // Get water entries for a date range
  Future<List<WaterEntryModel>> getWaterEntriesForRange({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final startDayKey = AppDateUtils.generateDayKey(startDate);
      final endDayKey = AppDateUtils.generateDayKey(endDate);

      final querySnapshot = await _firestore
          .collection(AppConstants.waterEntriesCollection)
          .where('userId', isEqualTo: userId)
          .where('dayKey', isGreaterThanOrEqualTo: startDayKey)
          .where('dayKey', isLessThanOrEqualTo: endDayKey)
          .orderBy('dayKey', descending: true)
          .orderBy('timestamp', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => WaterEntryModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Error fetching water entries for range: $e');
    }
  }

  // Get daily total for a specific day
  Future<double> getDailyTotal({
    required String userId,
    required String dayKey,
  }) async {
    try {
      final statsDoc = await _firestore
          .collection(AppConstants.dailyStatsCollection)
          .doc(userId)
          .collection('stats')
          .doc(dayKey)
          .get();

      if (statsDoc.exists) {
        return (statsDoc.data()!['totalAmount'] as num?)?.toDouble() ?? 0.0;
      }

      // If stats don't exist, calculate from entries
      final entries = await getWaterEntriesForDay(userId: userId, dayKey: dayKey);
      double total = 0.0;
      for (final entry in entries) {
        total += entry.amount;
      }
      return total;
    } catch (e) {
      throw Exception('Error fetching daily total: $e');
    }
  }

  // Get daily stats
  Future<DailyStatsModel?> getDailyStats({
    required String userId,
    required String dayKey,
  }) async {
    try {
      final statsDoc = await _firestore
          .collection(AppConstants.dailyStatsCollection)
          .doc(userId)
          .collection('stats')
          .doc(dayKey)
          .get();

      if (statsDoc.exists) {
        return DailyStatsModel.fromMap(statsDoc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching daily stats: $e');
    }
  }

  // Stream of water entries for a specific day
  Stream<List<WaterEntryModel>> streamWaterEntriesForDay({
    required String userId,
    required String dayKey,
  }) {
    return _firestore
        .collection(AppConstants.waterEntriesCollection)
        .where('userId', isEqualTo: userId)
        .where('dayKey', isEqualTo: dayKey)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => WaterEntryModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Stream of daily stats
  Stream<DailyStatsModel?> streamDailyStats({
    required String userId,
    required String dayKey,
  }) {
    return _firestore
        .collection(AppConstants.dailyStatsCollection)
        .doc(userId)
        .collection('stats')
        .doc(dayKey)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        return DailyStatsModel.fromMap(snapshot.data()!);
      }
      return null;
    });
  }

  // Clear all water-related data for a user (entries + daily stats)
  Future<void> clearUserData(String userId) async {
    try {
      final batch = _firestore.batch();

      // Delete all water entries for user
      final entriesSnap = await _firestore
          .collection(AppConstants.waterEntriesCollection)
          .where('userId', isEqualTo: userId)
          .get();
      for (final doc in entriesSnap.docs) {
        batch.delete(doc.reference);
      }

      // Delete all daily stats for user
      final statsSnap = await _firestore
          .collection(AppConstants.dailyStatsCollection)
          .doc(userId)
          .collection('stats')
          .get();
      for (final doc in statsSnap.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Error clearing user data: $e');
    }
  }

  // Update daily stats (transactional)
  Future<void> _updateDailyStats(
    String userId,
    String dayKey,
    double amount, {
    required bool increment,
  }) async {
    try {
      final statsRef = _firestore
          .collection(AppConstants.dailyStatsCollection)
          .doc(userId)
          .collection('stats')
          .doc(dayKey);

      await _firestore.runTransaction((transaction) async {
        final statsDoc = await transaction.get(statsRef);

        if (statsDoc.exists) {
          final currentTotal = (statsDoc.data()!['totalAmount'] as num?)?.toDouble() ?? 0.0;
          final currentCount = statsDoc.data()!['entryCount'] ?? 0;

          final newTotal = increment
              ? currentTotal + amount
              : (currentTotal - amount).clamp(0.0, double.infinity);
          final newCount = increment
              ? currentCount + 1
              : (currentCount - 1).clamp(0, 999999);

          transaction.update(statsRef, {
            'totalAmount': newTotal,
            'entryCount': newCount,
            'userId': userId,
            'date': dayKey,
          });
        } else {
          // Create new stats document
          transaction.set(statsRef, {
            'userId': userId,
            'date': dayKey,
            'totalAmount': increment ? amount : 0.0,
            'entryCount': increment ? 1 : 0,
            'goalAchieved': false,
          });
        }
      });
    } catch (e) {
      throw Exception('Error updating daily stats: $e');
    }
  }
}
