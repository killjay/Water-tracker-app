import 'package:flutter/foundation.dart';
import '../services/water_service.dart';
import '../models/water_entry_model.dart';
import '../models/daily_stats_model.dart';
import '../utils/date_utils.dart';

class WaterProvider with ChangeNotifier {
  final WaterService _waterService = WaterService();
  
  String? _currentDayKey;
  List<WaterEntryModel> _todayEntries = [];
  DailyStatsModel? _todayStats;
  double _todayTotal = 0.0;
  bool _isLoading = false;
  String? _errorMessage;
  
  // Optimistic update tracking
  final Map<String, WaterEntryModel> _pendingOptimisticEntries = {};
  final Set<String> _pendingOptimisticDeletes = {};
  DateTime? _lastOptimisticUpdate;

  String? get currentDayKey => _currentDayKey;
  List<WaterEntryModel> get todayEntries => _todayEntries;
  DailyStatsModel? get todayStats => _todayStats;
  double get todayTotal => _todayTotal;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  WaterProvider() {
    _initialize();
  }

  void _initialize() {
    _currentDayKey = AppDateUtils.generateDayKey();
  }

  // Refresh day key and reload data (useful when day changes)
  void refreshDay([String? userId]) {
    final newDayKey = AppDateUtils.generateDayKey();
    if (newDayKey != _currentDayKey) {
      _currentDayKey = newDayKey;
      if (userId != null) {
        loadTodayData(userId);
      }
    }
  }

  // Load today's data
  Future<void> loadTodayData(String userId) async {
    if (_currentDayKey == null) {
      _currentDayKey = AppDateUtils.generateDayKey();
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Load entries and stats
      final entries = await _waterService.getWaterEntriesForDay(
        userId: userId,
        dayKey: _currentDayKey!,
      );
      
      final stats = await _waterService.getDailyStats(
        userId: userId,
        dayKey: _currentDayKey!,
      );

      _todayEntries = entries;
      _todayStats = stats;
      _todayTotal = stats?.totalAmount ?? 
          entries.fold(0.0, (sum, entry) => sum + entry.amount);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  // Add water entry
  Future<bool> addWaterEntry({
    required String userId,
    required double amount,
    String? cupSize,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Generate dayKey to ensure we're using current day
      final dayKey = AppDateUtils.generateDayKey();
      if (dayKey != _currentDayKey) {
        _currentDayKey = dayKey;
      }

      await _waterService.addWaterEntry(
        userId: userId,
        amount: amount,
        cupSize: cupSize,
      );
      // Reload today's data
      await loadTodayData(userId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete water entry
  Future<bool> deleteWaterEntry({
    required String userId,
    required String entryId,
    required double amount,
    required String dayKey,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _waterService.deleteWaterEntry(
        userId: userId,
        entryId: entryId,
        amount: amount,
        dayKey: dayKey,
      );

      // Reload today's data
      await loadTodayData(userId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Stream today's entries
  Stream<List<WaterEntryModel>> streamTodayEntries(String userId) {
    final dayKey = AppDateUtils.generateDayKey();
    return _waterService.streamWaterEntriesForDay(
      userId: userId,
      dayKey: dayKey,
    );
  }

  // Stream today's stats
  Stream<DailyStatsModel?> streamTodayStats(String userId) {
    final dayKey = AppDateUtils.generateDayKey();
    return _waterService.streamDailyStats(
      userId: userId,
      dayKey: dayKey,
    );
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Optimistic add water entry - updates UI instantly, syncs in background
  Future<bool> addWaterEntryOptimistic({
    required String userId,
    required double amount,
    String? cupSize,
  }) async {
    // Generate dayKey to ensure we're using current day
    final dayKey = AppDateUtils.generateDayKey();
    if (dayKey != _currentDayKey) {
      _currentDayKey = dayKey;
    }

    // Create optimistic entry with temporary ID
    final tempId = 'optimistic_${DateTime.now().millisecondsSinceEpoch}';
    final optimisticEntry = WaterEntryModel(
      id: tempId,
      userId: userId,
      timestamp: DateTime.now(),
      amount: amount,
      cupSize: cupSize,
      dayKey: dayKey,
    );

    // Snapshot current state for rollback
    final snapshot = _StateSnapshot(
      entries: List.from(_todayEntries),
      stats: _todayStats?.copyWith(),
      total: _todayTotal,
    );

    // Optimistically update state immediately
    _todayEntries = [..._todayEntries, optimisticEntry];
    _todayTotal += amount;
    _todayStats = _todayStats?.copyWith(
      totalAmount: (_todayStats!.totalAmount + amount),
      entryCount: _todayStats!.entryCount + 1,
      goalAchieved: false, // Will be recalculated by service
    ) ?? DailyStatsModel(
      userId: userId,
      date: dayKey,
      totalAmount: amount,
      entryCount: 1,
      goalAchieved: false,
    );
    _pendingOptimisticEntries[tempId] = optimisticEntry;
    _lastOptimisticUpdate = DateTime.now();
    _errorMessage = null;
    notifyListeners();

    // Sync to Firestore in background
    try {
      await _waterService.addWaterEntry(
        userId: userId,
        amount: amount,
        cupSize: cupSize,
      );
      
      // Success: Remove from pending, reload to get real entry ID
      _pendingOptimisticEntries.remove(tempId);
      await loadTodayData(userId);
      return true;
    } catch (e) {
      // Failure: Rollback to snapshot
      _todayEntries = snapshot.entries;
      _todayStats = snapshot.stats;
      _todayTotal = snapshot.total;
      _pendingOptimisticEntries.remove(tempId);
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Optimistic delete water entry - updates UI instantly, syncs in background
  Future<bool> deleteWaterEntryOptimistic({
    required String userId,
    required String entryId,
    required double amount,
    required String dayKey,
  }) async {
    // Find the entry to delete
    final entryIndex = _todayEntries.indexWhere((e) => e.id == entryId);
    if (entryIndex == -1) {
      // Entry not found, might already be deleted
      return false;
    }

    final entryToDelete = _todayEntries[entryIndex];

    // Snapshot current state for rollback
    final snapshot = _StateSnapshot(
      entries: List.from(_todayEntries),
      stats: _todayStats?.copyWith(),
      total: _todayTotal,
    );

    // Optimistically update state immediately
    _todayEntries.removeAt(entryIndex);
    _todayTotal = (_todayTotal - amount).clamp(0.0, double.infinity);
    _todayStats = _todayStats?.copyWith(
      totalAmount: (_todayStats!.totalAmount - amount).clamp(0.0, double.infinity),
      entryCount: (_todayStats!.entryCount - 1).clamp(0, double.infinity.toInt()),
    );
    _pendingOptimisticDeletes.add(entryId);
    _lastOptimisticUpdate = DateTime.now();
    _errorMessage = null;
    notifyListeners();

    // Sync to Firestore in background
    try {
      await _waterService.deleteWaterEntry(
        userId: userId,
        entryId: entryId,
        amount: amount,
        dayKey: dayKey,
      );
      
      // Success: Remove from pending, reload to ensure consistency
      _pendingOptimisticDeletes.remove(entryId);
      await loadTodayData(userId);
      return true;
    } catch (e) {
      // Failure: Rollback to snapshot
      _todayEntries = snapshot.entries;
      _todayStats = snapshot.stats;
      _todayTotal = snapshot.total;
      _pendingOptimisticDeletes.remove(entryId);
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Check if we should ignore stream updates (to prevent conflicts with optimistic updates)
  bool _shouldIgnoreStreamUpdate() {
    if (_lastOptimisticUpdate == null) return false;
    final timeSinceUpdate = DateTime.now().difference(_lastOptimisticUpdate!);
    // Ignore stream updates for 2 seconds after optimistic update
    return timeSinceUpdate.inSeconds < 2;
  }

  // Merge stream entry with optimistic state (prevent duplicates)
  List<WaterEntryModel> _mergeStreamEntries(List<WaterEntryModel> streamEntries) {
    if (!_shouldIgnoreStreamUpdate() && _pendingOptimisticEntries.isEmpty) {
      return streamEntries;
    }

    // Start with stream entries (real data from Firestore)
    final merged = List<WaterEntryModel>.from(streamEntries);
    
    // Add pending optimistic entries that aren't in stream yet
    for (final optimisticEntry in _pendingOptimisticEntries.values) {
      // Check if a similar entry already exists (match by timestamp + amount)
      final exists = merged.any((e) =>
          e.timestamp.difference(optimisticEntry.timestamp).inSeconds.abs() < 5 &&
          (e.amount - optimisticEntry.amount).abs() < 0.1);
      
      if (!exists) {
        merged.add(optimisticEntry);
      }
    }

    // Remove entries that are pending delete
    merged.removeWhere((e) => _pendingOptimisticDeletes.contains(e.id));

    return merged;
  }
}

// Helper class for state snapshots
class _StateSnapshot {
  final List<WaterEntryModel> entries;
  final DailyStatsModel? stats;
  final double total;

  _StateSnapshot({
    required this.entries,
    required this.stats,
    required this.total,
  });
}
