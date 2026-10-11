import 'dart:async';
import 'package:flutter/material.dart';
import 'models.dart';
import 'storage.dart';

/// Single store for the whole app. No backend, no accounts: everything is
/// kept on the device and saved automatically after every change.
class AppState extends ChangeNotifier {
  ThemeMode themeMode = ThemeMode.system;

  bool onboardingDone = false;
  Goal onboardingGoal = Goal.reduce;
  int onboardingCups = 4;
  Set<DrinkType> onboardingUsualDrinks = {DrinkType.espresso, DrinkType.cappuccino, DrinkType.tea};
  QuitMethod onboardingMethod = QuitMethod.gradual;
  DateTime onboardingStartDate = DateTime.now();
  ReductionSpeed onboardingSpeed = ReductionSpeed.steady;

  Profile profile = Profile();
  NotificationPrefs notifications = NotificationPrefs();

  final List<CoffeeEntry> entries = [];
  final List<CravingLog> cravings = [];
  Plan? plan;

  // ---------------- persistence ----------------

  Timer? _saveTimer;

  /// Loads saved data from the device. Falls back to a fresh state if nothing
  /// is saved yet, or if the saved data can't be read.
  static Future<AppState> load() async {
    try {
      final data = await Storage.read();
      if (data != null) {
        return AppState().._apply(data);
      }
    } catch (e) {
      debugPrint('Could not load saved data: $e');
    }
    return AppState();
  }

  Map<String, dynamic> toJson() => {
        'version': 1,
        'themeMode': themeMode.name,
        'onboardingDone': onboardingDone,
        'onboardingGoal': onboardingGoal.name,
        'onboardingCups': onboardingCups,
        'onboardingUsualDrinks': onboardingUsualDrinks.map((d) => d.name).toList(),
        'onboardingMethod': onboardingMethod.name,
        'onboardingSpeed': onboardingSpeed.name,
        'onboardingStartDate': onboardingStartDate.toIso8601String(),
        'profile': profile.toJson(),
        'notifications': notifications.toJson(),
        'entries': entries.map((e) => e.toJson()).toList(),
        'cravings': cravings.map((c) => c.toJson()).toList(),
        'plan': plan?.toJson(),
      };

  void _apply(Map<String, dynamic> j) {
    themeMode = enumByName(ThemeMode.values, j['themeMode'], ThemeMode.system);
    onboardingDone = j['onboardingDone'] as bool? ?? false;
    onboardingGoal = enumByName(Goal.values, j['onboardingGoal'], Goal.reduce);
    onboardingCups = j['onboardingCups'] as int? ?? 4;
    onboardingUsualDrinks = ((j['onboardingUsualDrinks'] as List<dynamic>?) ?? const [])
        .map((e) => enumByName(DrinkType.values, e, DrinkType.other))
        .toSet();
    onboardingMethod = enumByName(QuitMethod.values, j['onboardingMethod'], QuitMethod.gradual);
    onboardingSpeed = enumByName(ReductionSpeed.values, j['onboardingSpeed'], ReductionSpeed.steady);
    onboardingStartDate =
        DateTime.tryParse(j['onboardingStartDate'] as String? ?? '') ?? DateTime.now();

    final p = j['profile'];
    if (p is Map<String, dynamic>) profile = Profile.fromJson(p);
    final n = j['notifications'];
    if (n is Map<String, dynamic>) notifications = NotificationPrefs.fromJson(n);

    entries
      ..clear()
      ..addAll(((j['entries'] as List<dynamic>?) ?? const [])
          .map((e) => CoffeeEntry.fromJson(e as Map<String, dynamic>)));
    cravings
      ..clear()
      ..addAll(((j['cravings'] as List<dynamic>?) ?? const [])
          .map((e) => CravingLog.fromJson(e as Map<String, dynamic>)));

    final pl = j['plan'];
    plan = pl is Map<String, dynamic> ? Plan.fromJson(pl) : null;
    
    // Older saves didn't store the daily cups on the profile.
    if (profile.dailyCups == 0 && onboardingDone) profile.dailyCups = onboardingCups;
  }

  /// Every notifyListeners() also schedules a save, so no screen has to
  /// remember to persist anything itself.
  @override
  void notifyListeners() {
    super.notifyListeners();
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 200), saveNow);
  }

  Future<void> saveNow() async {
    _saveTimer?.cancel();
    try {
      await Storage.write(toJson());
    } catch (e) {
      debugPrint('Could not save data: $e');
    }
  }
  // ---------------- derived values ----------------

  static DateTime _dayOnly(DateTime t) => DateTime(t.year, t.month, t.day);
  static DateTime _nextDay(DateTime d) => DateTime(d.year, d.month, d.day + 1);
  static DateTime _prevDay(DateTime d) => DateTime(d.year, d.month, d.day - 1);

  Iterable<CoffeeEntry> _entriesOn(DateTime d) => entries
      .where((e) => e.time.year == d.year && e.time.month == d.month && e.time.day == d.day);

  int _mgOn(DateTime d) => _entriesOn(d).fold(0, (s, e) => s + e.mg);
  int _cupsOn(DateTime d) => _entriesOn(d).fold(0, (s, e) => s + e.cups);

  int get todayLimit => plan?.currentDailyLimit ?? 250;
  int _limitOn(DateTime d) => plan?.limitOn(d) ?? 250;

  // Day-based reads used by Tracking, History and Statistics.
  List<CoffeeEntry> entriesOnDay(DateTime d) =>
      _entriesOn(d).toList()..sort((a, b) => a.time.compareTo(b.time));
  int mgOnDay(DateTime d) => _mgOn(d);
  int limitOnDay(DateTime d) => _limitOn(d);

  /// Usual daily intake: the plan baseline, or the cups you told us about.
  int get baselineMg {
    final p = plan;
    if (p != null && p.baselineMg > 0) return p.baselineMg;
    final cups = profile.dailyCups > 0 ? profile.dailyCups : onboardingCups;
    return cups * 90;
  }

  /// Earliest day with any data (first drink, or the plan start once it began).
  DateTime? get firstDay {
    final today = _dayOnly(DateTime.now());
    DateTime? best;
    if (entries.isNotEmpty) {
      best = _dayOnly(entries.map((e) => e.time).reduce((a, b) => a.isBefore(b) ? a : b));
    }
    final p = plan;
    if (p != null) {
      final s = _dayOnly(p.startDate);
      if (!s.isAfter(today) && (best == null || s.isBefore(best))) best = s;
    }
    return best;
  }

  /// Average mg per day between two days (inclusive). Days before your first
  /// data and the still-empty today are left out. Null when nothing counts.
  double? avgMgBetween(DateTime from, DateTime to) {
    final first = firstDay;
    if (first == null) return null;
    final today = _dayOnly(DateTime.now());
    var s = _dayOnly(from).isBefore(first) ? first : _dayOnly(from);
    var e = _dayOnly(to).isAfter(today) ? today : _dayOnly(to);
    if (e == today && _entriesOn(today).isEmpty) e = _prevDay(today);
    if (e.isBefore(s)) return null;
    var total = 0;
    var n = 0;
    for (var d = s; !d.isAfter(e); d = _nextDay(d)) {
      total += _mgOn(d);
      n++;
    }
    return n == 0 ? null : total / n;
  }

  /// Best run of days at or under the limit since tracking began.
  int get longestStreak {
    final start = _trackingStart;
    if (start == null) return 0;
    final today = _dayOnly(DateTime.now());
    var best = 0;
    var run = 0;
    for (var d = start; !d.isAfter(today); d = _nextDay(d)) {
      final total = _mgOn(d);
      if (d == today && total == 0) continue;
      if (total <= _limitOn(d)) {
        run++;
        if (run > best) best = run;
      } else {
        run = 0;
      }
    }
    return best;
  }

  /// Weekday you drink the most on, or null until there is enough data.
  String? get busiestWeekday {
    final first = firstDay;
    if (first == null) return null;
    final today = _dayOnly(DateTime.now());
    if (today.difference(first).inDays < 13) return null;
    final totals = List<int>.filled(7, 0);
    final counts = List<int>.filled(7, 0);
    for (var d = first; !d.isAfter(today); d = _nextDay(d)) {
      totals[d.weekday - 1] += _mgOn(d);
      counts[d.weekday - 1]++;
    }
    var bestI = -1;
    double bestAvg = 0;
    for (var i = 0; i < 7; i++) {
      if (counts[i] == 0) continue;
      final a = totals[i] / counts[i];
      if (a > bestAvg) {
        bestAvg = a;
        bestI = i;
      }
    }
    if (bestI < 0) return null;
    return const ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'][bestI];
  }

  // ---------------- in-app limit warning ----------------

  String? _pendingWarning;

  /// Returns (and clears) a warning produced by the last drink you logged.
  String? takeWarning() {
    final w = _pendingWarning;
    _pendingWarning = null;
    return w;
  }

  void _checkLimit(int before, int after) {
    if (!notifications.limitWarning || plan == null) return;
    final limit = todayLimit;
    if (after <= before) return;
    if (limit == 0) {
      _pendingWarning = 'Your plan is coffee-free today. Take a breath before the next one.';
    } else if (before <= limit && after > limit) {
      _pendingWarning = 'You went over today\'s limit ($after of $limit mg).';
    } else if (before < limit * 0.8 && after >= limit * 0.8 && after <= limit) {
      _pendingWarning = 'You\'re close to your daily limit ($after of $limit mg).';
    }
  }

  List<CoffeeEntry> get todayEntries =>
      _entriesOn(DateTime.now()).toList()..sort((a, b) => a.time.compareTo(b.time));

  int get todayTotalMg => _mgOn(DateTime.now());
  int get todayRemaining => todayLimit - todayTotalMg;

  CoffeeEntry? get lastCoffee =>
      entries.isEmpty ? null : (entries.toList()..sort((a, b) => b.time.compareTo(a.time))).first;

  /// First day that counts for streaks and savings: the plan's start date
  /// (or the first logged entry when there is no plan). Null while the plan
  /// hasn't started yet.
  DateTime? get _trackingStart {
    final p = plan;
    if (p != null) {
      final s = _dayOnly(p.startDate);
      return s.isAfter(_dayOnly(DateTime.now())) ? null : s;
    }
    if (entries.isEmpty) return null;
    return _dayOnly(entries.map((e) => e.time).reduce((a, b) => a.isBefore(b) ? a : b));
  }

  /// Consecutive days (ending today) at or under the daily limit.
  /// A day without any drinks counts as under the limit. Today is skipped
  /// while it is still empty, because it isn't over yet.
  int get streak {
    final start = _trackingStart;
    if (start == null) return 0;
    final today = _dayOnly(DateTime.now());
    var count = 0;
    for (var d = today; !d.isBefore(start); d = _prevDay(d)) {
      final total = _mgOn(d);
      if (d == today && total == 0) continue;
      if (total <= _limitOn(d)) {
        count++;
      } else {
        break;
      }
    }
    return count;
  }

  /// Finished days since the start with no drinks at all.
  int get coffeeFreeDaysCount {
    final start = _trackingStart;
    if (start == null) return 0;
    final today = _dayOnly(DateTime.now());
    var free = 0;
    for (var d = start; d.isBefore(today); d = _nextDay(d)) {
      if (_entriesOn(d).isEmpty) free++;
    }
    return free;
  }

  int get cravingsResisted => cravings.where((c) => c.resisted).length;
  int get cravingsTotal => cravings.length;

  /// Cups you didn't drink compared with your usual daily amount, times the
  /// coffee price. Finished days count in full (a heavy day never cancels
  /// a good one). Today counts in proportion to how much of the day has
  /// passed, so the number moves as you log drinks.
  double get moneySaved {
    final start = _trackingStart;
    if (start == null) return 0;
    final baseline = profile.dailyCups > 0 ? profile.dailyCups : onboardingCups;
    final now = DateTime.now();
    final today = _dayOnly(now);

    double avoided = 0;
    for (var d = start; d.isBefore(today); d = _nextDay(d)) {
      final left = baseline - _cupsOn(d);
      if (left > 0) avoided += left;
    }
    final dayFraction = now.difference(today).inMinutes / 1440.0;
    final leftToday = baseline * dayFraction - _cupsOn(today);
    if (leftToday > 0) avoided += leftToday;

    return avoided * profile.coffeePrice;
  }
  // ---------------- mutations ----------------

  /// Public trigger for UI rebuilds + saving after mutating fields directly
  /// (e.g. editing `profile` or `plan` from a form).
  void refresh() => notifyListeners();

  void addEntry(DrinkType type, int cups, int mg, DateTime time) {
    final before = todayTotalMg;
    entries.add(CoffeeEntry(
      id: UniqueKey().toString(),
      drink: type,
      cups: cups,
      mg: mg,
      time: time,
    ));
    final t = _dayOnly(time);
    if (t == _dayOnly(DateTime.now())) _checkLimit(before, todayTotalMg);
    notifyListeners();
  }

  void updateEntry(String id, {DrinkType? drink, int? cups, int? mg, DateTime? time}) {
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

  void buildPlanFromOnboarding() {
    plan = Plan.build(
      goal: onboardingGoal,
      method: onboardingMethod,
      speed: onboardingSpeed,
      startDate: onboardingStartDate,
      baselineMg: onboardingCups * 90,
    );
    notifyListeners();
  }

  void completeOnboarding() {
    buildPlanFromOnboarding();
    profile.dailyCups = onboardingCups;
    onboardingDone = true;
    notifyListeners();
  }
  void setThemeMode(ThemeMode m) {
    themeMode = m;
    notifyListeners();
  }

  /// Wipes everything: history, plan, profile and settings.
  void deleteAllData() {
    entries.clear();
    cravings.clear();
    plan = null;
    profile = Profile();
    notifications = NotificationPrefs();
    onboardingDone = false;
    onboardingGoal = Goal.reduce;
    onboardingCups = 4;
    onboardingUsualDrinks = {DrinkType.espresso, DrinkType.cappuccino, DrinkType.tea};
    onboardingMethod = QuitMethod.gradual;
    onboardingStartDate = DateTime.now();
    onboardingSpeed = ReductionSpeed.steady;
    notifyListeners();
  }

  // ---------------- achievements ----------------

  List<Achievement> get achievements => [
        Achievement('first_day', '🏆', 'First day', (s) => entries.isNotEmpty || plan != null,
            (s) => 'Log your first entry'),
        Achievement('streak3', '🔥', '3 day streak', (s) => s.streak >= 3,
            (s) => '${s.streak.clamp(0, 3)} of 3'),
        Achievement('streak7', '🔥', '7 day streak', (s) => s.streak >= 7,
            (s) => '${s.streak.clamp(0, 7)} of 7'),
        Achievement('week1', '🎯', 'First week completed', (s) => s.firstWeekDone,
            (s) => s.firstWeekDone ? 'Done' : 'In progress'),
        Achievement('streak14', '🔥', '14 day streak', (s) => s.streak >= 14,
            (s) => '${s.streak.clamp(0, 14)} of 14'),
        Achievement('coffees50', '☕', '50 coffees avoided', (s) => s.cravingsResisted >= 50,
            (s) => '${s.cravingsResisted} of 50'),
        Achievement('saved10', '💰', 'First 10 saved', (s) => s.moneySaved >= 10,
            (s) => '${s.moneySaved.toStringAsFixed(0)} of 10'),
        Achievement('challenge30', '🏅', '30 day challenge', (s) => s.daysIntoChallenge >= 30,
            (s) => 'Day ${s.daysIntoChallenge.clamp(0, 30)} of 30'),
      ];

  AppSnapshot get snapshot => AppSnapshot(
        streak: streak,
        coffeeFreeDays: coffeeFreeDaysCount,
        cravingsResisted: cravingsResisted,
        moneySaved: moneySaved,
        firstWeekDone: plan?.isWeekDone(0) ?? false,
        daysIntoChallenge: plan?.dayNumber ?? 0,
      );
}