import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/notification_service.dart';
import '../../services/water_service.dart';
import '../../utils/constants.dart';
import '../../screens/goal/goal_setup_screen.dart';
import '../../screens/onboarding/onboarding_flow_screen.dart';
import '../../models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _reminderEnabled = true;
  bool _smartTuningEnabled = true;
  int _reminderInterval = 60;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _reminderEnabled =
          prefs.getBool(AppConstants.reminderEnabledKey) ?? true;
      _smartTuningEnabled =
          prefs.getBool(AppConstants.smartTuningEnabledKey) ?? true;
      _reminderInterval =
          prefs.getInt(AppConstants.reminderIntervalKey) ?? 60;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userData = authProvider.userData;

    return Scaffold(
      backgroundColor: const Color(0xFF000000), // black background
      appBar: AppBar(
        title: const Text(
          'Settings',
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // User Profile Card
          if (userData != null) _buildUserProfileCard(userData),
          if (userData != null) const SizedBox(height: 24),

          // Profile Settings Section
          _buildSectionCard(
            title: 'Profile',
            children: [
              _buildListTile(
                icon: Icons.flag,
                iconColor: const Color(0xFF896CFE), // purple accent
                title: 'Daily Goal',
                subtitle: '${userData?.preferences.goal.toStringAsFixed(0) ?? 'Not set'} ${userData?.preferences.unit ?? 'ml'}',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GoalSetupScreen(),
                    ),
                  );
                },
              ),
              _buildListTile(
                icon: Icons.tune,
                iconColor: const Color(0xFF896CFE), // purple accent
                title: 'Hydration Profile',
                subtitle: 'Weight, activity level, sleep schedule',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const OnboardingFlowScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Reminders Section
          _buildSectionCard(
            title: 'Reminders',
            children: [
              _buildSwitchTile(
                icon: Icons.notifications,
                iconColor: const Color(0xFF896CFE), // purple accent
                title: 'Enable Reminders',
                subtitle: 'Get reminders to drink water',
                value: _reminderEnabled,
                onChanged: (value) async {
                  setState(() {
                    _reminderEnabled = value;
                  });
                  await NotificationService().setNotificationsEnabled(value);
                },
              ),
              _buildSwitchTile(
                icon: Icons.auto_awesome,
                iconColor: const Color(0xFF896CFE), // purple accent
                title: 'Smart Tuning',
                subtitle: 'Automatically adjust reminder intervals based on your progress',
                value: _smartTuningEnabled,
                onChanged: (value) async {
                  setState(() {
                    _smartTuningEnabled = value;
                  });
                  await NotificationService().setSmartTuningEnabled(value);
                },
              ),
              if (!_smartTuningEnabled)
                _buildListTile(
                  icon: Icons.timer,
                  iconColor: const Color(0xFF896CFE), // purple accent
                  title: 'Reminder Interval',
                  subtitle: '$_reminderInterval minutes',
                  onTap: () {
                    _showIntervalDialog();
                  },
                ),
            ],
          ),
          const SizedBox(height: 24),

          // Data & Privacy Section
          _buildSectionCard(
            title: 'Data & Privacy',
            children: [
              _buildListTile(
                icon: Icons.feedback,
                iconColor: const Color(0xFF896CFE), // purple accent
                title: 'Send Feedback',
                subtitle: 'Tell us what you think about the app',
                onTap: () {
                  const email = 'support@example.com';
                  const subject = 'Water Tracker Feedback';
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Compose an email to $email with subject "$subject"'),
                      backgroundColor: const Color(0xFF896CFE), // purple accent
                    ),
                  );
                },
              ),
              _buildListTile(
                icon: Icons.delete_forever,
                iconColor: const Color(0xFFE53935),
                title: 'Clear History',
                subtitle: 'Remove all logged water entries and stats',
                titleColor: const Color(0xFFE53935),
                onTap: () => _showClearHistoryDialog(context, authProvider),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Account Section
          _buildSectionCard(
            title: 'Account',
            children: [
              _buildListTile(
                icon: Icons.logout,
                iconColor: const Color(0xFFE53935),
                title: 'Sign Out',
                subtitle: 'Sign out of your account',
                titleColor: const Color(0xFFE53935),
                onTap: () => _showSignOutDialog(context, authProvider),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildUserProfileCard(UserModel userData) {
    final displayName = userData.displayName ?? 'User';
    final initials = displayName
        .split(' ')
        .map((n) => n.isNotEmpty ? n[0].toUpperCase() : '')
        .take(2)
        .join();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFF1C1C1E), // secondary background
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF896CFE), // purple accent
            ),
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFFFFFFF), // white
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userData.email,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFFEBEBF5), // secondary label
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E), // secondary background
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Text(
              title.toUpperCase(),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0x99EBEBF5), // tertiary label
                letterSpacing: -0.08,
                fontFamily: 'Inter',
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? titleColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF2C2C2E), // tertiary background
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: titleColor ?? const Color(0xFFFFFFFF), // white
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFFEBEBF5), // secondary label
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: Color(0xFF38383A), // separator
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF2C2C2E), // tertiary background
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFFFFFFF), // white
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFFEBEBF5), // secondary label
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF896CFE), // purple accent
          ),
        ],
      ),
    );
  }

  Future<void> _showIntervalDialog() async {
    final controller = TextEditingController(text: _reminderInterval.toString());

    final result = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: const Text(
          'Reminder Interval',
          style: TextStyle(
            color: Color(0xFFFFFFFF),
            fontWeight: FontWeight.w700,
            fontFamily: 'Inter',
          ),
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(
            color: Color(0xFFFFFFFF),
            fontFamily: 'Inter',
          ),
          decoration: InputDecoration(
            labelText: 'Interval (minutes)',
            labelStyle: const TextStyle(
              color: Color(0xFFEBEBF5),
              fontFamily: 'Inter',
            ),
            hintText: 'Enter interval in minutes',
            hintStyle: const TextStyle(
              color: Color(0x99EBEBF5),
              fontFamily: 'Inter',
            ),
            filled: true,
            fillColor: const Color(0xFF2C2C2E),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF38383A)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF38383A)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF896CFE), width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Color(0xFFEBEBF5),
                fontFamily: 'Inter',
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final interval = int.tryParse(controller.text);
              if (interval != null && interval > 0) {
                Navigator.pop(context, interval);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF896CFE),
              foregroundColor: const Color(0xFFFFFFFF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Save',
              style: TextStyle(fontFamily: 'Inter'),
            ),
          ),
        ],
      ),
    );

    if (result != null) {
      setState(() {
        _reminderInterval = result;
      });
      await NotificationService().setReminderInterval(result);
    }
  }

  Future<void> _showClearHistoryDialog(
    BuildContext context,
    AuthProvider authProvider,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: const Text(
          'Clear History',
          style: TextStyle(
            color: Color(0xFFFFFFFF),
            fontWeight: FontWeight.w700,
            fontFamily: 'Inter',
          ),
        ),
        content: const Text(
          'This will permanently delete all your water logs and daily stats. '
          'Your account and profile will stay intact.\n\nThis action cannot be undone.',
          style: TextStyle(
            color: Color(0xFFEBEBF5),
            fontFamily: 'Inter',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Color(0xFFEBEBF5),
                fontFamily: 'Inter',
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              foregroundColor: const Color(0xFFFFFFFF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Clear History',
              style: TextStyle(fontFamily: 'Inter'),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final userId = authProvider.currentUser?.uid;
      if (userId == null) return;

      try {
        await WaterService().clearUserData(userId);
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('History cleared'),
            backgroundColor: Color(0xFF896CFE),
          ),
        );
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to clear history: $e'),
            backgroundColor: const Color(0xFFE53935),
          ),
        );
      }
    }
  }

  Future<void> _showSignOutDialog(
    BuildContext context,
    AuthProvider authProvider,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: const Text(
          'Sign Out',
          style: TextStyle(
            color: Color(0xFFFFFFFF),
            fontWeight: FontWeight.w700,
            fontFamily: 'Inter',
          ),
        ),
        content: const Text(
          'Are you sure you want to sign out?',
          style: TextStyle(
            color: Color(0xFFEBEBF5),
            fontFamily: 'Inter',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Color(0xFFEBEBF5),
                fontFamily: 'Inter',
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              foregroundColor: const Color(0xFFFFFFFF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Sign Out',
              style: TextStyle(fontFamily: 'Inter'),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      await authProvider.signOut();
      if (context.mounted) {
        Navigator.pop(context);
      }
    }
  }
}
