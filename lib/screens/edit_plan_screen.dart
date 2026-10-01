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
  late QuitMethod method;
  double speed = 0.5; // 0 gentle .. 1 fast
  bool loaded = false;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final app = context.app;
    final plan = app.plan!;
    if (!loaded) {
      method = plan.method;
      loaded = true;
    }
    final weeksLabel = speed < 0.34 ? '8 weeks to zero' : (speed < 0.67 ? '5 weeks to zero' : '3 weeks to zero');

    return AppScaffold(
      body: Column(children: [
        TopBar(title: 'Edit plan', back: true),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            children: [
              Text('Quit method', style: AppText.label(c.inkMuted)),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(child: TChip('Gradually', on: method == QuitMethod.gradual, onTap: () => setState(() => method = QuitMethod.gradual))),
                const SizedBox(width: 8),
                Expanded(child: TChip('Immediately', on: method == QuitMethod.immediate, onTap: () => setState(() => method = QuitMethod.immediate))),
              ]),
              const SizedBox(height: 20),
              TInput(label: 'Start date', value: _fmt(plan.startDate), icon: Icons.calendar_today_rounded),
              const SizedBox(height: 10),
              TInput(label: 'Target date', value: _fmt(plan.targetDate), icon: Icons.calendar_today_rounded),
              const SizedBox(height: 10),
              TInput(label: "Today's limit", value: '${plan.currentDailyLimit} mg', icon: Icons.coffee_rounded),
              if (method == QuitMethod.gradual) ...[
                const SizedBox(height: 20),
                Text('Reduction speed', style: AppText.label(c.inkMuted)),
                const SizedBox(height: 8),
                TCard(
                  child: Column(children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text(speed < 0.34 ? 'Gentle' : (speed < 0.67 ? 'Steady' : 'Fast'), style: AppText.h3(c.ink)),
                      Text(weeksLabel, style: AppText.tiny(c.inkMuted)),
                    ]),
                    SliderTheme(
                      data: SliderThemeData(
                        activeTrackColor: c.accent,
                        inactiveTrackColor: c.surface2,
                        thumbColor: c.surface,
                        overlayColor: c.accent.withOpacity(0.15),
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12, elevation: 2),
                      ),
                      child: Slider(value: speed, onChanged: (v) => setState(() => speed = v)),
                    ),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('Gentle · 8 weeks', style: AppText.tiny(c.inkMuted)),
                      Text('Fast · 3 weeks', style: AppText.tiny(c.inkMuted)),
                    ]),
                  ]),
                ),
                const SizedBox(height: 16),
                TCard(
                  flat: true,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('New plan preview', style: AppText.tiny(c.inkMuted)),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 60,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [1.0, 0.8, 0.64, 0.4, 0.26, 0.1].map((h) {
                          final isLast = h == 0.1;
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 3),
                              child: Container(
                                height: (h * 60).clamp(6, 60),
                                decoration: BoxDecoration(
                                    color: isLast ? c.accent : c.coffeeSoft, borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ]),
                ),
              ],
              const SizedBox(height: 24),
              TButton('Save plan', onTap: () {
                plan.method = method;
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