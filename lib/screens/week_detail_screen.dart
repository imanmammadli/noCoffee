import 'package:flutter/material.dart';
import '../main.dart';
import '../theme.dart';
import '../widgets/common.dart';

class WeekDetailScreen extends StatelessWidget {
  final int weekIndex;
  const WeekDetailScreen({super.key, this.weekIndex = 0});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final app = context.app;
    final plan = app.plan!;
    final week = plan.weeks[weekIndex];
    final isCurrent = weekIndex == plan.currentWeekIndex;

    return AppScaffold(
      body: Column(children: [
        TopBar(title: 'Week ${week.weekNumber}', back: true),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            children: [
              TCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Daily limit this week', style: AppText.tiny(c.inkMuted)),
                      const SizedBox(height: 4),
                      Text('${week.targetMg} mg', style: AppText.num(c.ink, 38)),
                    ]),
                    TPill(isCurrent ? 'This week' : (week.completed ? 'Completed' : 'Upcoming'),
                        fg: c.ink, bg: c.surface2),
                  ]),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 96,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(7, (i) {
                        final active = isCurrent && i < 5;
                        final h = active ? (0.3 + (i * 37) % 60 / 100) : 0.22;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            child: Container(
                              height: (h * 90).clamp(10, 90),
                              decoration: BoxDecoration(
                                color: active ? c.coffee : c.coffee.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(7),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(children: ['M','T','W','T','F','S','S'].map((d) => Expanded(child: Text(d, style: AppText.tiny(c.inkMuted), textAlign: TextAlign.center))).toList()),
                ]),
              ),
              const SizedBox(height: 16),
              TCard(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                child: Column(children: [
                  _row(context, 'Days under limit', '4 of 5'),
                  Divider(color: c.line, height: 1),
                  _row(context, 'Average so far', '${(week.targetMg * 0.9).round()} mg'),
                  Divider(color: c.line, height: 1),
                  _row(context, 'Coffee-free days', '${app.coffeeFreeDaysCount}', color: c.accent),
                  Divider(color: c.line, height: 1),
                  _row(context, 'Cravings resisted', '${app.cravingsResisted}'),
                ]),
              ),
              const SizedBox(height: 16),
              const InsightCard(text: "You're averaging under target. The next step could start a couple of days early if you want it to."),
              const SizedBox(height: 12),
              if (isCurrent && weekIndex < plan.weeks.length - 1)
                TButton('Start next week early', style: TBtnStyle.secondary, onTap: () {
                  week.completed = true;
                  plan.currentWeekIndex++;
                  plan.currentDailyLimit = plan.weeks[plan.currentWeekIndex].targetMg;
                  Navigator.pop(context);
                  showTaperToast(context, 'Week ${plan.currentWeekIndex + 1} started');
                }),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _row(BuildContext context, String label, String value, {Color? color}) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: AppText.label(c.inkMuted)),
        Text(value, style: AppText.num(color ?? c.ink, 16)),
      ]),
    );
  }
}