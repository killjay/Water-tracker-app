import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/water_service.dart';
import '../../models/daily_stats_model.dart';
import '../../utils/date_utils.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final WaterService _waterService = WaterService();
  bool _isLoading = false;
  List<DailyStatsModel> _last7Days = [];

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.currentUser?.uid;
    if (userId == null) {
      print('[StatsScreen] No userId found, cannot load stats');
      return;
    }

    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final now = DateTime.now();
      final List<DailyStatsModel> stats = [];

      for (int i = 6; i >= 0; i--) {
        final day = now.subtract(Duration(days: i));
        final dayKey = AppDateUtils.generateDayKey(day);
        final stat = await _waterService.getDailyStats(
          userId: userId,
          dayKey: dayKey,
        );
        stats.add(
          DailyStatsModel(
            userId: userId,
            date: dayKey,
            totalAmount: stat?.totalAmount ?? 0,
            entryCount: stat?.entryCount ?? 0,
            goalAchieved: stat?.goalAchieved ?? false,
          ),
        );
      }

      print('[StatsScreen] Loaded ${stats.length} days of stats');
      
      if (mounted) {
        setState(() {
          _last7Days = stats;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('[StatsScreen] Error loading stats: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print('[StatsScreen] Building with _isLoading=$_isLoading, _last7Days.length=${_last7Days.length}');
    
    final authProvider = Provider.of<AuthProvider>(context);
    final userData = authProvider.userData;
    final goal = userData?.preferences.goal ?? 2000.0;
    final unit = userData?.preferences.unit ?? 'ml';

    final completedDays =
        _last7Days.where((d) => d.totalAmount >= goal).length.toDouble();
    final completionRate =
        _last7Days.isEmpty ? 0.0 : (completedDays / _last7Days.length);

    int currentStreak = 0;
    for (int i = _last7Days.length - 1; i >= 0; i--) {
      if (_last7Days[i].totalAmount >= goal) {
        currentStreak++;
      } else {
        break;
      }
    }

    print('[StatsScreen] Calculated: streak=$currentStreak, rate=$completionRate');

    return Scaffold(
      backgroundColor: const Color(0xFF000000), // black background
      appBar: AppBar(
        title: const Text(
          'Stats',
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
      body: RefreshIndicator(
        onRefresh: _loadStats,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Metrics grid
                  IntrinsicHeight(
                    child: Row(
                      children: [
                        Expanded(
                          child: _MetricCard(
                            label: 'Current Streak',
                            value: '$currentStreak days',
                            icon: Icons.local_fire_department,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _MetricCard(
                            label: 'Completion Rate',
                            value: '${(completionRate * 100).toStringAsFixed(0)}%',
                            icon: Icons.check_circle,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'Last 7 days',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFFFFFFF), // white
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 12),

                  SizedBox(
                    height: 200,
                    child: _WeeklyLineChart(
                      stats: _last7Days,
                      goal: goal,
                      unit: unit,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1C1C1E), // iOS secondary background
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF38383A), width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: const Color(0xFF896CFE), // purple accent
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xFFFFFFFF), // white
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFFEBEBF5), // iOS secondary label
                fontSize: 13,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeeklyLineChart extends StatelessWidget {
  final List<DailyStatsModel> stats;
  final double goal;
  final String unit;

  const _WeeklyLineChart({
    required this.stats,
    required this.goal,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    if (stats.isEmpty) {
      return Center(
        child: Text(
          'No data yet',
          style: const TextStyle(
            color: Color(0xFFEBEBF5), // iOS secondary label
          ),
        ),
      );
    }

    final maxAmount = stats.map((s) => s.totalAmount).fold<double>(
        goal > 0 ? goal : 2000.0, (a, b) => a > b ? a : b);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Y-axis labels
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _YAxisLabel('${maxAmount.toInt()}'),
              _YAxisLabel('${(maxAmount * 0.75).toInt()}'),
              _YAxisLabel('${(maxAmount * 0.5).toInt()}'),
              _YAxisLabel('${(maxAmount * 0.25).toInt()}'),
              _YAxisLabel('0'),
            ],
          ),
          const SizedBox(width: 8),
          // Chart area
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: CustomPaint(
                    painter: _LineChartPainter(
                      stats: stats,
                      maxAmount: maxAmount,
                    ),
                    child: Container(),
                  ),
                ),
                const SizedBox(height: 8),
                // X-axis labels
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: stats.map((stat) {
                    final date = _parseDateKey(stat.date);
                    return Text(
                      _shortWeekday(date),
                      style: const TextStyle(
                        fontSize: 8,
                        color: Color(0xFF585858),
                        fontFamily: 'Inter',
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  DateTime _parseDateKey(String dayKey) {
    final parts = dayKey.split('-');
    if (parts.length != 3) return DateTime.now();
    final year = int.tryParse(parts[0]) ?? DateTime.now().year;
    final month = int.tryParse(parts[1]) ?? DateTime.now().month;
    final day = int.tryParse(parts[2]) ?? DateTime.now().day;
    return DateTime(year, month, day);
  }

  String _shortWeekday(DateTime date) {
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final index = date.weekday - 1;
    if (index < 0 || index >= labels.length) return '';
    return labels[index];
  }
}

class _YAxisLabel extends StatelessWidget {
  final String label;

  const _YAxisLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      '$label mL',
      style: const TextStyle(
        fontSize: 8,
        color: Color(0xFF585858),
        fontFamily: 'Inter',
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<DailyStatsModel> stats;
  final double maxAmount;

  _LineChartPainter({
    required this.stats,
    required this.maxAmount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (stats.isEmpty) return;

    // Grid lines paint (horizontal and vertical)
    final gridPaint = Paint()
      ..color = const Color(0x1AFFFFFF) // #ffffff1a
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw horizontal grid lines
    for (int i = 0; i <= 4; i++) {
      final y = (size.height / 4) * i;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    // Draw vertical grid lines
    final spacing = size.width / (stats.length - 1);
    for (int i = 0; i < stats.length; i++) {
      final x = i * spacing;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        gridPaint,
      );
    }

    // Calculate data points
    final points = <Offset>[];
    for (int i = 0; i < stats.length; i++) {
      final x = i * spacing;
      final normalizedValue = maxAmount == 0 ? 0.0 : stats[i].totalAmount / maxAmount;
      final y = size.height - (normalizedValue * size.height);
      points.add(Offset(x, y.clamp(0.0, size.height)));
    }

    // Draw line connecting points
    if (points.length > 1) {
      final linePaint = Paint()
        ..color = const Color(0xFFE2F163) // lime green
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final path = Path();
      path.moveTo(points[0].dx, points[0].dy);
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
      canvas.drawPath(path, linePaint);
    }

    // Draw circular dots at each data point
    final dotPaint = Paint()
      ..color = const Color(0xFF000000) // black fill
      ..style = PaintingStyle.fill;

    final dotBorderPaint = Paint()
      ..color = const Color(0xFFE2F163) // lime green border
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    for (final point in points) {
      // Draw filled circle
      canvas.drawCircle(point, 3.5, dotPaint);
      // Draw border
      canvas.drawCircle(point, 3.5, dotBorderPaint);
    }
  }  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
