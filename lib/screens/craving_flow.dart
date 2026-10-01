import 'dart:async';
import 'package:flutter/material.dart';
import '../main.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets/common.dart';

class CravingFlow extends StatefulWidget {
  const CravingFlow({super.key});
  @override
  State<CravingFlow> createState() => _CravingFlowState();
}

class _CravingFlowState extends State<CravingFlow> {
  int step = 0;
  int level = 4;

  @override
  Widget build(BuildContext context) {
    switch (step) {
      case 0:
        return _LevelStep(
          level: level,
          onChange: (v) => setState(() => level = v),
          onNext: () => setState(() => step = 1),
        );
      case 1:
        return _SupportStep(level: level, onNext: () => setState(() => step = 2));
      default:
        return _ResultStep(level: level);
    }
  }
}

class _LevelStep extends StatelessWidget {
  final int level;
  final ValueChanged<int> onChange;
  final VoidCallback onNext;
  const _LevelStep({required this.level, required this.onChange, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              TIconButton(Icons.close_rounded, plain: true, onTap: () => Navigator.pop(context)),
              const Spacer(),
              Text('Craving support', style: AppText.tiny(c.inkMuted)),
            ]),
            const SizedBox(height: 18),
            Text('How strong is your craving?', style: AppText.h1(c.ink)),
            const SizedBox(height: 8),
            Text('No wrong answer. This helps us learn your pattern.', style: AppText.body(c.inkMuted)),
            const SizedBox(height: 32),
            SizedBox(
              height: 150,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(5, (i) {
                  final v = i + 1;
                  final on = v == level;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => onChange(v),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          height: 30.0 + v * 24,
                          decoration: BoxDecoration(
                            color: on ? c.coffee : c.surface2,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: on
                                ? [BoxShadow(color: c.coffee.withOpacity(.4), blurRadius: 14, offset: const Offset(0, 6))]
                                : null,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('1 · Very low', style: AppText.tiny(c.inkMuted)),
              Text('5 · Very strong', style: AppText.tiny(c.inkMuted)),
            ]),
            const SizedBox(height: 24),
            TCard(
              flat: true,
              child: Column(children: [
                Text('$level', style: AppText.num(c.ink, 36)),
                const SizedBox(height: 8),
                Text(
                  level >= 4 ? "Strong — you've beaten this before" : "You've got this",
                  style: AppText.body(c.ink).copyWith(fontWeight: FontWeight.w600),
                ),
              ]),
            ),
            const Spacer(),
            TButton('Help me through it', onTap: onNext),
          ]),
        ),
      ),
    );
  }
}

class _SupportStep extends StatefulWidget {
  final int level;
  final VoidCallback onNext;
  const _SupportStep({required this.level, required this.onNext});
  @override
  State<_SupportStep> createState() => _SupportStepState();
}

class _SupportStepState extends State<_SupportStep> {
  int? selected = 2;
  int secondsLeft = 5 * 60;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => secondsLeft = (secondsLeft - 1).clamp(0, 999999));
      if (secondsLeft <= 0) t.cancel();
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  static const options = [
    ('💧', 'Drink a glass of water', 'Thirst copies caffeine withdrawal'),
    ('🚶', 'Walk for 5 minutes', 'Outside if you can'),
    ('🧘', 'Breathing exercise', '4 in, 7 hold, 8 out · 90 seconds'),
    ('🍎', 'Have a light snack', 'Something with protein'),
    ('⏱️', 'Just wait 5 minutes', 'Then decide'),
  ];

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final m = secondsLeft ~/ 60, s = secondsLeft % 60;
    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              TIconButton(Icons.arrow_back_ios_new_rounded, plain: true, onTap: () => Navigator.pop(context)),
              const Spacer(),
              TPill('Level ${widget.level}', fg: c.inkMuted, bg: c.surface2),
            ]),
            const SizedBox(height: 16),
            Text('Try one of these first', style: AppText.h1(c.ink)),
            const SizedBox(height: 8),
            Text("Pick anything. We'll check back in five minutes.", style: AppText.body(c.inkMuted)),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.separated(
                itemCount: options.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final (emoji, title, sub) = options[i];
                  return SelectRow(
                    emoji: emoji, title: title, subtitle: sub,
                    on: selected == i,
                    onTap: () => setState(() => selected = i),
                  );
                },
              ),
            ),
            const SizedBox(height: 14),
            TCard(
              flat: true,
              child: Row(children: [
                Icon(Icons.access_time_rounded, size: 17, color: c.inkMuted),
                const SizedBox(width: 10),
                Text('Timer running', style: AppText.body(c.ink).copyWith(fontWeight: FontWeight.w600, fontSize: 13.5)),
                const Spacer(),
                Text('${m.toString().padLeft(1,'0')}:${s.toString().padLeft(2,'0')}', style: AppText.num(c.ink, 19)),
              ]),
            ),
            const SizedBox(height: 12),
            TButton('Skip to result', style: TBtnStyle.secondary, onTap: widget.onNext),
          ]),
        ),
      ),
    );
  }
}

class _ResultStep extends StatelessWidget {
  final int level;
  const _ResultStep({required this.level});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(children: [
            Row(children: [
              Text('Craving · ${fmtTimeNow()}', style: AppText.tiny(c.inkMuted)),
              const Spacer(),
              TPill('Level $level', fg: c.inkMuted, bg: c.surface2),
            ]),
            Expanded(
              child: Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                    width: 72, height: 72,
                    decoration: BoxDecoration(color: c.surface2, borderRadius: BorderRadius.circular(26)),
                    alignment: Alignment.center,
                    child: const Text('☕', style: TextStyle(fontSize: 32)),
                  ),
                  const SizedBox(height: 24),
                  Text('Did you resist the craving?', style: AppText.h1(c.ink), textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Text('Either answer is useful. Honest data makes better plans.',
                      style: AppText.body(c.inkMuted), textAlign: TextAlign.center),
                ]),
              ),
            ),
            TButton('Yes, I resisted', style: TBtnStyle.accent, onTap: () {
              context.app.logCraving(level, true);
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const _CelebrateResisted()));
            }),
            const SizedBox(height: 12),
            TButton('No, I had coffee', style: TBtnStyle.secondary, onTap: () {
              context.app.logCraving(level, false);
              Navigator.pop(context);
              showTaperSheet(context, const _AddAfterCravingNote());
            }),
          ]),
        ),
      ),
    );
  }

  String fmtTimeNow() => fmtTime(DateTime.now());
}

class _AddAfterCravingNote extends StatelessWidget {
  const _AddAfterCravingNote();
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Text('Logged. No judgment here.', style: AppText.h3(c.ink)),
      const SizedBox(height: 8),
      Text('Head to Home to add the coffee whenever you\'re ready.',
          style: AppText.body(c.inkMuted), textAlign: TextAlign.center),
      const SizedBox(height: 16),
      TButton('Back to home', onTap: () => Navigator.pop(context)),
    ]);
  }
}

class _CelebrateResisted extends StatelessWidget {
  const _CelebrateResisted();
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final app = context.app;
    final resisted = app.cravingsResisted;
    final total = app.cravingsTotal;
    final rate = total == 0 ? 0 : (resisted / total * 100).round();
    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(children: [
            Expanded(
              child: Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                    width: 88, height: 88,
                    decoration: BoxDecoration(color: c.accentSoft, shape: BoxShape.circle),
                    alignment: Alignment.center,
                    child: const Text('🔥', style: TextStyle(fontSize: 40)),
                  ),
                  const SizedBox(height: 24),
                  Text('You resisted the craving', style: AppText.h1(c.ink), textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                        "That's $resisted of your last $total. Keep noticing what makes it easier.",
                        style: AppText.body(c.inkMuted), textAlign: TextAlign.center),
                  ),
                  const SizedBox(height: 24),
                  TCard(
                    child: Column(children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                        Column(children: [Text('$resisted', style: AppText.num(c.accent, 24)), const SizedBox(height: 4), Text('resisted', style: AppText.tiny(c.inkMuted))]),
                        Column(children: [Text('${total - resisted}', style: AppText.num(c.ink, 24)), const SizedBox(height: 4), Text('gave in', style: AppText.tiny(c.inkMuted))]),
                        Column(children: [Text('$rate%', style: AppText.num(c.ink, 24)), const SizedBox(height: 4), Text('success rate', style: AppText.tiny(c.inkMuted))]),
                      ]),
                      const SizedBox(height: 14),
                      TBar(value: total == 0 ? 0 : resisted / total),
                    ]),
                  ),
                  const SizedBox(height: 12),
                  InsightCard(icon: Icons.savings_rounded, text: 'That\'s ${app.profile.coffeePrice.toStringAsFixed(2)} ${app.profile.currency} you didn\'t spend today.'),
                ]),
              ),
            ),
            TButton('Back to home', onTap: () => Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false)),
          ]),
        ),
      ),
    );
  }
}