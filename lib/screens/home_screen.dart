import 'package:flutter/material.dart';
import '../main.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets/common.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final app = context.app;
    final total = app.todayTotalMg;
    final limit = app.todayLimit;
    final remaining = limit - total;
    final over = remaining < 0;
    final ratio = limit == 0 ? 0.0 : total / limit;
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Good morning' : (hour < 18 ? 'Good afternoon' : 'Good evening');

    return AppScaffold(
      navIndex: 0,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('$greeting, ${app.profile.firstName} 👋', style: AppText.h2(c.ink)),
                const SizedBox(height: 4),
                Text(_todayLabel(), style: AppText.tiny(c.inkMuted)),
              ]),
            ),
            TIconButton(Icons.notifications_none_rounded, onTap: () {}),
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 21,
              backgroundColor: c.coffee,
              child: Text(app.profile.firstName.substring(0, 1),
                  style: const TextStyle(color: Color(0xFFFFF9F1), fontWeight: FontWeight.w700)),
            ),
          ]),
          const SizedBox(height: 18),
          TCard(
            lift: true,
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 16),
            child: Column(children: [
              ProgressRing(
                value: ratio,
                color: over ? c.warn : c.accent,
                center: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text.rich(TextSpan(children: [
                    TextSpan(text: '$total', style: AppText.num(c.ink, 46)),
                    TextSpan(text: ' mg', style: AppText.num(c.ink, 20)),
                  ])),
                  const SizedBox(height: 2),
                  Text('of $limit mg', style: AppText.label(c.inkMuted)),
                ]),
              ),
              const SizedBox(height: 14),
              Divider(color: c.line, height: 1),
              const SizedBox(height: 14),
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                Column(children: [
                  Text(over ? '+${-remaining} mg' : '$remaining mg',
                      style: AppText.num(over ? c.warn : c.accent, 19)),
                  const SizedBox(height: 3),
                  Text(over ? 'over limit' : 'remaining', style: AppText.tiny(c.inkMuted)),
                ]),
                Container(width: 1, height: 28, color: c.line),
                Column(children: [
                  Text('${app.todayEntries.length}', style: AppText.num(c.ink, 19)),
                  const SizedBox(height: 3),
                  Text('drinks today', style: AppText.tiny(c.inkMuted)),
                ]),
              ]),
            ]),
          ),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(
              flex: 21,
              child: TButton('Add coffee',
                  icon: Icons.add_rounded, onTap: () => _openAddCoffee(context)),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 16,
              child: TButton('I want coffee',
                  style: TBtnStyle.ghost, onTap: () => Navigator.pushNamed(context, '/craving')),
            ),
            const SizedBox(width: 10),
            TIconButton(Icons.list_alt_rounded,
                onTap: () => Navigator.pushNamed(context, '/tracking')),
          ]),
          const SizedBox(height: 16),
          if (over)
            InsightCard(
              icon: Icons.warning_amber_rounded,
              color: c.warn,
              text: "You're ${-remaining} mg over. Tomorrow starts fresh — the streak only counts days under your limit.",
            )
          else
            InsightCard(
              text: remaining > 0
                  ? 'You have $remaining mg left — about one small coffee. Save it for later if you can.'
                  : "You're exactly at your limit today. Nicely judged.",
            ),
          const SizedBox(height: 12),
          Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Expanded(
              flex: 4,
              child: TCard(
                padding: const EdgeInsets.all(15),
                child: app.lastCoffee == null
                    ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Last coffee', style: AppText.tiny(c.inkMuted)),
                        const SizedBox(height: 8),
                        Text('None yet today', style: AppText.h3(c.ink)),
                      ])
                    : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Last coffee', style: AppText.tiny(c.inkMuted)),
                        const SizedBox(height: 8),
                        Row(children: [
                          Text(drinkInfo(app.lastCoffee!.drink).emoji, style: const TextStyle(fontSize: 20)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(drinkInfo(app.lastCoffee!.drink).label, style: AppText.h3(c.ink)),
                              const SizedBox(height: 2),
                              Text('${app.lastCoffee!.mg} mg · ${fmtAgo(app.lastCoffee!.time)}',
                                  style: AppText.tiny(c.inkMuted)),
                            ]),
                          ),
                        ]),
                      ]),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: TCard(
                padding: const EdgeInsets.all(15),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    const Text('🔥', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Text('${app.streak}', style: AppText.num(c.ink, 24)),
                  ]),
                  const Spacer(),
                  Text('day streak', style: AppText.tiny(c.ink)),
                  Text('Keep going!', style: AppText.tiny(c.inkMuted)),
                ]),
              ),
            ),
          ]),
        ]),
      ),
    );
  }

  String _todayLabel() {
    const wd = ['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'];
    const mo = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final n = DateTime.now();
    return '${wd[n.weekday - 1]}, ${n.day} ${mo[n.month - 1]}';
  }

  void _openAddCoffee(BuildContext context) {
    showTaperSheet(context, const AddCoffeeFlow());
  }
}

/// Two-step bottom sheet: choose drink -> quantity/time -> save.
class AddCoffeeFlow extends StatefulWidget {
  const AddCoffeeFlow({super.key});
  @override
  State<AddCoffeeFlow> createState() => _AddCoffeeFlowState();
}

class _AddCoffeeFlowState extends State<AddCoffeeFlow> {
  DrinkType selected = DrinkType.espresso;
  int step = 0;
  int cups = 1;
  String size = 'Regular';
  DateTime time = DateTime.now();

  int get mg => (drinkInfo(selected).mgPerCup * cups * (size == 'Large' ? 1.3 : (size == 'Small' ? 0.7 : 1))).round();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final app = context.app;
    if (step == 0) {
      return SizedBox(
        height: 480,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text('What did you drink?', style: AppText.h2(c.ink))),
            TIconButton(Icons.close_rounded, plain: true, onTap: () => Navigator.pop(context)),
          ]),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: kDrinks.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final d = kDrinks[i];
                return SelectRow(
                  emoji: d.emoji,
                  title: d.label,
                  subtitle: '${d.mgPerCup} mg per cup',
                  on: selected == d.type,
                  onTap: () => setState(() => selected = d.type),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          TButton('Continue', onTap: () => setState(() => step = 1)),
        ]),
      );
    }

    final after = app.todayTotalMg + mg;
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Row(children: [
        Row(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: c.surface2, borderRadius: BorderRadius.circular(14)),
            alignment: Alignment.center,
            child: Text(drinkInfo(selected).emoji, style: const TextStyle(fontSize: 19)),
          ),
          const SizedBox(width: 10),
          Text(drinkInfo(selected).label, style: AppText.h2(c.ink)),
        ]),
        const Spacer(),
        TextButton(
          onPressed: () => setState(() => step = 0),
          child: Text('Change', style: AppText.tiny(c.coffee).copyWith(fontSize: 13)),
        ),
      ]),
      const SizedBox(height: 20),
      Align(alignment: Alignment.centerLeft, child: Text('Quantity', style: AppText.label(c.inkMuted))),
      const SizedBox(height: 8),
      Row(children: [
        Expanded(child: TChip('1 cup', on: cups == 1, onTap: () => setState(() => cups = 1))),
        const SizedBox(width: 8),
        Expanded(child: TChip('2 cups', on: cups == 2, onTap: () => setState(() => cups = 2))),
        const SizedBox(width: 8),
        Expanded(child: TChip('3 cups', on: cups == 3, onTap: () => setState(() => cups = 3))),
      ]),
      const SizedBox(height: 18),
      Align(alignment: Alignment.centerLeft, child: Text('Size', style: AppText.label(c.inkMuted))),
      const SizedBox(height: 8),
      Row(children: [
        Expanded(child: TChip('Small', on: size == 'Small', onTap: () => setState(() => size = 'Small'))),
        const SizedBox(width: 8),
        Expanded(child: TChip('Regular', on: size == 'Regular', onTap: () => setState(() => size = 'Regular'))),
        const SizedBox(width: 8),
        Expanded(child: TChip('Large', on: size == 'Large', onTap: () => setState(() => size = 'Large'))),
      ]),
      const SizedBox(height: 18),
      TInput(label: 'Time', value: fmtTime(time), icon: Icons.access_time_rounded, onTap: () async {
        final picked = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(time));
        if (picked != null) {
          setState(() {
            final now = DateTime.now();
            time = DateTime(now.year, now.month, now.day, picked.hour, picked.minute);
          });
        }
      }),
      const SizedBox(height: 16),
      TCard(
        flat: true,
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Estimated caffeine', style: AppText.tiny(c.inkMuted)),
              const SizedBox(height: 4),
              Text('$mg mg', style: AppText.num(c.ink, 30)),
            ]),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('After this', style: AppText.tiny(c.inkMuted)),
            const SizedBox(height: 4),
            Text('$after / ${app.todayLimit} mg', style: AppText.num(c.ink, 16)),
          ]),
        ]),
      ),
      const SizedBox(height: 16),
      TButton('Add coffee', onTap: () {
        app.addEntry(selected, cups, mg, time);
        Navigator.pop(context);
        showTaperToast(context, '${drinkInfo(selected).label} added · $mg mg');
      }),
    ]);
  }
}