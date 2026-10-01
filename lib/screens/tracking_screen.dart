import 'package:flutter/material.dart';
import '../main.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets/common.dart';

class TrackingScreen extends StatelessWidget {
  const TrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final app = context.app;
    final entries = app.todayEntries;
    return AppScaffold(
      navIndex: 1,
      body: Column(children: [
        TopBar(title: 'Tracking', trailing: TIconButton(Icons.calendar_today_rounded, onTap: () => Navigator.pushNamed(context, '/history'))),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            children: [
              Row(children: [
                TChip('Today', on: true),
                const SizedBox(width: 8),
                TChip('Yesterday'),
                const SizedBox(width: 8),
                TChip('Calendar', icon: Icons.calendar_today_rounded,
                    onTap: () => Navigator.pushNamed(context, '/history')),
              ]),
              const SizedBox(height: 16),
              TCard(
                child: Column(children: [
                  Row(children: [
                    _stat(context, '${app.todayTotalMg}', 'mg caffeine'),
                    _stat(context, '${entries.length}', 'drinks'),
                    _stat(context, '${app.todayLimit}', 'daily limit'),
                    _stat(context, '${app.todayRemaining}', 'remaining', color: c.accent),
                  ]),
                  const SizedBox(height: 16),
                  TBar(value: app.todayLimit == 0 ? 0 : app.todayTotalMg / app.todayLimit),
                ]),
              ),
              const SizedBox(height: 24),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Timeline', style: AppText.h3(c.ink)),
                Text('${entries.length} entries', style: AppText.tiny(c.inkMuted)),
              ]),
              const SizedBox(height: 8),
              if (entries.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: EmptyState(
                    icon: Icons.coffee_rounded,
                    title: 'No coffee logged today',
                    subtitle: 'Nice. Log one if that changes.',
                    ctaLabel: 'Add coffee',
                    onCta: () => Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false),
                  ),
                )
              else
                Column(
                  children: entries
                      .map((e) => Dismissible(
                            key: ValueKey(e.id),
                            direction: DismissDirection.endToStart,
                            confirmDismiss: (_) => _confirmDelete(context, e),
                            onDismissed: (_) {
                              app.deleteEntry(e.id);
                              showTaperToast(context, 'Entry deleted');
                            },
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              child: Icon(Icons.delete_outline_rounded, color: c.danger),
                            ),
                            child: InkWell(
                              onTap: () => Navigator.push(context,
                                  MaterialPageRoute(builder: (_) => EditEntryScreen(entryId: e.id))),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                child: Row(children: [
                                  SizedBox(width: 46, child: Text(fmtTime(e.time), style: AppText.tiny(c.inkMuted))),
                                  Container(
                                    width: 44, height: 44,
                                    decoration: BoxDecoration(color: c.surface2, borderRadius: BorderRadius.circular(15)),
                                    alignment: Alignment.center,
                                    child: Text(drinkInfo(e.drink).emoji, style: const TextStyle(fontSize: 19)),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      Text(drinkInfo(e.drink).label, style: AppText.h3(c.ink)),
                                      const SizedBox(height: 2),
                                      Text('${e.cups} cup${e.cups > 1 ? 's' : ''}', style: AppText.tiny(c.inkMuted)),
                                    ]),
                                  ),
                                  Text('${e.mg} mg', style: AppText.num(c.ink, 17)),
                                ]),
                              ),
                            ),
                          ))
                      .toList()
                      .expand((w) => [w, Divider(color: c.line, height: 1)])
                      .toList()
                    ..removeLast(),
                ),
              const SizedBox(height: 16),
              if (entries.isNotEmpty)
                const InsightCard(text: 'Swipe an entry left to delete, or tap it to edit.'),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _stat(BuildContext context, String value, String label, {Color? color}) {
    final c = context.colors;
    return Expanded(
      child: Column(children: [
        Text(value, style: AppText.num(color ?? c.ink, 26)),
        const SizedBox(height: 4),
        Text(label, style: AppText.tiny(c.inkMuted), textAlign: TextAlign.center),
      ]),
    );
  }

  Future<bool> _confirmDelete(BuildContext context, CoffeeEntry e) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => _DeleteDialog(entry: e),
    );
    return result ?? false;
  }
}

class _DeleteDialog extends StatelessWidget {
  final CoffeeEntry entry;
  const _DeleteDialog({required this.entry});
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Dialog(
      backgroundColor: c.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 54, height: 54,
            decoration: BoxDecoration(color: c.dangerSoft, shape: BoxShape.circle),
            child: Icon(Icons.delete_outline_rounded, color: c.danger, size: 24),
          ),
          const SizedBox(height: 16),
          Text('Delete this entry?', style: AppText.h2(c.ink)),
          const SizedBox(height: 8),
          Text(
            'This removes the ${drinkInfo(entry.drink).label.toLowerCase()} at ${fmtTime(entry.time)} from your history.',
            style: AppText.body(c.inkMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(children: [
            Expanded(child: TButton('Cancel', style: TBtnStyle.secondary, small: true, onTap: () => Navigator.pop(context, false))),
            const SizedBox(width: 10),
            Expanded(child: TButton('Delete', style: TBtnStyle.danger, small: true, onTap: () => Navigator.pop(context, true))),
          ]),
        ]),
      ),
    );
  }
}

class EditEntryScreen extends StatefulWidget {
  final String entryId;
  const EditEntryScreen({super.key, required this.entryId});
  @override
  State<EditEntryScreen> createState() => _EditEntryScreenState();
}

class _EditEntryScreenState extends State<EditEntryScreen> {
  late DrinkType drink;
  late int cups;
  late int mg;
  late DateTime time;
  bool loaded = false;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final app = context.app;
    if (!loaded) {
      final e = app.entries.firstWhere((e) => e.id == widget.entryId);
      drink = e.drink;
      cups = e.cups;
      mg = e.mg;
      time = e.time;
      loaded = true;
    }
    final dayTotalAfter = app.todayTotalMg -
        app.entries.firstWhere((e) => e.id == widget.entryId).mg +
        mg;

    return AppScaffold(
      body: Column(children: [
        TopBar(
          title: 'Edit entry',
          back: true,
          trailing: TIconButton(Icons.delete_outline_rounded, color: c.danger, onTap: () async {
            final entry = app.entries.firstWhere((e) => e.id == widget.entryId);
            final ok = await showDialog<bool>(context: context, builder: (_) => _DeleteDialog(entry: entry));
            if (ok == true) {
              app.deleteEntry(widget.entryId);
              if (context.mounted) Navigator.pop(context);
            }
          }),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            children: [
              SelectRow(
                emoji: drinkInfo(drink).emoji,
                title: drinkInfo(drink).label,
                subtitle: 'Tap to change drink',
                on: true,
                onTap: () async {
                  final picked = await showModalBottomSheet<DrinkType>(
                    context: context,
                    backgroundColor: Colors.transparent,
                    builder: (_) => _DrinkPicker(current: drink),
                  );
                  if (picked != null) {
                    setState(() {
                      drink = picked;
                      mg = drinkInfo(picked).mgPerCup * cups;
                    });
                  }
                },
              ),
              const SizedBox(height: 20),
              Text('Quantity', style: AppText.label(c.inkMuted)),
              const SizedBox(height: 8),
              Row(children: [1, 2, 3].map((n) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: TChip('$n cup${n > 1 ? 's' : ''}', on: cups == n,
                        onTap: () => setState(() { cups = n; mg = drinkInfo(drink).mgPerCup * n; })),
                  ),
                );
              }).toList()),
              const SizedBox(height: 20),
              Text('Caffeine', style: AppText.label(c.inkMuted)),
              const SizedBox(height: 8),
              TCard(
                child: Row(children: [
                  Text('$mg mg', style: AppText.num(c.ink, 19)),
                  const Spacer(),
                  Text('Estimated — edit if you know better', style: AppText.tiny(c.inkMuted)),
                ]),
              ),
              const SizedBox(height: 16),
              TInput(label: 'Time', value: 'Today, ${fmtTime(time)}', icon: Icons.access_time_rounded, onTap: () async {
                final picked = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(time));
                if (picked != null) {
                  setState(() {
                    final now = DateTime.now();
                    time = DateTime(now.year, now.month, now.day, picked.hour, picked.minute);
                  });
                }
              }),
              const SizedBox(height: 20),
              TCard(
                flat: true,
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('Day total after saving', style: AppText.label(c.inkMuted)),
                  Text('$dayTotalAfter mg', style: AppText.num(c.ink, 19)),
                ]),
              ),
              const SizedBox(height: 24),
              TButton('Save changes', onTap: () {
                app.updateEntry(widget.entryId, drink: drink, cups: cups, mg: mg, time: time);
                Navigator.pop(context);
                showTaperToast(context, 'Changes saved');
              }),
            ],
          ),
        ),
      ]),
    );
  }
}

class _DrinkPicker extends StatelessWidget {
  final DrinkType current;
  const _DrinkPicker({required this.current});
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
      decoration: BoxDecoration(color: c.surface, borderRadius: const BorderRadius.only(topLeft: rSheet, topRight: rSheet)),
      child: SafeArea(
        top: false,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 5, margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(color: c.line2, borderRadius: BorderRadius.circular(99))),
          ...kDrinks.map((d) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: SelectRow(
                  emoji: d.emoji, title: d.label, subtitle: '${d.mgPerCup} mg per cup',
                  on: d.type == current,
                  onTap: () => Navigator.pop(context, d.type),
                ),
              )),
        ]),
      ),
    );
  }
}