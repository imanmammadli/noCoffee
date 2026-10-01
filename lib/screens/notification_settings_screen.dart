import 'package:flutter/material.dart';
import '../main.dart';
import '../theme.dart';
import '../widgets/common.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});
  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final n = context.app.notifications;

    return AppScaffold(
      body: Column(children: [
        TopBar(title: 'Notifications', back: true),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            children: [
              const InsightCard(icon: Icons.notifications_none_rounded, text: 'We send at most three a day, and none between 22:00 and 07:00.'),
              const SizedBox(height: 16),
              _group(context, [
                _toggleRow(context, 'Coffee reminders', '"Remember to track your coffee today."', n.coffeeReminders, (v) => setState(() => n.coffeeReminders = v)),
                _toggleRow(context, 'Daily progress', 'A summary at 20:00 with tomorrow\'s target', n.dailyProgress, (v) => setState(() => n.dailyProgress = v)),
                _toggleRow(context, 'Limit warning', '"You\'re getting close to your daily limit."', n.limitWarning, (v) => setState(() => n.limitWarning = v)),
                _toggleRow(context, 'Streak reminders', '"You\'re on a 7-day streak 🔥"', n.streakReminders, (v) => setState(() => n.streakReminders = v)),
                _toggleRow(context, 'Motivation', '"Small steps create big changes."', n.motivation, (v) => setState(() => n.motivation = v)),
              ]),
              const SizedBox(height: 20),
              Text('Quiet hours', style: AppText.label(c.inkMuted)),
              const SizedBox(height: 8),
              _group(context, [
                _valueRow(context, Icons.nightlight_round, 'From', '22:00'),
                _valueRow(context, Icons.wb_sunny_outlined, 'Until', '07:00'),
              ]),
              const SizedBox(height: 20),
              TCard(
                bg: c.surface2,
                borderColor: Colors.transparent,
                padding: const EdgeInsets.all(14),
                child: Row(children: [
                  Container(width: 30, height: 30, decoration: BoxDecoration(color: c.coffee, borderRadius: BorderRadius.circular(9)),
                      alignment: Alignment.center, child: const Icon(Icons.coffee_rounded, size: 16, color: Color(0xFFFFF9F1))),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Taper · now', style: AppText.tiny(c.ink)),
                      Text('Your caffeine target this week is 150 mg/day.', style: AppText.tiny(c.inkMuted)),
                    ]),
                  ),
                ]),
              ),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _group(BuildContext context, List<Widget> tiles) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(color: c.surface, borderRadius: BorderRadius.circular(22), border: Border.all(color: c.line)),
      child: Column(children: tiles.expand((t) => [t, Divider(color: c.line, height: 1)]).toList()..removeLast()),
    );
  }

  Widget _toggleRow(BuildContext context, String title, String sub, bool value, ValueChanged<bool> onChanged) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: AppText.body(c.ink).copyWith(fontWeight: FontWeight.w700, fontSize: 14.5)),
            const SizedBox(height: 4),
            Text(sub, style: AppText.tiny(c.inkMuted)),
          ]),
        ),
        const SizedBox(width: 10),
        TToggle(value: value, onChanged: onChanged),
      ]),
    );
  }

  Widget _valueRow(BuildContext context, IconData icon, String label, String value) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Row(children: [
        Icon(icon, size: 18, color: c.inkMuted),
        const SizedBox(width: 14),
        Expanded(child: Text(label, style: AppText.body(c.ink).copyWith(fontWeight: FontWeight.w600, fontSize: 14.5))),
        Text(value, style: AppText.tiny(c.inkMuted)),
      ]),
    );
  }
}