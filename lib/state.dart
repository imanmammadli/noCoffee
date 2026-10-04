import 'dart:math';
import 'package:flutter/material.dart';
import 'models.dart';

/// Single in-memory store for the whole app. No backend, no auth —
/// matches the product decision to ship without accounts.
/// Swap this for a persisted store (Hive/sqflite) later without touching UI code.
class AppState extends ChangeNotifier {
  ThemeMode themeMode = ThemeMode.system;

  bool onboardingDone = false;
  Goal onboardingGoal = Goal.reduce;
  int onboardingCups = 4;
  Set<DrinkType> onboardingUsualDrinks = {
    DrinkType.espresso,
    DrinkType.cappuccino,
    DrinkType.tea
  };
  QuitMethod onboardingMethod = QuitMethod.gradual;

  final Profile profile = Profile();
  final NotificationPrefs notifications = NotificationPrefs();

  final List<CoffeeEntry> entries = [];
  final List<CravingLog> cravings = [];
  Plan? plan;

  int get todayLimit => plan?.currentDailyLimit ?? 250;

  List<CoffeeEntry> get todayEntries {
    final now = DateTime.now();
    return entries
        .where((e) =>
            e.time.year == now.year &&
            e.time.month == now.month &&
            e.time.day == now.day)
        .toList()
      ..sort((a, b) => a.time.compareTo(b.time));
  }

  int get todayTotalMg => todayEntries.fold(0, (s, e) => s + e.mg);
  int get todayRemaining => (todayLimit - todayTotalMg);

  CoffeeEntry? get lastCoffee => entries.isEmpty
      ? null
      : (entries.toList()..sort((a, b) => b.time.compareTo(a.time))).first;

  // --- streak: consecutive days (including today if not yet over) under the daily limit ---
  int get streak {
    int count = 0;
    DateTime day = DateTime.now();
    for (int i = 0; i < 60; i++) {
      final dayEntries = entries.where((e) =>
          e.time.year == day.year &&
          e.time.month == day.month &&
          e.time.day == day.day);
      final total = dayEntries.fold(0, (s, e) => s + e.mg);
      final isToday = i == 0;
      if (isToday && dayEntries.isEmpty) {
        // today not over yet — don't break the streak on an empty today
        day = day.subtract(const Duration(days: 1));
        continue;
      }
      if (total <= todayLimit) {
        count++;
      } else {
        break;
      }
      day = day.subtract(const Duration(days: 1));
    }
    return count;
  }

  int get coffeeFreeDaysCount {
    final byDay = <String, int>{};
    for (final e in entries) {
      final k = '${e.time.year}-${e.time.month}-${e.time.day}';
      byDay[k] = (byDay[k] ?? 0) + e.mg;
    }
    final start =
        plan?.startDate ?? DateTime.now().subtract(const Duration(days: 12));
    int free = 0;
    for (var d = start;
        d.isBefore(DateTime.now());
        d = d.add(const Duration(days: 1))) {
      final k = '${d.year}-${d.month}-${d.day}';
      if (!byDay.containsKey(k)) free++;
    }
    return free;
  }

  int get cravingsResisted => cravings.where((c) => c.resisted).length;
  int get cravingsTotal => cravings.length;

  double get moneySaved {
    final avgCupsBefore = onboardingCups;
    final daysTracked = max(
        1, DateTime.now().difference(plan?.startDate ?? DateTime.now()).inDays);
    final cupsNowPerDay = todayEntries.length; // rough proxy
    final cupsAvoidedPerDay = max(0, avgCupsBefore - cupsNowPerDay);
    return cupsAvoidedPerDay * profile.coffeePrice * daysTracked / 3;
  }

  // ---- mutations ----

  void addEntry(DrinkType type, int cups, int mg, DateTime time) {
    entries.add(CoffeeEntry(
      id: UniqueKey().toString(),
      drink: type,
      cups: cups,
      mg: mg,
      time: time,
    ));
    notifyListeners();
  }

  void updateEntry(String id,
      {DrinkType? drink, int? cups, int? mg, DateTime? time}) {
    final e = entries.firstWhere((e) => e.id == id);
    if (drink != null) e.drink = drink;
    if (cups != null) e.cups = cups;
    if (mg != null) e.mg = mg;
    if (time != null) e.time = time;
    notifyListeners();
  }

  void deleteEntry(String id) {
    entries.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  void logCraving(int level, bool resisted) {
    cravings.add(CravingLog(level, resisted, DateTime.now()));
    notifyListeners();
  }

    DateTime onboardingStartDate = DateTime.now();
  ReductionSpeed onboardingSpeed = ReductionSpeed.steady;

  void buildPlanFromOnboarding() {
    final estimateMg = onboardingCups * 90;
    final start = onboardingStartDate;
    final toZero = onboardingGoal == Goal.quit;
    List<WeekStep> weeks;
    Duration totalSpan;
    switch (onboardingMethod) {
      case QuitMethod.immediate:
        weeks = [WeekStep(1, 0)];
        totalSpan = const Duration(days: 1);
        break;
      case QuitMethod.gradual:
        final steps = _speedSteps(toZero, onboardingSpeed);
        weeks = [
          for (int i = 0; i < steps.length; i++) WeekStep(i + 1, (estimateMg * steps[i]).round())
        ];
        totalSpan = Duration(days: weeks.length * 7);
        break;
    }
    plan = Plan(
      goal: onboardingGoal,
      method: onboardingMethod,
      speed: onboardingSpeed,
      startDate: start,
      targetDate: start.add(totalSpan),
      currentDailyLimit: weeks.first.targetMg,
      weeks: weeks,
      currentWeekIndex: 0,
    );
    notifyListeners();
  }

  List<double> _speedSteps(bool toZero, ReductionSpeed speed) {
    if (toZero) {
      switch (speed) {
        case ReductionSpeed.gentle:
          return [0.85, 0.72, 0.6, 0.48, 0.36, 0.24, 0.12, 0.0];
        case ReductionSpeed.fast:
          return [0.5, 0.2, 0.0];
        case ReductionSpeed.steady:
          return [0.75, 0.625, 0.375, 0.25, 0.0];
      }
    } else {
      switch (speed) {
        case ReductionSpeed.gentle:
          return [0.9, 0.8, 0.7, 0.6, 0.55, 0.5];
        case ReductionSpeed.fast:
          return [0.7, 0.5, 0.4];
        case ReductionSpeed.steady:
          return [0.8, 0.65, 0.55, 0.45];
      }
    }
  }

  void completeOnboarding() {
    buildPlanFromOnboarding();
    onboardingDone = true;
    notifyListeners();
  }

  void refresh() => notifyListeners();

  void setThemeMode(ThemeMode m) {
    themeMode = m;
    notifyListeners();
  }

  void deleteAllData() {
    entries.clear();
    cravings.clear();
    plan = null;
    onboardingDone = false;
    notifyListeners();
  }

  void seedDemoData() {
    final now = DateTime.now();
    entries.addAll([
      CoffeeEntry(
          id: 'seed1',
          drink: DrinkType.espresso,
          cups: 1,
          mg: 80,
          time: DateTime(now.year, now.month, now.day, 8, 30)),
      CoffeeEntry(
          id: 'seed2',
          drink: DrinkType.cappuccino,
          cups: 1,
          mg: 75,
          time: DateTime(now.year, now.month, now.day, 12, 15)),
    ]);
    cravings.addAll([
      CravingLog(4, true, now.subtract(const Duration(hours: 3))),
      CravingLog(3, true, now.subtract(const Duration(days: 1))),
      CravingLog(5, false, now.subtract(const Duration(days: 2))),
    ]);
    notifyListeners();
  }

  List<Achievement> get achievements => [
        Achievement(
            'first_day',
            '🏆',
            'First day',
            (s) => entries.isNotEmpty || plan != null,
            (s) => 'Log your first entry'),
        Achievement('streak3', '🔥', '3 day streak', (s) => s.streak >= 3,
            (s) => '${s.streak.clamp(0, 3)} of 3'),
        Achievement('streak7', '🔥', '7 day streak', (s) => s.streak >= 7,
            (s) => '${s.streak.clamp(0, 7)} of 7'),
        Achievement(
            'week1',
            '🎯',
            'First week completed',
            (s) => s.firstWeekDone,
            (s) => s.firstWeekDone ? 'Done' : 'In progress'),
        Achievement('streak14', '🔥', '14 day streak', (s) => s.streak >= 14,
            (s) => '${s.streak.clamp(0, 14)} of 14'),
        Achievement(
            'coffees50',
            '☕',
            '50 coffees avoided',
            (s) => s.cravingsResisted >= 50,
            (s) => '${s.cravingsResisted} of 50'),
        Achievement(
            'saved10',
            '💰',
            '10 ${profile.currency} saved',
            (s) => s.moneySaved >= 10,
            (s) => '${s.moneySaved.toStringAsFixed(0)} of 10'),
        Achievement(
            'challenge30',
            '🏅',
            '30 day challenge',
            (s) => s.daysIntoChallenge >= 30,
            (s) => 'Day ${s.daysIntoChallenge.clamp(0, 30)} of 30'),
      ];

  AppSnapshot get snapshot => AppSnapshot(
        streak: streak,
        coffeeFreeDays: coffeeFreeDaysCount,
        cravingsResisted: cravingsResisted,
        moneySaved: moneySaved,
        firstWeekDone: (plan?.weeks.first.completed) ?? false,
        daysIntoChallenge: plan?.dayNumber ?? 0,
      );
}
