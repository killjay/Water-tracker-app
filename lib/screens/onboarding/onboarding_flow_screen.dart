import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import '../../utils/goal_calculator.dart';

class OnboardingFlowScreen extends StatefulWidget {
  const OnboardingFlowScreen({super.key});

  @override
  State<OnboardingFlowScreen> createState() => _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends State<OnboardingFlowScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  double? _weightKg;
  String _activityLevel = 'medium';
  TimeOfDay _wakeTime = const TimeOfDay(hour: 7, minute: 0);
  TimeOfDay _sleepTime = const TimeOfDay(hour: 23, minute: 0);

  final _weightFormKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _pickTime({
    required bool isWake,
  }) async {
    final initial = isWake ? _wakeTime : _sleepTime;
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
    );
    if (picked != null) {
      setState(() {
        if (isWake) {
          _wakeTime = picked;
        } else {
          _sleepTime = picked;
        }
      });
    }
  }

  void _next() {
    if (_currentPage == 0) {
      if (!_weightFormKey.currentState!.validate()) {
        return;
      }
      _weightFormKey.currentState!.save();
    }
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
    }
  }

  void _back() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
    }
  }

  int _timeOfDayToMinutes(TimeOfDay time) => time.hour * 60 + time.minute;

  Future<void> _completeOnboarding() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.userData;
    if (user == null || _weightKg == null) return;

    final wakeMinutes = _timeOfDayToMinutes(_wakeTime);
    final sleepMinutes = _timeOfDayToMinutes(_sleepTime);

    final goalMl = GoalCalculator.calculateGoal(
      weightKg: _weightKg!,
      activityLevel: _activityLevel,
      wakeTimeMinutes: wakeMinutes,
      sleepTimeMinutes: sleepMinutes,
    );

    final newPrefs = user.preferences.copyWith(
      goal: goalMl,
      unit: 'ml',
      weightKg: _weightKg,
      activityLevel: _activityLevel,
      wakeTimeMinutes: wakeMinutes,
      sleepTimeMinutes: sleepMinutes,
      hasCompletedOnboarding: true,
    );

    final success = await authProvider.updateUserPreferences(newPrefs);
    if (!mounted) return;

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Failed to save profile'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Navigate to dashboard/home; AuthWrapper will now send user there
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildWeightPage(),
      _buildActivityPage(),
      _buildSleepPage(),
      _buildSummaryPage(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF000000), // black background
      appBar: AppBar(
        title: const Text(
          'Let\'s personalise',
          style: TextStyle(
            color: Color(0xFFFFFFFF), // white
            fontWeight: FontWeight.w700,
            fontSize: 34,
            fontFamily: 'Inter',
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: _currentPage > 0,
        leading: _currentPage > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFFFFFFFF)),
                onPressed: _back,
              )
            : null,
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          _buildStepIndicator(),
          const SizedBox(height: 16),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: pages.length,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.all(24.0),
                child: pages[index],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed:
                _currentPage == pages.length - 1 ? _completeOnboarding : _next,
            child: Text(_currentPage == pages.length - 1 ? 'Finish' : 'Next'),
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    const total = 4;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        total,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index <= _currentPage
                ? const Color(0xFF896CFE) // purple accent
                : const Color(0xFF38383A), // separator
          ),
        ),
      ),
    );
  }

  Widget _buildWeightPage() {
    return Form(
      key: _weightFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Your weight',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFFFFFFFF), // white
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'We use this to estimate a healthy hydration target.',
            style: TextStyle(
              color: Color(0xFFEBEBF5), // secondary label
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 24),
          TextFormField(
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Weight (kg)',
              prefixIcon: Icon(Icons.monitor_weight),
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your weight';
              }
              final v = double.tryParse(value);
              if (v == null || v <= 0) {
                return 'Please enter a valid weight';
              }
              return null;
            },
            onSaved: (value) {
              _weightKg = double.tryParse(value ?? '');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActivityPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Activity level',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Color(0xFFFFFFFF), // white
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'On most days, how active are you?',
          style: TextStyle(
            color: Color(0xFFEBEBF5), // secondary label
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 24),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(
              value: 'low',
              label: Text('Low'),
              icon: Icon(Icons.self_improvement),
            ),
            ButtonSegment(
              value: 'medium',
              label: Text('Normal'),
              icon: Icon(Icons.directions_walk),
            ),
            ButtonSegment(
              value: 'high',
              label: Text('High'),
              icon: Icon(Icons.fitness_center),
            ),
          ],
          selected: {_activityLevel},
          onSelectionChanged: (set) {
            setState(() {
              _activityLevel = set.first;
            });
          },
        ),
      ],
    );
  }

  Widget _buildSleepPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Sleep schedule',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Color(0xFFFFFFFF), // white
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'We time reminders between your wake and sleep window.',
          style: TextStyle(
            color: Color(0xFFEBEBF5), // secondary label
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 24),
        ListTile(
          leading: const Icon(Icons.wb_sunny),
          title: const Text('Wake time'),
          subtitle: Text(_wakeTime.format(context)),
          onTap: () => _pickTime(isWake: true),
        ),
        ListTile(
          leading: const Icon(Icons.nightlight_round),
          title: const Text('Sleep time'),
          subtitle: Text(_sleepTime.format(context)),
          onTap: () => _pickTime(isWake: false),
        ),
      ],
    );
  }

  Widget _buildSummaryPage() {
    final weight = _weightKg ?? 70;
    final wakeMinutes = _timeOfDayToMinutes(_wakeTime);
    final sleepMinutes = _timeOfDayToMinutes(_sleepTime);
    final previewGoal = GoalCalculator.calculateGoal(
      weightKg: weight,
      activityLevel: _activityLevel,
      wakeTimeMinutes: wakeMinutes,
      sleepTimeMinutes: sleepMinutes,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Your daily goal',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Color(0xFFFFFFFF), // white
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Here\'s a personalised target based on your profile.',
          style: TextStyle(
            color: Color(0xFFEBEBF5), // secondary label
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 32),
        Center(
          child: Column(
            children: [
              Text(
                '${previewGoal.toStringAsFixed(0)} ml',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFFFFFFF), // white
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Weight: ${weight.toStringAsFixed(1)} kg · Activity: ${_activityLevel.toUpperCase()}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFFEBEBF5), // secondary label
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Wake: ${_wakeTime.format(context)} · Sleep: ${_sleepTime.format(context)}',
                style: const TextStyle(
                  color: Color(0xFFEBEBF5), // secondary label
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

