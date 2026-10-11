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
import 'screens/delete_data_screen.dart';
import 'screens/name_screen.dart';
import 'notification_service.dart';

final GlobalKey<ScaffoldMessengerState> messengerKey = GlobalKey<ScaffoldMessengerState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final state = await AppState.load();
  final motivationOn = await NotificationService.instance.init();
  runApp(TaperApp(state: state, motivationOn: motivationOn));
}

class TaperApp extends StatefulWidget {
  final AppState? state;
  final bool motivationOn;
  const TaperApp({super.key, this.state, this.motivationOn = false});

  @override
  State<TaperApp> createState() => _TaperAppState();
}

class _TaperAppState extends State<TaperApp> with WidgetsBindingObserver {
  late final AppState state = widget.state ?? AppState();

  @override
  void initState() {
    super.initState();
    // The phone's scheduled notifications are the source of truth for this toggle.
    state.notifications.motivation = widget.motivationOn;
    state.addListener(_onStateChanged);
    WidgetsBinding.instance.addObserver(this);
    NotificationService.instance.syncAll(state);
  }

  void _onStateChanged() {
    setState(() {});
    final warning = state.takeWarning();
    if (warning != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final m = messengerKey.currentState;
        if (m == null) return;
        m.hideCurrentSnackBar();
        m.showSnackBar(SnackBar(
          content: Text(warning),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ));
      });
    }
  }

  @override
  void dispose() {
    state.removeListener(_onStateChanged);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState s) {
    // Save right away when the app leaves the foreground.
    if (s != AppLifecycleState.resumed) {
      state.saveNow();
      if (s == AppLifecycleState.paused) NotificationService.instance.syncAll(state);
    }
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
          scaffoldMessengerKey: messengerKey,
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
            '/name': (_) => const NameScreen(),
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