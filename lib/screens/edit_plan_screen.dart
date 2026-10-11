import 'package:flutter/material.dart';
import '../main.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets/common.dart';

class EditPlanScreen extends StatefulWidget {
  const EditPlanScreen({super.key});
  @override
  State<EditPlanScreen> createState() => _EditPlanScreenState();
}

class _EditPlanScreenState extends State<EditPlanScreen> {
  Goal? goal;
  QuitMethod? method;
  ReductionSpeed? speed;
  DateTime? startDate;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final app = context.app;
    final current = app.plan;
    if (current == null) {
      return const AppScaffold(
        body: Column(children: [
          TopBar(title: 'Edit plan', back: true),
          Expanded(child: SizedBox()),
        ]),
      );
    }
    goal ??= current.goal == Goal.trackOnly ? Goal.reduce : current.goal;
    method ??= current.method;
    speed ??= current.speed;
    startDate ??= current.startDate;

    final preview = Plan.build(
      goal: goal!,
      method: method!,
      speed: speed!,
      startDate: startDate!,
      baselineMg: current.baselineMg,
    );

    return AppScaffold(
      body: Column(children: [
        const TopBar(title: 'Edit plan', back: true),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            children: [
              Text('Goal', style: AppText.label(c.inkMuted)),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(child: TChip('Reduce', on: goal == Goal.reduce, onTap: () => setState(() => goal = Goal.reduce))),
                const SizedBox(width: 8),
                Expanded(child: TChip('Quit completely', on: goal == Goal.quit, onTap: () => setState(() => goal = Goal.quit))),
              ]),
              const SizedBox(height: 20),
              Text('Quit method', style: AppText.label(c.inkMuted)),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(child: TChip('Gradually', on: method == QuitMethod.gradual, onTap: () => setState(() => method = QuitMethod.gradual))),
                const SizedBox(width: 8),
                Expanded(child: TChip('Immediately', on: method == QuitMethod.immediate, onTap: () => setState(() => method = QuitMethod.immediate))),
              ]),
              const SizedBox(height: 20),
              TInput(
                label: 'Start date',
                value: _fmt(startDate!),
                icon: Icons.calendar_today_rounded,
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: startDate!,
                    firstDate: DateTime.now().subtract(const Duration(days: 60)),
                    lastDate: DateTime.now().add(const Duration(days: 90)),
                  );
                  if (picked != null) setState(() => startDate = picked);
                },
              ),
              const SizedBox(height: 10),
              TInput(label: 'End date', value: _fmt(preview.targetDate), icon: Icons.calendar_today_rounded),
              if (method == QuitMethod.gradual) ...[
                const SizedBox(height: 20),
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
              const SizedBox(height: 16),
              TCard(
                flat: true,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('New plan preview · ${preview.weeks.length} weeks', style: AppText.tiny(c.inkMuted)),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 60,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: preview.weeks.map((w) {
                        final base = preview.baselineMg == 0 ? 1 : preview.baselineMg;
                        final isLast = w == preview.weeks.last;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            child: Container(
                              height: (w.targetMg / base * 60).clamp(6, 60).toDouble(),
                              decoration: BoxDecoration(
                                  color: isLast ? c.accent : c.coffeeSoft, borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text('Baseline ${preview.baselineMg} mg → ${preview.finalTargetMg} mg a day',
                      style: AppText.tiny(c.inkMuted)),
                ]),
              ),
              const SizedBox(height: 24),
              TButton('Save plan', onTap: () {
                app.plan = preview;
                app.refresh();
                Navigator.pop(context);
                showTaperToast(context, 'Plan saved');
              }),
            ],
          ),
        ),
      ]),
    );
  }

  String _fmt(DateTime d) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${d.day} ${months[d.month - 1]}';
  }
}
