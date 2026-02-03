import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/water_provider.dart';
import 'services/water_service.dart';
import 'services/notification_service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/onboarding/onboarding_flow_screen.dart';
import 'utils/theme.dart';
import 'utils/date_utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize Firebase App Check
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.playIntegrity,
    appleProvider: AppleProvider.deviceCheck,
  );

  // Initialize timezone
  await AppDateUtils.initialize();

  // Enable Firestore offline persistence
  await WaterService.enableOfflinePersistence();

  // Initialize notifications
  await NotificationService().initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => WaterProvider()),
      ],
      child: MaterialApp(
        title: 'Water Tracker',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark, // Use dark theme by default to match design
        debugShowCheckedModeBanner: false,
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Show loading while checking auth state
        if (authProvider.isLoading && authProvider.currentUser == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Show login screen if not authenticated
        if (authProvider.currentUser == null) {
          return const LoginScreen();
        }

        // If user data is still loading, show a spinner
        if (authProvider.userData == null && authProvider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Route to onboarding if profile is incomplete
        if (!authProvider.hasCompletedOnboarding) {
          return const OnboardingFlowScreen();
        }

        // Show home/dashboard when authenticated and onboarded
        return const HomeScreen();
      },
    );
  }
}
