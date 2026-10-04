import 'package:flutter/material.dart';
import '../main.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets/common.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});
  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  int step = 0;
  final int totalSteps = 5;

  // Fully local draft state — nothing is written to AppState until the
  // final "Start my journey" tap, so every screen always reflects the
  // latest choice instead of stale shared-state reads.
  Goal goal = Goal.reduce;
  int cups = 4;
  Set<DrinkType> drinks = {DrinkType.espresso, DrinkType.cappuccino, DrinkType.tea};
  QuitMethod method = QuitMethod.gradual;
  DateTime startDate = DateTime.now();
  ReductionSpeed speed = ReductionSpeed.steady;

  int get estimateMg => cups * 90;

  List<double> _steps() {
    final toZero = goal == Goal.quit;
    if (toZero) {
      switch (speed) {
        case ReductionSpeed.gentle: return [0.85, 0.72, 0.6, 0.48, 0.36, 0.24, 0.12, 0.0];
        case ReductionSpeed.fast: return [0.5, 0.2, 0.0];
        case ReductionSpeed.steady: return [0.75, 0.625, 0.375, 0.25, 0.0];
      }
    } else {
      switch (speed) {
        case ReductionSpeed.gentle: return [0.9, 0.8, 0.7, 0.6, 0.55, 0.5];
        case ReductionSpeed.fast: return [0.7, 0.5, 0.4];
        case ReductionSpeed.steady: return [0.8, 0.65, 0.55, 0.45];
      }
    }
  }

  void next() {
    if (step < totalSteps - 1) {
      setState(() => step++);
    } else {
      final app = context.app;
      app.onboardingGoal = goal;
      app.onboardingCups = cups;
      app.onboardingUsualDrinks = drinks;
      app.onboardingMethod = method;
      app.onboardingStartDate = startDate;
      app.onboardingSpeed = speed;
      app.completeOnboarding();
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 16, 22, 6),
            child: Row(
              children: List.generate(
                totalSteps,
                (i) => Expanded(
                  child: Container(
                    height: 4,
                    margin: EdgeInsets.only(right: i == totalSteps - 1 ? 0 : 6),
                    decoration: BoxDecoration(
                      color: i <= step ? c.coffee : c.surface2,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 22),
              child: _stepBody(),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _stepBody() {
    switch (step) {
      case 0:
        return _goalStep();
      case 1:
        return _consumptionStep();
      case 2:
        return _methodStep();
      case 3:
        return _planConfigStep();
      default:
        return _readyStep();
    }
  }

  Widget _goalStep() {
    final c = context.colors;
    final options = [
      (Goal.reduce, '📉', 'Reduce caffeine', 'Cut down to a healthier daily amount'),
      (Goal.quit, '🚫', 'Quit coffee completely', 'Get to zero and stay there'),
      (Goal.trackOnly, '👀', 'Just track my caffeine', 'No plan, no targets — just the numbers'),
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text("What's your goal?", style: AppText.h1(c.ink)),
      const SizedBox(height: 8),
      Text('You can change this later.', style: AppText.body(c.inkMuted)),
      const SizedBox(height: 24),
      Expanded(
        child: ListView.separated(
          itemCount: options.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) {
            final (g, emoji, title, sub) = options[i];
            return SelectRow(
              emoji: emoji,
              title: title,
              subtitle: sub,
              on: goal == g,
              onTap: () => setState(() => goal = g),
            );
          },
        ),
      ),
      TButton('Continue', onTap: next),
    ]);
  }

  Widget _consumptionStep() {
    final c = context.colors;
    return SingleChildScrollView(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('How much coffee do you drink?', style: AppText.h1(c.ink)),
        const SizedBox(height: 8),
        Text("A rough answer is fine — we'll refine it as you log.", style: AppText.body(c.inkMuted)),
        const SizedBox(height: 24),
        TCard(
          child: Column(children: [
            Text('Cups per day', style: AppText.label(c.inkMuted)),
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              _stepBtn(Icons.remove_rounded, () => setState(() => cups = (cups - 1).clamp(0, 15))),
              Text('$cups', style: AppText.num(c.ink, 44)),
              _stepBtn(Icons.add_rounded, () => setState(() => cups = (cups + 1).clamp(0, 15)), filled: true),
            ]),
          ]),
        ),
        const SizedBox(height: 20),
        Text('Usually drinks', style: AppText.label(c.inkMuted)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: kDrinks
              .map((d) => TChip(
                    d.label,
                    on: drinks.contains(d.type),
                    onTap: () => setState(() {
                      if (drinks.contains(d.type)) {
                        drinks.remove(d.type);
                      } else {
                        drinks.add(d.type);
                      }
                    }),
                  ))
              .toList(),
        ),
        const SizedBox(height: 20),
        TCard(
          flat: true,
          child: Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Estimated intake', style: AppText.tiny(c.inkMuted)),
                const SizedBox(height: 4),
                Text.rich(TextSpan(children: [
                  TextSpan(text: '$estimateMg mg', style: AppText.num(c.ink, 28)),
                  TextSpan(text: ' / day', style: AppText.body(c.inkMuted)),
                ])),
              ]),
            ),
            TPill(estimateMg > 300 ? 'Above average' : 'Typical', fg: c.warn, bg: c.warnSoft),
          ]),
        ),
        const SizedBox(height: 24),
        TButton('Continue', onTap: next),
      ]),
    );
  }

  Widget _stepBtn(IconData icon, VoidCallback onTap, {bool filled = false}) {
    final c = context.colors;
    return Material(
      color: filled ? c.coffee : c.surface2,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 46, height: 46,
          child: Icon(icon, size: 19, color: filled ? const Color(0xFFFFF9F1) : c.ink),
        ),
      ),
    );
  }

  Widget _methodStep() {
    final c = context.colors;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('How do you want to quit?', style: AppText.h1(c.ink)),
      const SizedBox(height: 8),
      Text('At $estimateMg mg a day, stopping suddenly usually means a rough couple of days.',
          style: AppText.body(c.inkMuted)),
      const SizedBox(height: 24),
      InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => setState(() => method = QuitMethod.gradual),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: method == QuitMethod.gradual ? c.coffeeSoft : c.surface,
            border: Border.all(color: method == QuitMethod.gradual ? c.coffee : c.line2, width: 1.4),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Text('🪜', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Gradually', style: AppText.h3(c.ink)),
                  const SizedBox(height: 3),
                  Text('Step down week by week', style: AppText.tiny(c.inkMuted)),
                ]),
              ),
              Icon(method == QuitMethod.gradual ? Icons.check_circle_rounded : Icons.circle_outlined,
                  color: method == QuitMethod.gradual ? c.accent : c.line2),
            ]),
            const SizedBox(height: 12),
            Row(
              children: [0.9, 0.72, 0.55, 0.4, 0.2]
                  .map((h) => Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(right: 6),
                          height: 8 + 26 * h,
                          decoration: BoxDecoration(
                            color: h == 0.2 ? c.accent : c.coffee.withOpacity(0.35 + h * 0.5),
                            borderRadius: BorderRadius.circular(9),
                          ),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 10),
            Text('Several weeks · fewer withdrawal symptoms', style: AppText.tiny(c.inkMuted)),
          ]),
        ),
      ),
      const SizedBox(height: 12),
      SelectRow(
        emoji: '✂️',
        title: 'Immediately',
        subtitle: 'Stop from your start date',
        on: method == QuitMethod.immediate,
        onTap: () => setState(() => method = QuitMethod.immediate),
      ),
      const Spacer(),
      TButton('Continue', onTap: next),
    ]);
  }

  Widget _planConfigStep() {
    final c = context.colors;
    final stepsList = method == QuitMethod.immediate ? [estimateMg, 0] : _steps().map((f) => (estimateMg * f).round()).toList();

    return SingleChildScrollView(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Your step-down', style: AppText.h1(c.ink)),
        const SizedBox(height: 8),
        Text('Built from $estimateMg mg a day. You can adjust this later from Plan.',
            style: AppText.body(c.inkMuted)),
        const SizedBox(height: 20),
        TCard(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
          child: Column(
            children: List.generate(stepsList.length, (i) {
              final label = i == 0 ? 'Now' : 'Week $i';
              final isLast = i == stepsList.length - 1;
              return Column(children: [
                Row(children: [
                  Container(
                    width: 10, height: 10,
                    decoration: BoxDecoration(
                        color: i == 0 ? c.coffee : (isLast ? c.accent : c.ring), shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(label, style: AppText.h3(c.ink))),
                  Text('${stepsList[i]} mg',
                      style: AppText.num(isLast && stepsList[i] == 0 ? c.accent : c.ink, 16)),
                ]),
                if (i != stepsList.length - 1)
                  Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Divider(color: c.line, height: 1)),
              ]);
            }),
          ),
        ),
        const SizedBox(height: 16),
        TInput(
          label: 'Start date',
          value: _fmtDate(startDate),
          icon: Icons.calendar_today_rounded,
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: startDate,
              firstDate: DateTime.now().subtract(const Duration(days: 1)),
              lastDate: DateTime.now().add(const Duration(days: 60)),
            );
            if (picked != null) setState(() => startDate = picked);
          },
        ),
        if (method == QuitMethod.gradual) ...[
          const SizedBox(height: 10),
          Text('Reduction speed', style: AppText.label(c.inkMuted)),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: TChip('Gentle', on: speed == ReductionSpeed.gentle, onTap: () => setState(() => speed = ReductionSpeed.gentle))),
            const SizedBox(width: 8),
            Expanded(child: TChip('Steady', on: speed == ReductionSpeed.steady, onTap: () => setState(() => speed = ReductionSpeed.steady))),
            const SizedBox(width: 8),
            Expanded(child: TChip('Fast', on: speed == ReductionSpeed.fast, onTap: () => setState(() => speed = ReductionSpeed.fast))),
          ]),
        ],
        const SizedBox(height: 24),
        TButton('Continue', onTap: next),
      ]),
    );
  }

  Widget _readyStep() {
    final c = context.colors;
    final stepsList = method == QuitMethod.immediate ? [estimateMg, 0] : _steps().map((f) => (estimateMg * f).round()).toList();
    final firstGoal = stepsList.length > 1 ? stepsList[1] : stepsList[0];
    final weeksCount = method == QuitMethod.immediate ? 0 : stepsList.length - 1;
    final targetDate = startDate.add(Duration(days: weeksCount * 7));

    return Column(children: [
      Expanded(
        child: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 76, height: 76,
              decoration: BoxDecoration(color: c.accentSoft, shape: BoxShape.circle),
              child: Icon(Icons.check_rounded, color: c.accent, size: 36),
            ),
            const SizedBox(height: 24),
            Text('Your plan is ready', style: AppText.h1(c.ink), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                weeksCount == 0
                    ? "You're starting from zero on ${_fmtDate(startDate)}. We'll help you through the first few days."
                    : "In $weeksCount weeks you'll be caffeine-free. We'll keep the daily target in front of you.",
                style: AppText.body(c.inkMuted),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            TCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('First daily goal', style: AppText.label(c.inkMuted)),
                  TPill('Starts ${_fmtDate(startDate)}', fg: c.accent, bg: c.accentSoft),
                ]),
                const SizedBox(height: 8),
                Text('$firstGoal mg', style: AppText.num(c.ink, 44)),
                const SizedBox(height: 16),
                Divider(color: c.line, height: 1),
                const SizedBox(height: 16),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('Coffee-free by', style: AppText.label(c.inkMuted)),
                  Text(_fmtDate(targetDate), style: AppText.num(c.ink, 17)),
                ]),
              ]),
            ),
          ]),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: TButton('Start my journey', style: TBtnStyle.accent, onTap: next),
      ),
    ]);
  }

  String _fmtDate(DateTime d) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${d.day} ${months[d.month - 1]}';
  }
}