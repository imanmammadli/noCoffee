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
    final plan = app.plan;
    if (plan == null || weekIndex >= plan.weeks.length) {
      return const AppScaffold(
        body: Column(children: [
          TopBar(title: 'Week', back: true),
          Expanded(child: SizedBox()),
        ]),
      );
    }
    final week = plan.weeks[weekIndex];
    final isCurrent = plan.hasStarted && weekIndex == plan.currentWeekIndex && !plan.isFinished;
    final isDone = plan.isWeekDone(weekIndex);

    final start = plan.weekStart(weekIndex);
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final days = [for (var i = 0; i < 7; i++) DateTime(start.year, start.month, start.day + i)];
    final totals = [
      for (final d in days)
        app.entries
            .where((e) => e.time.year == d.year && e.time.month == d.month && e.time.day == d.day)
            .fold<int>(0, (s, e) => s + e.mg)
    ];
    final past = [for (final d in days) d.isBefore(today)];
    final passedCount = past.where((p) => p).length;
    final underCount = [for (var i = 0; i < 7; i++) if (past[i] && totals[i] <= week.targetMg) 1].length;
    final sumPast = [for (var i = 0; i < 7; i++) if (past[i]) totals[i]].fold<int>(0, (a, b) => a + b);
    final avg = passedCount == 0 ? 0 : (sumPast / passedCount).round();
    final freeDays = [for (var i = 0; i < 7; i++) if (past[i] && totals[i] == 0) 1].length;
    final maxMg = [week.targetMg, ...totals, 1].reduce((a, b) => a > b ? a : b);

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
                    TPill(isCurrent ? 'This week' : (isDone ? 'Completed' : 'Upcoming'),
                        fg: c.ink, bg: c.surface2),
                  ]),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 96,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(7, (i) {
                        final shown = past[i] || days[i] == today;
                        final h = shown ? totals[i] / maxMg : 0.0;
                        final over = totals[i] > week.targetMg;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            child: Container(
                              height: (h * 90).clamp(8, 90).toDouble(),
                              decoration: BoxDecoration(
                                color: !shown
                                    ? c.coffee.withValues(alpha: 0.15)
                                    : (over ? c.warn : c.coffee),
                                borderRadius: BorderRadius.circular(7),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                      children: [for (final d in days) d.weekday]
                          .map((w) => Expanded(
                              child: Text(['M', 'T', 'W', 'T', 'F', 'S', 'S'][w - 1],
                                  style: AppText.tiny(c.inkMuted), textAlign: TextAlign.center)))
                          .toList()),
                ]),
              ),
              const SizedBox(height: 16),
              TCard(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                child: Column(children: [
                  _row(context, 'Days under limit', '$underCount of $passedCount'),
                  Divider(color: c.line, height: 1),
                  _row(context, 'Average per day', '$avg mg'),
                  Divider(color: c.line, height: 1),
                  _row(context, 'Coffee-free days', '$freeDays', color: c.accent),
                ]),
              ),
              const SizedBox(height: 16),
              if (isCurrent && weekIndex < plan.weeks.length - 1)
                TButton('Start next week early', style: TBtnStyle.secondary, onTap: () {
                  plan.startNextWeekNow();
                  app.refresh();
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
