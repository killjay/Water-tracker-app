import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:water_tracker/main.dart';
import 'package:water_tracker/providers/auth_provider.dart';
import 'package:water_tracker/providers/water_provider.dart';
import 'package:water_tracker/screens/home/home_screen.dart';
import 'package:water_tracker/screens/stats/stats_screen.dart';

void main() {
  Widget _wrapWithProviders(Widget child) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
        ChangeNotifierProvider<WaterProvider>(create: (_) => WaterProvider()),
      ],
      child: MaterialApp(home: child),
    );
  }

  testWidgets('HomeScreen builds with bottom navigation and FAB',
      (WidgetTester tester) async {
    await tester.pumpWidget(_wrapWithProviders(const HomeScreen()));

    // App bar title
    expect(find.text('Water Tracker'), findsOneWidget);
    // FAB
    expect(find.byType(FloatingActionButton), findsOneWidget);
    // Bottom navigation
    expect(find.byType(BottomNavigationBar), findsOneWidget);
  });

  testWidgets('StatsScreen builds basic layout', (WidgetTester tester) async {
    await tester.pumpWidget(_wrapWithProviders(const StatsScreen()));

    expect(find.text('Stats'), findsOneWidget);
    expect(find.text('Last 7 days'), findsOneWidget);
  });
}

