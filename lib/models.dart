/// Reads an enum by its name, falling back if the value is missing or unknown.
T enumByName<T extends Enum>(List<T> values, Object? name, T fallback) {
  for (final v in values) {
    if (v.name == name) return v;
  }
  return fallback;
}

enum DrinkType { espresso, americano, cappuccino, latte, filter, tea, energyDrink, other }

class DrinkInfo {
  final DrinkType type;
  final String label;
  final String emoji;
  final int mgPerCup;
  const DrinkInfo(this.type, this.label, this.emoji, this.mgPerCup);
}

const kDrinks = <DrinkInfo>[
  DrinkInfo(DrinkType.espresso, 'Espresso', '☕', 63),
  DrinkInfo(DrinkType.americano, 'Americano', '☕', 77),
  DrinkInfo(DrinkType.cappuccino, 'Cappuccino', '☕', 75),
  DrinkInfo(DrinkType.latte, 'Latte', '🥛', 75),
  DrinkInfo(DrinkType.filter, 'Filter coffee', '🫗', 95),
  DrinkInfo(DrinkType.tea, 'Tea', '🫖', 30),
  DrinkInfo(DrinkType.energyDrink, 'Energy drink', '⚡', 80),
  DrinkInfo(DrinkType.other, 'Other', '🥤', 50),
];

DrinkInfo drinkInfo(DrinkType t) => kDrinks.firstWhere((d) => d.type == t);

class CoffeeEntry {
  final String id;
  DrinkType drink;
  int cups;
  int mg;
  DateTime time;

  CoffeeEntry({
    required this.id,
    required this.drink,
    required this.cups,
    required this.mg,
    required this.time,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'drink': drink.name,
        'cups': cups,
        'mg': mg,
        'time': time.toIso8601String(),
      };

  factory CoffeeEntry.fromJson(Map<String, dynamic> j) => CoffeeEntry(
        id: j['id'] as String,
        drink: enumByName(DrinkType.values, j['drink'], DrinkType.other),
        cups: j['cups'] as int,
        mg: j['mg'] as int,
        time: DateTime.parse(j['time'] as String),
      );
}

enum Goal { reduce, quit, trackOnly }
enum QuitMethod { gradual, immediate }
enum ReductionSpeed { gentle, steady, fast }

/// Share of the baseline intake allowed in each week of a gradual plan.
List<double> planSteps(bool toZero, ReductionSpeed speed) {
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

class WeekStep {
  final int weekNumber;
  final int targetMg;
  const WeekStep(this.weekNumber, this.targetMg);

  Map<String, dynamic> toJson() => {'weekNumber': weekNumber, 'targetMg': targetMg};

  factory WeekStep.fromJson(Map<String, dynamic> j) =>
      WeekStep(j['weekNumber'] as int, j['targetMg'] as int);
}

/// A plan is just dates + weekly targets. Which week you are in, today's
/// limit and "completed" status are all derived from today's date.
class Plan {
  Goal goal;
  QuitMethod method;
  ReductionSpeed speed;
  DateTime startDate;
  DateTime targetDate;
  int baselineMg;
  List<WeekStep> weeks;

  Plan({
    required this.goal,
    required this.method,
    required this.speed,
    required this.startDate,
    required this.targetDate,
    required this.baselineMg,
    required this.weeks,
  });

  factory Plan.build({
    required Goal goal,
    required QuitMethod method,
    required ReductionSpeed speed,
    required DateTime startDate,
    required int baselineMg,
  }) {
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final List<WeekStep> weeks;
    if (method == QuitMethod.immediate) {
      // Stopping at once: four weeks at zero to get through the hardest part.
      weeks = [for (var i = 0; i < 4; i++) WeekStep(i + 1, 0)];
    } else {
      final steps = planSteps(goal == Goal.quit, speed);
      weeks = [
        for (var i = 0; i < steps.length; i++) WeekStep(i + 1, (baselineMg * steps[i]).round())
      ];
    }
    return Plan(
      goal: goal,
      method: method,
      speed: speed,
      startDate: start,
      targetDate: DateTime(start.year, start.month, start.day + weeks.length * 7),
      baselineMg: baselineMg,
      weeks: weeks,
    );
  }

  static int _daysBetween(DateTime a, DateTime b) =>
      DateTime.utc(b.year, b.month, b.day).difference(DateTime.utc(a.year, a.month, a.day)).inDays;

  int get daysSinceStart => _daysBetween(startDate, DateTime.now());
  bool get hasStarted => daysSinceStart >= 0;
  int get daysUntilStart => hasStarted ? 0 : -daysSinceStart;
  int get dayNumber => hasStarted ? daysSinceStart + 1 : 0;
  int get totalDays => _daysBetween(startDate, targetDate);
  bool get isFinished => daysSinceStart >= totalDays;

  double get progress {
    if (!hasStarted) return 0.0;
    final v = dayNumber / totalDays;
    return v > 1 ? 1.0 : v;
  }

  int get currentWeekIndex {
    if (!hasStarted) return 0;
    final i = daysSinceStart ~/ 7;
    return i >= weeks.length ? weeks.length - 1 : i;
  }

  /// Before the plan starts, the limit is simply the baseline intake.
  int get currentDailyLimit => hasStarted ? weeks[currentWeekIndex].targetMg : baselineMg;

  /// The daily limit that applied on a given calendar day.
  int limitOn(DateTime day) {
    final diff = _daysBetween(startDate, day);
    if (diff < 0) return baselineMg;
    final i = diff ~/ 7;
    return weeks[i >= weeks.length ? weeks.length - 1 : i].targetMg;
  }

  int get finalTargetMg => weeks.last.targetMg;

  String get endLabel => method == QuitMethod.immediate
      ? 'First 4 weeks end'
      : (finalTargetMg == 0 ? 'Coffee-free by' : 'Target reached by');

  bool isWeekDone(int i) =>
      hasStarted && (i < currentWeekIndex || (isFinished && i == weeks.length - 1));

  DateTime weekStart(int i) => DateTime(startDate.year, startDate.month, startDate.day + 7 * i);

  /// Moves the whole timeline back so the next week starts today.
  void startNextWeekNow() {
    if (!hasStarted || currentWeekIndex >= weeks.length - 1) return;
    final shift = (currentWeekIndex + 1) * 7 - daysSinceStart;
    startDate = DateTime(startDate.year, startDate.month, startDate.day - shift);
    targetDate = DateTime(targetDate.year, targetDate.month, targetDate.day - shift);
  }

  Map<String, dynamic> toJson() => {
        'goal': goal.name,
        'method': method.name,
        'speed': speed.name,
        'startDate': startDate.toIso8601String(),
        'targetDate': targetDate.toIso8601String(),
        'baselineMg': baselineMg,
        'weeks': weeks.map((w) => w.toJson()).toList(),
      };

  factory Plan.fromJson(Map<String, dynamic> j) {
    final goal = enumByName(Goal.values, j['goal'], Goal.reduce);
    final method = enumByName(QuitMethod.values, j['method'], QuitMethod.gradual);
    final speed = enumByName(ReductionSpeed.values, j['speed'], ReductionSpeed.steady);
    final weeks = (j['weeks'] as List<dynamic>)
        .map((w) => WeekStep.fromJson(w as Map<String, dynamic>))
        .toList();

    final int baseline;
    final saved = j['baselineMg'];
    if (saved is int) {
      baseline = saved;
    } else {
      // Older saves didn't store the baseline: work back from week 1.
      final first = planSteps(goal == Goal.quit, speed).first;
      baseline = (method == QuitMethod.gradual && first > 0)
          ? (weeks.first.targetMg / first).round()
          : 400;
    }

    return Plan(
      goal: goal,
      method: method,
      speed: speed,
      startDate: DateTime.parse(j['startDate'] as String),
      targetDate: DateTime.parse(j['targetDate'] as String),
      baselineMg: baseline,
      weeks: weeks,
    );
  }
}
class Achievement {
  final String id;
  final String emoji;
  final String title;
  final bool Function(AppSnapshot) isUnlocked;
  final String Function(AppSnapshot) progressLabel;
  const Achievement(this.id, this.emoji, this.title, this.isUnlocked, this.progressLabel);
}

/// Lightweight read-only snapshot passed to achievement checks.
class AppSnapshot {
  final int streak;
  final int coffeeFreeDays;
  final int cravingsResisted;
  final double moneySaved;
  final bool firstWeekDone;
  final int daysIntoChallenge;
  const AppSnapshot({
    required this.streak,
    required this.coffeeFreeDays,
    required this.cravingsResisted,
    required this.moneySaved,
    required this.firstWeekDone,
    required this.daysIntoChallenge,
  });
}

class CravingLog {
  final int level; // 1-5
  final bool resisted;
  final DateTime time;
  CravingLog(this.level, this.resisted, this.time);

  Map<String, dynamic> toJson() =>
      {'level': level, 'resisted': resisted, 'time': time.toIso8601String()};

  factory CravingLog.fromJson(Map<String, dynamic> j) => CravingLog(
        j['level'] as int,
        j['resisted'] as bool,
        DateTime.parse(j['time'] as String),
      );
}

class Profile {
  String firstName;
  String lastName;
  String email;
  int age;
  double weightKg;
  int dailyCups;
  double coffeePrice;
  Profile({
    this.firstName = '',
    this.lastName = '',
    this.email = '',
    this.age = 0,
    this.weightKg = 0,
    this.dailyCups = 0,
    this.coffeePrice = 0,
  });

  Map<String, dynamic> toJson() => {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'age': age,
        'weightKg': weightKg,
        'dailyCups': dailyCups,
        'coffeePrice': coffeePrice,
      };

  factory Profile.fromJson(Map<String, dynamic> j) => Profile(
        firstName: j['firstName'] as String? ?? '',
        lastName: j['lastName'] as String? ?? '',
        email: j['email'] as String? ?? '',
        age: j['age'] as int? ?? 0,
        weightKg: (j['weightKg'] as num?)?.toDouble() ?? 0,
        dailyCups: j['dailyCups'] as int? ?? 0,
        coffeePrice: (j['coffeePrice'] as num?)?.toDouble() ?? 0,
      );
}

class NotificationPrefs {
  NotificationPrefs();

  bool coffeeReminders = false;
  bool dailyProgress = false;
  bool limitWarning = true;
  bool streakReminders = false;
  bool motivation = false;

  /// Quiet hours, as minutes after midnight. No notification is scheduled
  /// inside this window.
  int quietFromMin = 22 * 60;
  int quietUntilMin = 7 * 60;

  bool isQuiet(int hour, int minute) {
    final m = hour * 60 + minute;
    if (quietFromMin == quietUntilMin) return false;
    if (quietFromMin > quietUntilMin) return m >= quietFromMin || m < quietUntilMin;
    return m >= quietFromMin && m < quietUntilMin;
  }

  Map<String, dynamic> toJson() => {
        'coffeeReminders': coffeeReminders,
        'dailyProgress': dailyProgress,
        'limitWarning': limitWarning,
        'streakReminders': streakReminders,
        'motivation': motivation,
        'quietFromMin': quietFromMin,
        'quietUntilMin': quietUntilMin,
      };

  factory NotificationPrefs.fromJson(Map<String, dynamic> j) {
    final p = NotificationPrefs();
    p.coffeeReminders = j['coffeeReminders'] as bool? ?? p.coffeeReminders;
    p.dailyProgress = j['dailyProgress'] as bool? ?? p.dailyProgress;
    p.limitWarning = j['limitWarning'] as bool? ?? p.limitWarning;
    p.streakReminders = j['streakReminders'] as bool? ?? p.streakReminders;
    p.motivation = j['motivation'] as bool? ?? p.motivation;
    p.quietFromMin = j['quietFromMin'] as int? ?? p.quietFromMin;
    p.quietUntilMin = j['quietUntilMin'] as int? ?? p.quietUntilMin;
    return p;
  }
}

String fmtMinutes(int m) =>
    '${(m ~/ 60).toString().padLeft(2, '0')}:${(m % 60).toString().padLeft(2, '0')}';

String fmtTime(DateTime t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

String fmtAgo(DateTime t) {
  final d = DateTime.now().difference(t);
  if (d.inMinutes < 1) return 'just now';
  if (d.inHours < 1) return '${d.inMinutes}m ago';
  if (d.inHours < 24) return '${d.inHours}h ${d.inMinutes % 60}m ago';
  return '${d.inDays}d ago';
}