import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/analytics_service.dart';

class GoalSetupScreen extends StatefulWidget {
  const GoalSetupScreen({super.key});

  @override
  State<GoalSetupScreen> createState() => _GoalSetupScreenState();
}

class _GoalSetupScreenState extends State<GoalSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _goalController = TextEditingController();
  String _selectedUnit = 'ml';

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userData = authProvider.userData;
    if (userData != null) {
      _goalController.text = userData.preferences.goal.toStringAsFixed(0);
      _selectedUnit = userData.preferences.unit;
    }
  }

  @override
  void dispose() {
    _goalController.dispose();
    super.dispose();
  }

  Future<void> _saveGoal() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final goal = double.tryParse(_goalController.text);
    if (goal == null || goal <= 0) {
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userData = authProvider.userData;
    if (userData == null) return;

    final updatedPreferences = userData.preferences.copyWith(
      goal: goal,
      unit: _selectedUnit,
    );

    final success = await authProvider.updateUserPreferences(updatedPreferences);

    if (!mounted) return;

    if (success) {
      // Log analytics
      await AnalyticsService().logGoalUpdated(newGoal: goal);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Goal updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Failed to update goal'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Daily Goal'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Daily Water Goal',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Set your daily water intake target',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF896CFE), // purple accent
              ),
            ),
            const SizedBox(height: 32),

            // Goal input
            TextFormField(
              controller: _goalController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Goal Amount',
                prefixIcon: Icon(Icons.flag),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a goal amount';
                }
                final goal = double.tryParse(value);
                if (goal == null || goal <= 0) {
                  return 'Please enter a valid amount';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Unit selector
            const Text(
              'Unit',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'ml', label: Text('ml')),
                ButtonSegment(value: 'oz', label: Text('oz')),
                ButtonSegment(value: 'cups', label: Text('cups')),
              ],
              selected: {_selectedUnit},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() {
                  _selectedUnit = newSelection.first;
                });
              },
            ),
            const SizedBox(height: 32),

            // Save button
            ElevatedButton(
              onPressed: _saveGoal,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Save Goal'),
            ),
          ],
        ),
      ),
    );
  }
}
