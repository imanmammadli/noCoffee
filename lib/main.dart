import 'package:flutter/material.dart';
import 'state.dart';
import 'theme.dart';
import 'screens/splash_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/onboarding_flow.dart';
import 'screens/home_screen.dart';
import 'screens/tracking_screen.dart';
import 'screens/history_screen.dart';
import 'screens/craving_flow.dart';
import 'screens/plan_screen.dart';
import 'screens/week_detail_screen.dart';
import 'screens/edit_plan_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/achievements_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/notification_settings_screen.dart';
import 'screens/export_screen.dart';
import 'screens/delete_data_screen.dart';

void main() {
  runApp(const TaperApp());
}

class TaperApp extends StatefulWidget {
  const TaperApp({super.key});
  @override
  State<TaperApp> createState() => _TaperAppState();
}

class _TaperAppState extends State<TaperApp> {
  final AppState state = AppState()..seedDemoData();

  @override
  void initState() {
    super.initState();
    state.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final platformBrightness = MediaQuery.platformBrightnessOf(context);
    final isDark = state.themeMode == ThemeMode.dark ||
        (state.themeMode == ThemeMode.system && platformBrightness == Brightness.dark);
    final colors = isDark ? AppColors.dark : AppColors.light;

    return AppStateScope(
      state: state,
      child: AppTheme(
        colors: colors,
        child: MaterialApp(
          title: 'Taper',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            fontFamily: 'Roboto',
            brightness: colors.brightness,
            scaffoldBackgroundColor: colors.bg,
            colorScheme: ColorScheme(
              brightness: colors.brightness,
              primary: colors.coffee,
              onPrimary: colors.bg,
              secondary: colors.accent,
              onSecondary: colors.bg,
              error: colors.danger,
              onError: colors.bg,
              surface: colors.surface,
              onSurface: colors.ink,
            ),
          ),
          initialRoute: '/',
          routes: {
            '/': (_) => const SplashScreen(),
            '/welcome': (_) => const WelcomeScreen(),
            '/onboarding': (_) => const OnboardingFlow(),
            '/home': (_) => const HomeScreen(),
            '/tracking': (_) => const TrackingScreen(),
            '/history': (_) => const HistoryScreen(),
            '/craving': (_) => const CravingFlow(),
            '/plan': (_) => const PlanScreen(),
            '/weekDetail': (_) => const WeekDetailScreen(),
            '/editPlan': (_) => const EditPlanScreen(),
            '/stats': (_) => const StatsScreen(),
            '/achievements': (_) => const AchievementsScreen(),
            '/profile': (_) => const ProfileScreen(),
            '/editProfile': (_) => const EditProfileScreen(),
            '/settings': (_) => const SettingsScreen(),
            '/notificationSettings': (_) => const NotificationSettingsScreen(),
            '/export': (_) => const ExportScreen(),
            '/deleteData': (_) => const DeleteDataScreen(),
          },
        ),
      ),
    );
  }
}

/// Simple InheritedWidget to make AppState reachable via `context.app`.
class AppStateScope extends InheritedWidget {
  final AppState state;
  const AppStateScope({super.key, required this.state, required super.child});

  static AppState of(BuildContext context) {
    final s = context.dependOnInheritedWidgetOfExactType<AppStateScope>();
    assert(s != null, 'AppStateScope not found in context');
    return s!.state;
  }

  @override
  bool updateShouldNotify(AppStateScope oldWidget) => true;
}

extension AppStateX on BuildContext {
  AppState get app => AppStateScope.of(this);
}