import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/water_provider.dart';
import '../../services/water_service.dart';
import '../../models/water_entry_model.dart';
import '../../utils/date_utils.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  DateTime _selectedDate = DateTime.now();
  final WaterService _waterService = WaterService();
  List<WaterEntryModel> _entries = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final dayKey = AppDateUtils.generateDayKey(_selectedDate);
      final entries = await _waterService.getWaterEntriesForDay(
        userId: authProvider.currentUser!.uid,
        dayKey: dayKey,
      );

      setState(() {
        _entries = entries;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading entries: $e')),
        );
      }
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadEntries();
    }
  }

  double _calculateTotal() {
    return _entries.fold(0.0, (sum, entry) => sum + entry.amount);
  }

  Future<void> _deleteEntry(WaterEntryModel entry) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final waterProvider = Provider.of<WaterProvider>(context, listen: false);
    final userId = authProvider.currentUser?.uid;
    if (userId == null) return;

    final dayKey = AppDateUtils.generateDayKey(_selectedDate);

    // Optimistically remove from local list immediately for instant UI feedback
    setState(() {
      _entries.removeWhere((e) => e.id == entry.id);
    });

    // Use optimistic delete to keep daily stats and dashboard in sync
    final success = await waterProvider.deleteWaterEntryOptimistic(
      userId: userId,
      entryId: entry.id,
      amount: entry.amount,
      dayKey: dayKey,
    );

    if (!mounted) return;

    if (!success) {
      // Rollback: reload entries to restore the deleted one
      await _loadEntries();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            waterProvider.errorMessage ?? 'Failed to delete. Please try again.',
          ),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: () => _deleteEntry(entry),
          ),
        ),
      );
      return;
    }

    // Success: Reload to ensure consistency with Firestore
    await _loadEntries();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userData = authProvider.userData;
    final unit = userData?.preferences.unit ?? 'ml';
    final total = _calculateTotal();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'History',
          style: TextStyle(
            color: Color(0xFFFFFFFF), // white
            fontWeight: FontWeight.w700,
            fontSize: 34,
            fontFamily: 'Inter',
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFFFFFFFF)),
      ),
      body: Column(
        children: [
          // Date selector
          Card(
            margin: const EdgeInsets.all(16),
            child: ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text(
                AppDateUtils.formatDate(_selectedDate),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: _selectDate,
            ),
          ),

          // Summary card
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(
                        '${total.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '$unit Total',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF896CFE), // purple accent
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        '${_entries.length}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Entries',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF896CFE), // purple accent
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Entries list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _entries.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.water_drop_outlined,
                              size: 64,
                              color: const Color(0xFF896CFE).withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No entries for this day',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF896CFE), // purple accent
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _entries.length,
                        itemBuilder: (context, index) {
                          final entry = _entries[index];
                          return Dismissible(
                            key: Key(entry.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              color: Colors.red,
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                            confirmDismiss: (direction) async {
                              return await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Delete entry'),
                                      content: const Text(
                                          'Are you sure you want to delete this log?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text('Cancel'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                          ),
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    ),
                                  ) ??
                                  false;
                            },
                            onDismissed: (direction) async {
                              await _deleteEntry(entry);
                            },
                            child: Card(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 4,
                              ),
                              child: ListTile(
                                leading: const Icon(
                                  Icons.water_drop,
                                  color: Color(0xFF896CFE), // purple accent
                                ),
                                title: Text(
                                  '${entry.amount.toStringAsFixed(0)} $unit',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  entry.cupSize ?? 'Custom amount',
                                ),
                                trailing: Text(
                                  AppDateUtils.formatTime(entry.timestamp),
                                  style: const TextStyle(
                                    color: Color(0xFF896CFE), // purple accent
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
