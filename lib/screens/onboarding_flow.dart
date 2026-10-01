import 'package:flutter/material.dart';
import '../main.dart';
import '../models.dart';
import '../state.dart';
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

  void next() {
    if (step < totalSteps - 1) {
      setState(() => step++);
    } else {
      context.app.completeOnboarding();
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final app = context.app;
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
              child: _stepBody(context, app),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _stepBody(BuildContext context, AppState app) {
    switch (step) {
      case 0:
        return _GoalStep(onNext: next);
      case 1:
        return _ConsumptionStep(onNext: next);
      case 2:
        return _MethodStep(onNext: next);
      case 3:
        return _PlanConfigStep(onNext: next);
      default:
        return _ReadyStep(onDone: next);
    }
  }
}

class _GoalStep extends StatefulWidget {
  final VoidCallback onNext;
  const _GoalStep({required this.onNext});
  @override
  State<_GoalStep> createState() => _GoalStepState();
}

class _GoalStepState extends State<_GoalStep> {
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final app = context.app;
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
            final (goal, emoji, title, sub) = options[i];
            return SelectRow(
              emoji: emoji,
              title: title,
              subtitle: sub,
              on: app.onboardingGoal == goal,
              onTap: () => setState(() => app.onboardingGoal = goal),
            );
          },
        ),
      ),
      TButton('Continue', onTap: widget.onNext),
    ]);
  }
}

class _ConsumptionStep extends StatefulWidget {
  final VoidCallback onNext;
  const _ConsumptionStep({required this.onNext});
  @override
  State<_ConsumptionStep> createState() => _ConsumptionStepState();
}

class _ConsumptionStepState extends State<_ConsumptionStep> {
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final app = context.app;
    final estimate = app.onboardingCups * 90;
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
              _stepBtn(context, Icons.remove_rounded,
                  () => setState(() => app.onboardingCups = (app.onboardingCups - 1).clamp(0, 15))),
              Text('${app.onboardingCups}', style: AppText.num(c.ink, 44)),
              _stepBtn(context, Icons.add_rounded,
                  () => setState(() => app.onboardingCups = (app.onboardingCups + 1).clamp(0, 15)),
                  filled: true),
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
                    on: app.onboardingUsualDrinks.contains(d.type),
                    onTap: () => setState(() {
                      if (app.onboardingUsualDrinks.contains(d.type)) {
                        app.onboardingUsualDrinks.remove(d.type);
                      } else {
                        app.onboardingUsualDrinks.add(d.type);
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
                  TextSpan(text: '$estimate mg', style: AppText.num(c.ink, 28)),
                  TextSpan(text: ' / day', style: AppText.body(c.inkMuted)),
                ])),
              ]),
            ),
            TPill(estimate > 300 ? 'Above average' : 'Typical',
                fg: c.warn, bg: c.warnSoft),
          ]),
        ),
        const SizedBox(height: 24),
        TButton('Continue', onTap: widget.onNext),
      ]),
    );
  }

  Widget _stepBtn(BuildContext context, IconData icon, VoidCallback onTap, {bool filled = false}) {
    final c = context.colors;
    return Material(
      color: filled ? c.coffee : c.surface2,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 46,
          height: 46,
          child: Icon(icon, size: 19, color: filled ? const Color(0xFFFFF9F1) : c.ink),
        ),
      ),
    );
  }
}

class _MethodStep extends StatefulWidget {
  final VoidCallback onNext;
  const _MethodStep({required this.onNext});
  @override
  State<_MethodStep> createState() => _MethodStepState();
}

class _MethodStepState extends State<_MethodStep> {
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final app = context.app;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('How do you want to quit?', style: AppText.h1(c.ink)),
      const SizedBox(height: 8),
      Text('At ${app.onboardingCups * 90} mg a day, stopping suddenly usually means a rough couple of days.',
          style: AppText.body(c.inkMuted)),
      const SizedBox(height: 24),
      InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => setState(() => app.onboardingMethod = QuitMethod.gradual),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: app.onboardingMethod == QuitMethod.gradual ? c.coffeeSoft : c.surface,
            border: Border.all(
                color: app.onboardingMethod == QuitMethod.gradual ? c.coffee : c.line2, width: 1.4),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text('🪜', style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Gradually', style: AppText.h3(c.ink)),
                  const SizedBox(height: 3),
                  Text('Step down week by week', style: AppText.tiny(c.inkMuted)),
                ]),
              ),
              Icon(
                  app.onboardingMethod == QuitMethod.gradual
                      ? Icons.check_circle_rounded
                      : Icons.circle_outlined,
                  color: app.onboardingMethod == QuitMethod.gradual ? c.accent : c.line2),
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
            Text('~5 weeks · fewer withdrawal symptoms', style: AppText.tiny(c.inkMuted)),
          ]),
        ),
      ),
      const SizedBox(height: 12),
      SelectRow(
        emoji: '✂️',
        title: 'Immediately',
        subtitle: 'Stop from your start date',
        on: app.onboardingMethod == QuitMethod.immediate,
        onTap: () => setState(() => app.onboardingMethod = QuitMethod.immediate),
      ),
      const Spacer(),
      TButton('Continue', onTap: widget.onNext),
    ]);
  }
}

class _PlanConfigStep extends StatelessWidget {
  final VoidCallback onNext;
  const _PlanConfigStep({required this.onNext});
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final app = context.app;
    final estimate = app.onboardingCups * 90;
    final steps = app.onboardingMethod == QuitMethod.immediate
        ? [estimate, 0]
        : (app.onboardingGoal == Goal.quit
            ? [estimate, (estimate * .75).round(), (estimate * .625).round(), (estimate * .375).round(), (estimate * .25).round(), 0]
            : [estimate, (estimate * .8).round(), (estimate * .65).round(), (estimate * .55).round(), (estimate * .45).round()]);

    return SingleChildScrollView(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Your step-down', style: AppText.h1(c.ink)),
        const SizedBox(height: 8),
        Text('Built from $estimate mg a day. You can adjust this later from Plan.',
            style: AppText.body(c.inkMuted)),
        const SizedBox(height: 20),
        TCard(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
          child: Column(
            children: List.generate(steps.length, (i) {
              final label = i == 0 ? 'Now' : 'Week $i';
              final isLast = i == steps.length - 1;
              return Column(children: [
                Row(children: [
                  Container(
                    width: 10, height: 10,
                    decoration: BoxDecoration(
                        color: i == 0 ? c.coffee : (isLast ? c.accent : c.ring), shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(label, style: AppText.h3(c.ink))),
                  Text('${steps[i]} mg',
                      style: AppText.num(isLast && steps[i] == 0 ? c.accent : c.ink, 16)),
                ]),
                if (i != steps.length - 1) Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Divider(color: c.line, height: 1)),
              ]);
            }),
          ),
        ),
        const SizedBox(height: 16),
        TInput(label: 'Start date', value: 'Today', icon: Icons.calendar_today_rounded),
        const SizedBox(height: 10),
        TInput(label: 'Reduction speed', value: 'Steady', icon: Icons.speed_rounded),
        const SizedBox(height: 24),
        TButton('Continue', onTap: onNext),
      ]),
    );
  }
}

class _ReadyStep extends StatelessWidget {
  final VoidCallback onDone;
  const _ReadyStep({required this.onDone});
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final app = context.app;
    final estimate = app.onboardingCups * 90;
    final firstGoal = app.onboardingMethod == QuitMethod.immediate
        ? 0
        : (app.onboardingGoal == Goal.quit ? (estimate * .75).round() : (estimate * .8).round());
    final weeks = app.onboardingMethod == QuitMethod.immediate ? 0 : (app.onboardingGoal == Goal.quit ? 5 : 4);
    final targetDate = DateTime.now().add(Duration(days: weeks * 7));
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
                weeks == 0
                    ? "You're starting from zero today. We'll help you through the first few days."
                    : "In $weeks weeks you'll be caffeine-free. We'll keep the daily target in front of you.",
                style: AppText.body(c.inkMuted),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            TCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('First daily goal', style: AppText.label(c.inkMuted)),
                  TPill('Starts today', fg: context.colors.accent, bg: context.colors.accentSoft),
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
        child: TButton('Start my journey', style: TBtnStyle.accent, onTap: onDone),
      ),
    ]);
  }

  String _fmtDate(DateTime d) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${d.day} ${months[d.month - 1]}';
  }
}