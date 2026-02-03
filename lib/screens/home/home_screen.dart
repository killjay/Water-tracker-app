import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/water_provider.dart';
import '../../widgets/progress_indicator.dart';
import '../../widgets/water_cup_widget.dart';
import '../../utils/constants.dart';
import '../../utils/date_utils.dart';
import '../../services/notification_service.dart';
import '../../services/analytics_service.dart';
import '../../models/water_entry_model.dart';
import '../settings/settings_screen.dart';
import '../history/history_screen.dart';
import '../stats/stats_screen.dart';
import '../../services/tuning_engine.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  int _currentIndex = 0;
  final GlobalKey<WaterProgressIndicatorState> _progressKey =
      GlobalKey<WaterProgressIndicatorState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeTimezone();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final waterProvider = Provider.of<WaterProvider>(context, listen: false);
    
    if (authProvider.currentUser != null) {
      await waterProvider.loadTodayData(authProvider.currentUser!.uid);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh when app resumes to handle day changes
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final waterProvider = Provider.of<WaterProvider>(context, listen: false);
      if (authProvider.currentUser != null) {
        waterProvider.refreshDay(authProvider.currentUser!.uid);
        waterProvider.loadTodayData(authProvider.currentUser!.uid);
      }
    }
  }

  Future<void> _initializeTimezone() async {
    await AppDateUtils.initialize();
  }

  Future<void> _addWater(double amount, {String? cupSize}) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final waterProvider = Provider.of<WaterProvider>(context, listen: false);

    if (authProvider.currentUser == null) return;

    // Capture totals before update for goal celebration check
    final beforeTotal = waterProvider.todayTotal;
    final userData = authProvider.userData;
    final goal = userData?.preferences.goal ?? 0.0;

    // Log analytics (non-blocking)
    AnalyticsService().logWaterEntryAdded(
      amount: amount,
      cupSize: cupSize,
    );

    // Use optimistic update for instant UI feedback
    final success = await waterProvider.addWaterEntryOptimistic(
      userId: authProvider.currentUser!.uid,
      amount: amount,
      cupSize: cupSize,
    );

    if (!mounted) return;

    // Trigger pulse animation immediately (UI already updated optimistically)
    _progressKey.currentState?.triggerPulse();

    // Check if goal just crossed for celebration & analytics
    final afterTotal = waterProvider.todayTotal;
    if (beforeTotal < goal && afterTotal >= goal) {
      _progressKey.currentState?.triggerCelebrate();
      AnalyticsService().logGoalAchieved(totalAmount: afterTotal);
    }

    if (success) {
      // Schedule next reminder with smart tuning (after successful sync)
      if (userData != null && userData.preferences.reminderEnabled) {
        await NotificationService().scheduleSmartReminder(
          totalConsumed: waterProvider.todayTotal,
          dailyGoal: userData.preferences.goal,
          smartTuningEnabled: userData.preferences.smartTuningEnabled,
          fixedIntervalMinutes: userData.preferences.reminderIntervalMinutes,
        );
      }

      // Show subtle success feedback (optional, since UI already updated)
      // Only show if user might not notice the change
    } else {
      // Show error and rollback already happened in provider
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            waterProvider.errorMessage ?? 'Failed to save. Please try again.',
          ),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: () => _addWater(amount, cupSize: cupSize),
          ),
        ),
      );
    }
  }

  Future<void> _showCustomAmountDialog() async {
    final amountController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Custom Amount'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Amount (ml)',
              prefixIcon: Icon(Icons.water_drop),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter an amount';
              }
              final amount = double.tryParse(value);
              if (amount == null || amount <= 0) {
                return 'Please enter a valid amount';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final amount = double.tryParse(amountController.text);
                if (amount != null) {
                  Navigator.pop(context, amount);
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (result != null) {
      await _addWater(result);
    }
  }

  Future<void> _showQuickAddSheet(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userData = authProvider.userData;
    final unit = userData?.preferences.unit ?? 'ml';

    final allCupSizes = <String, double>{
      ...AppConstants.standardCupSizes,
      if (userData != null)
        ...Map.fromEntries(
          userData.customCupSizes.map(
            (cup) => MapEntry(cup.name, cup.amount),
          ),
        ),
    };

    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Quick add water',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: allCupSizes.entries.map((e) {
                    return ActionChip(
                      label: Text('${e.key} · ${e.value.toStringAsFixed(0)} $unit'),
                      onPressed: () {
                        Navigator.pop(context);
                        _addWater(e.value, cupSize: e.key);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _showCustomAmountDialog();
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Custom amount'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHomeContent(BuildContext context) {
    return Consumer2<AuthProvider, WaterProvider>(
        builder: (context, authProvider, waterProvider, child) {
          if (authProvider.currentUser == null) {
            return const Center(child: Text('Please log in'));
          }

          final userData = authProvider.userData;
          if (userData == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final goal = userData.preferences.goal;
          final unit = userData.preferences.unit;
          final todayTotal = waterProvider.todayTotal;
          final progress = goal > 0 ? (todayTotal / goal).clamp(0.0, 1.0) : 0.0;

          // Smart reminder status
          final hoursRemaining = AppDateUtils.getHoursRemainingInDay();
          final useSmart = userData.preferences.smartTuningEnabled &&
              userData.preferences.reminderEnabled;
          final Duration nextInterval = useSmart
              ? TuningEngine.calculateNextReminderInterval(
                  totalConsumed: todayTotal,
                  hoursRemaining: hoursRemaining,
                  dailyGoal: goal,
                )
              : TuningEngine.getFixedReminderInterval(
                  userData.preferences.reminderIntervalMinutes,
                );

          String statusLabel;
          if (todayTotal >= goal) {
            statusLabel = 'Goal reached';
          } else {
            final expectedSoFar =
                goal * ((24 - hoursRemaining) / 24.0).clamp(0.0, 1.0);
            if (todayTotal + goal * 0.05 < expectedSoFar) {
              statusLabel = 'Behind pace';
            } else {
              statusLabel = 'On track';
            }
          }

          return RefreshIndicator(
            onRefresh: () async {
              if (authProvider.currentUser != null) {
                waterProvider.refreshDay(authProvider.currentUser!.uid);
                await waterProvider.loadTodayData(authProvider.currentUser!.uid);
              }
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 44, 20, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header with date, greeting, and settings
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppDateUtils.formatDate(DateTime.now(), 'EEEE, dd MMM').toUpperCase(),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: Color(0x99EBEBF5), // tertiary label
                                letterSpacing: -0.08,
                                fontFamily: 'Inter',
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Hello, ${userData.displayName ?? 'there'}',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFFFFFFF), // white
                                letterSpacing: 0.36,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.settings,
                          size: 22,
                          color: Color(0xFFFFFFFF),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SettingsScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Today's intake section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'TODAY\'S INTAKE',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0x99EBEBF5), // tertiary label
                          letterSpacing: -0.08,
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${todayTotal.toStringAsFixed(0)} / ${goal.toStringAsFixed(0)} $unit',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFFFFFFF), // white
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Progress bar (4px height, lime green)
                      Container(
                        height: 4,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          color: const Color(0xFF2C2C2E), // tertiary background
                        ),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(999),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 4,
                                backgroundColor: Colors.transparent,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Color(0xFFE2F163), // lime green
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Status card
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: const Color(0xFF1C1C1E), // secondary background
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Hydration Status',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFFFFFFF), // white
                                fontFamily: 'Inter',
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              statusLabel == 'Goal reached'
                                  ? 'Goal reached! 🎉'
                                  : statusLabel == 'Behind pace'
                                      ? 'You\'re behind pace'
                                      : 'You\'re on track!',
                              style: const TextStyle(
                                fontSize: 15,
                                color: Color(0xFFEBEBF5), // secondary label
                                fontFamily: 'Inter',
                              ),
                            ),
                          ],
                        ),
                        const Divider(
                          color: Color(0xFF38383A), // separator
                          thickness: 1,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.access_time,
                                    size: 14,
                                    color: Color(0xFFEBEBF5), // secondary label
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Next reminder: ${DateTime.now().add(nextInterval).hour}:${DateTime.now().add(nextInterval).minute.toString().padLeft(2, '0')}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFFEBEBF5), // secondary label
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF896CFE), // purple accent
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: const Text(
                                  'ACTIVE',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFFFFFFF),
                                    letterSpacing: 0.5,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Latest log section
                  if (waterProvider.todayEntries.isNotEmpty)
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: const Color(0xFF1C1C1E), // secondary background
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Latest Log',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFFFFFFF), // white
                              fontFamily: 'Inter',
                            ),
                          ),
                          const SizedBox(height: 12),
                          Builder(
                            builder: (context) {
                              // Get the latest entry
                              final latestEntry = waterProvider.todayEntries
                                  .reduce((a, b) => a.timestamp.isAfter(b.timestamp) ? a : b);
                              
                              final timeStr = '${latestEntry.timestamp.hour.toString().padLeft(2, '0')}:${latestEntry.timestamp.minute.toString().padLeft(2, '0')}';
                              
                              return Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF2C2C2E), // tertiary background
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.water_drop,
                                      size: 20,
                                      color: Color(0xFF896CFE), // purple accent
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${latestEntry.amount.toStringAsFixed(0)} $unit',
                                          style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFFFFFFFF), // white
                                            fontFamily: 'Inter',
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Row(
                                          children: [
                                            Text(
                                              timeStr,
                                              style: const TextStyle(
                                                fontSize: 13,
                                                color: Color(0xFFEBEBF5), // secondary label
                                                fontFamily: 'Inter',
                                              ),
                                            ),
                                            if (latestEntry.cupSize != null) ...[
                                              const Text(
                                                ' • ',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Color(0xFFEBEBF5),
                                                  fontFamily: 'Inter',
                                                ),
                                              ),
                                              Text(
                                                latestEntry.cupSize!,
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  color: Color(0xFFEBEBF5), // secondary label
                                                  fontFamily: 'Inter',
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null, // No app bar, using custom header
      body: _currentIndex == 0
          ? _buildHomeContent(context)
          : _currentIndex == 1
              ? const HistoryScreen()
              : const StatsScreen(),
      floatingActionButton: _currentIndex == 0
          ? Padding(
              padding: const EdgeInsets.only(right: 20, bottom: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF896CFE), // purple accent
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      _showQuickAddSheet(context);
                    },
                    borderRadius: BorderRadius.circular(999),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.add,
                            color: Color(0xFFFFFFFF),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Add Water',
                            style: TextStyle(
                              color: Color(0xFFFFFFFF),
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1C1C1E), // dark background
          border: Border(
            top: BorderSide(
              color: Color(0xFF38383A), // separator
              width: 1,
            ),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              icon: Icons.home,
              label: 'Home',
              isSelected: _currentIndex == 0,
              onTap: () {
                setState(() => _currentIndex = 0);
                AnalyticsService().logScreenView('home');
              },
            ),
            _buildNavItem(
              icon: Icons.history,
              label: 'History',
              isSelected: _currentIndex == 1,
              onTap: () {
                setState(() => _currentIndex = 1);
                AnalyticsService().logScreenView('logs');
              },
            ),
            _buildNavItem(
              icon: Icons.bar_chart,
              label: 'Stats',
              isSelected: _currentIndex == 2,
              onTap: () {
                setState(() => _currentIndex = 2);
                AnalyticsService().logScreenView('stats');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 113,
        height: 46,
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFE2F163) // lime green when selected
              : const Color(0xFF1C1C1E), // dark background
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected
                  ? const Color(0xFF000000) // black icon when selected
                  : const Color(0xFFFFFFFF), // white icon when not selected
            ),
            const SizedBox(height: 1),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isSelected
                    ? const Color(0xFF000000)
                    : const Color(0xFFFFFFFF),
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(WaterEntryModel entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: const Text('Are you sure you want to delete this entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final authProvider =
                  Provider.of<AuthProvider>(context, listen: false);
              final waterProvider =
                  Provider.of<WaterProvider>(context, listen: false);

              if (authProvider.currentUser == null) return;

              // Log analytics
              await AnalyticsService().logWaterEntryDeleted();

              final success = await waterProvider.deleteWaterEntry(
                userId: authProvider.currentUser!.uid,
                entryId: entry.id,
                amount: entry.amount,
                dayKey: entry.dayKey,
              );

              if (!mounted) return;

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Entry deleted'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      waterProvider.errorMessage ?? 'Failed to delete entry',
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

}
