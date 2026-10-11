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

class WeekStep {
  final int weekNumber;
  final int targetMg;
  bool completed;
  WeekStep(this.weekNumber, this.targetMg, {this.completed = false});

  Map<String, dynamic> toJson() =>
      {'weekNumber': weekNumber, 'targetMg': targetMg, 'completed': completed};

  factory WeekStep.fromJson(Map<String, dynamic> j) => WeekStep(
        j['weekNumber'] as int,
        j['targetMg'] as int,
        completed: j['completed'] as bool? ?? false,
      );
}

class Plan {
  Goal goal;
  QuitMethod method;
  ReductionSpeed speed;
  DateTime startDate;
  DateTime targetDate;
  int currentDailyLimit;
  List<WeekStep> weeks;
  int currentWeekIndex;

  Plan({
    required this.goal,
    required this.method,
    required this.speed,
    required this.startDate,
    required this.targetDate,
    required this.currentDailyLimit,
    required this.weeks,
    required this.currentWeekIndex,
  });

  int get dayNumber => DateTime.now().difference(startDate).inDays + 1;
  int get totalDays => targetDate.difference(startDate).inDays;
  double get progress => (dayNumber / totalDays).clamp(0, 1);

  Map<String, dynamic> toJson() => {
        'goal': goal.name,
        'method': method.name,
        'speed': speed.name,
        'startDate': startDate.toIso8601String(),
        'targetDate': targetDate.toIso8601String(),
        'currentDailyLimit': currentDailyLimit,
        'weeks': weeks.map((w) => w.toJson()).toList(),
        'currentWeekIndex': currentWeekIndex,
      };

  factory Plan.fromJson(Map<String, dynamic> j) => Plan(
        goal: enumByName(Goal.values, j['goal'], Goal.reduce),
        method: enumByName(QuitMethod.values, j['method'], QuitMethod.gradual),
        speed: enumByName(ReductionSpeed.values, j['speed'], ReductionSpeed.steady),
        startDate: DateTime.parse(j['startDate'] as String),
        targetDate: DateTime.parse(j['targetDate'] as String),
        currentDailyLimit: j['currentDailyLimit'] as int,
        weeks: (j['weeks'] as List<dynamic>)
            .map((w) => WeekStep.fromJson(w as Map<String, dynamic>))
            .toList(),
        currentWeekIndex: j['currentWeekIndex'] as int,
      );
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

  bool coffeeReminders = true;
  bool dailyProgress = true;
  bool limitWarning = true;
  bool streakReminders = true;
  bool motivation = false;

  Map<String, dynamic> toJson() => {
        'coffeeReminders': coffeeReminders,
        'dailyProgress': dailyProgress,
        'limitWarning': limitWarning,
        'streakReminders': streakReminders,
        'motivation': motivation,
      };

  factory NotificationPrefs.fromJson(Map<String, dynamic> j) {
    final p = NotificationPrefs();
    p.coffeeReminders = j['coffeeReminders'] as bool? ?? p.coffeeReminders;
    p.dailyProgress = j['dailyProgress'] as bool? ?? p.dailyProgress;
    p.limitWarning = j['limitWarning'] as bool? ?? p.limitWarning;
    p.streakReminders = j['streakReminders'] as bool? ?? p.streakReminders;
    p.motivation = j['motivation'] as bool? ?? p.motivation;
    return p;
  }
}

String fmtTime(DateTime t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

String fmtAgo(DateTime t) {
  final d = DateTime.now().difference(t);
  if (d.inMinutes < 1) return 'just now';
  if (d.inHours < 1) return '${d.inMinutes}m ago';
  if (d.inHours < 24) return '${d.inHours}h ${d.inMinutes % 60}m ago';
  return '${d.inDays}d ago';
}