import 'package:flutter/material.dart';
import '../main.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'week_detail_screen.dart';

class PlanScreen extends StatelessWidget {
  const PlanScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final app = context.app;
    final plan = app.plan;

    if (plan == null) {
      return AppScaffold(
        navIndex: 2,
        body: Column(children: [
          TopBar(title: 'My plan'),
          Expanded(
            child: EmptyState(
              icon: Icons.donut_large_rounded,
              title: "You don't have an active plan",
              subtitle: "We'll build a step-down from what you've logged so far.",
              ctaLabel: 'Create plan',
              onCta: () => Navigator.pushNamed(context, '/onboarding'),
            ),
          ),
        ]),
      );
    }

    final day = plan.dayNumber.clamp(1, plan.totalDays);
    final consumed = app.todayTotalMg;
    final limit = plan.currentDailyLimit;
    final remaining = (limit - consumed).clamp(0, 999999);

    return AppScaffold(
      navIndex: 2,
      body: Column(children: [
        TopBar(title: 'My plan', trailing: TIconButton(Icons.edit_outlined, onTap: () => Navigator.pushNamed(context, '/editPlan'))),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            children: [
              TCard(
                lift: true,
                child: Column(children: [
                  Row(children: [
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text.rich(TextSpan(children: [
                          TextSpan(text: '$day', style: AppText.num(c.ink, 40)),
                          TextSpan(text: ' / ${plan.totalDays}', style: AppText.num(c.inkMuted, 18)),
                        ])),
                        const SizedBox(height: 4),
                        Text('days into your plan', style: AppText.tiny(c.inkMuted)),
                      ]),
                    ),
                    ProgressRing(
                      value: plan.progress, size: 74, stroke: 8,
                      center: Text('${(plan.progress * 100).round()}%', style: AppText.num(c.ink, 13)),
                    ),
                  ]),
                  const SizedBox(height: 16),
                  Divider(color: c.line, height: 1),
                  const SizedBox(height: 16),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('Coffee-free by', style: AppText.label(c.inkMuted)),
                    Text(_fmtDate(plan.targetDate), style: AppText.num(c.ink, 16)),
                  ]),
                ]),
              ),
              const SizedBox(height: 16),
              TCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text("This week's target", style: AppText.h3(c.ink)),
                    TPill('Week ${plan.currentWeekIndex + 1}', fg: c.ink, bg: c.surface2),
                  ]),
                  const SizedBox(height: 16),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                    Column(children: [Text('$limit', style: AppText.num(c.ink, 26)), const SizedBox(height:4), Text('daily limit', style: AppText.tiny(c.inkMuted))]),
                    Column(children: [Text('$consumed', style: AppText.num(c.ink, 26)), const SizedBox(height:4), Text('consumed', style: AppText.tiny(c.inkMuted))]),
                    Column(children: [Text('$remaining', style: AppText.num(c.accent, 26)), const SizedBox(height:4), Text('remaining', style: AppText.tiny(c.inkMuted))]),
                  ]),
                  const SizedBox(height: 16),
                  TBar(value: limit == 0 ? 0 : consumed / limit),
                ]),
              ),
              const SizedBox(height: 24),
              Text('Weekly plan', style: AppText.h3(c.ink)),
              const SizedBox(height: 8),
              TCard(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                child: Column(
                  children: List.generate(plan.weeks.length, (i) {
                    final w = plan.weeks[i];
                    final isNow = i == plan.currentWeekIndex;
                    final isDone = i < plan.currentWeekIndex;
                    final isLocked = i > plan.currentWeekIndex;
                    return Column(children: [
                      InkWell(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => WeekDetailScreen(weekIndex: i))),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Opacity(
                            opacity: isLocked ? 0.5 : 1,
                            child: Row(children: [
                              Container(
                                width: 10, height: 10,
                                decoration: BoxDecoration(
                                    color: isNow ? c.accent : (isDone ? c.coffee : c.ring), shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 12),
                              Expanded(child: Text('Week ${w.weekNumber} · ${w.targetMg} mg', style: AppText.h3(c.ink))),
                              if (isDone) Icon(Icons.check_rounded, size: 16, color: c.coffee)
                              else if (isNow) TPill('In progress', fg: c.ink, bg: c.surface2)
                              else Icon(Icons.lock_outline_rounded, size: 15, color: c.inkMuted),
                            ]),
                          ),
                        ),
                      ),
                      if (i != plan.weeks.length - 1) Divider(color: c.line, height: 1),
                    ]);
                  }),
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }

  String _fmtDate(DateTime d) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${d.day} ${months[d.month - 1]}';
  }
}