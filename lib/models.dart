
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
}

enum Goal { reduce, quit, trackOnly }
enum QuitMethod { gradual, immediate }
enum ReductionSpeed { gentle, steady, fast }

class WeekStep {
  final int weekNumber;
  final int targetMg;
  bool completed;
  WeekStep(this.weekNumber, this.targetMg, {this.completed = false});
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
}

class Profile {
  String firstName;
  String lastName;
  String email;
  int age;
  double weightKg;
  int dailyCups;
  double coffeePrice;
  String currency;
  Profile({
    this.firstName = 'Alex',
    this.lastName = 'Mammadov',
    this.email = 'alex@mail.com',
    this.age = 32,
    this.weightKg = 78,
    this.dailyCups = 4,
    this.coffeePrice = 3.5,
    this.currency = 'AZN',
  });
}

class NotificationPrefs {
  bool coffeeReminders = true;
  bool dailyProgress = true;
  bool limitWarning = true;
  bool streakReminders = true;
  bool motivation = false;
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