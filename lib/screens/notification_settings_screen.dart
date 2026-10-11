import 'package:flutter/material.dart';
import '../main.dart';
import '../models.dart';
import '../notification_service.dart';
import '../theme.dart';
import '../widgets/common.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});
  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  final _service = NotificationService.instance;

  Future<void> _toggleMotivation(bool on) async {
    final n = context.app.notifications;
    try {
      if (on) {
        final granted = await _service.requestPermission();
        if (!granted) {
          if (mounted) {
            showTaperToast(context, 'Notifications are blocked. Allow them in your phone settings.',
                isError: true);
          }
          return;
        }
        await _service.scheduleMotivation(isQuiet: n.isQuiet);
      } else {
        await _service.cancelMotivation();
      }
      if (!mounted) return;
      setState(() => n.motivation = on);
      showTaperToast(
          context, on ? 'Daily motivation on · around ${_service.motivationTimeLabel}' : 'Daily motivation off');
    } catch (_) {
      if (mounted) showTaperToast(context, 'Could not set up notifications', isError: true);
    }
  }

  /// Used by the four simple toggles: asks for permission when turning on,
  /// saves, then rebuilds the scheduled notifications.
  Future<void> _toggle(bool on, void Function(bool) set) async {
    final app = context.app;
    if (on) {
      final granted = await _service.requestPermission();
      if (!granted) {
        if (mounted) {
          showTaperToast(context, 'Notifications are blocked. Allow them in your phone settings.',
              isError: true);
        }
        return;
      }
    }
    set(on);
    app.refresh();
    if (mounted) setState(() {});
    await _service.syncAll(app);
  }

  Future<void> _pickQuiet(bool from) async {
    final app = context.app;
    final n = app.notifications;
    final current = from ? n.quietFromMin : n.quietUntilMin;
    final picked = await showTimePicker(
        context: context, initialTime: TimeOfDay(hour: current ~/ 60, minute: current % 60));
    if (picked == null) return;
    final v = picked.hour * 60 + picked.minute;
    if (from) {
      n.quietFromMin = v;
    } else {
      n.quietUntilMin = v;
    }
    app.refresh();
    if (mounted) setState(() {});
    await _service.syncAll(app);
  }

  Future<void> _sendTest() async {
    if (!_service.supported) {
      showTaperToast(context, 'Notifications work in the phone app, not in the browser');
      return;
    }
    final granted = await _service.requestPermission();
    if (!granted) {
      if (mounted) {
        showTaperToast(context, 'Notifications are blocked. Allow them in your phone settings.',
            isError: true);
      }
      return;
    }
    await _service.showTest();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final n = context.app.notifications;

    return AppScaffold(
      body: Column(children: [
        const TopBar(title: 'Notifications', back: true),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            children: [
              InsightCard(
                  icon: Icons.notifications_none_rounded,
                  text:
                      'We send at most four a day, and none between ${fmtMinutes(n.quietFromMin)} and ${fmtMinutes(n.quietUntilMin)}.'),
              const SizedBox(height: 16),
              _group(context, [
                _toggleRow(context, 'Coffee reminders', 'A nudge at 14:00 to track your coffee',
                    n.coffeeReminders, (v) => _toggle(v, (x) => n.coffeeReminders = x)),
                _toggleRow(context, 'Daily progress', "A summary at 20:00 with tomorrow's target",
                    n.dailyProgress, (v) => _toggle(v, (x) => n.dailyProgress = x)),
                _toggleRow(context, 'Limit warning', 'A heads-up in the app when you near or pass your limit',
                    n.limitWarning, (v) {
                  setState(() => n.limitWarning = v);
                  context.app.refresh();
                }),
                _toggleRow(context, 'Streak reminders', 'An evening message about your streak 🔥',
                    n.streakReminders, (v) => _toggle(v, (x) => n.streakReminders = x)),
                _toggleRow(context, 'Motivation', 'One short message a day, around ${_service.motivationTimeLabel}',
                    n.motivation, _toggleMotivation),
              ]),
              const SizedBox(height: 20),
              Text('Quiet hours', style: AppText.label(c.inkMuted)),
              const SizedBox(height: 8),
              _group(context, [
                _valueRow(context, Icons.nightlight_round, 'From', fmtMinutes(n.quietFromMin), () => _pickQuiet(true)),
                _valueRow(context, Icons.wb_sunny_outlined, 'Until', fmtMinutes(n.quietUntilMin), () => _pickQuiet(false)),
              ]),
              const SizedBox(height: 20),
              TCard(
                bg: c.surface2,
                borderColor: Colors.transparent,
                padding: const EdgeInsets.all(14),
                child: Row(children: [
                  Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(color: c.coffee, borderRadius: BorderRadius.circular(9)),
                      alignment: Alignment.center,
                      child: const Icon(Icons.coffee_rounded, size: 16, color: Color(0xFFFFF9F1))),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('NoCoffee · now', style: AppText.tiny(c.ink)),
                      Text('Small steps create big changes.', style: AppText.tiny(c.inkMuted)),
                    ]),
                  ),
                ]),
              ),
              const SizedBox(height: 16),
              TButton('Send a test notification',
                  style: TBtnStyle.secondary, small: true, onTap: _sendTest),
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
      decoration: BoxDecoration(
          color: c.surface, borderRadius: BorderRadius.circular(22), border: Border.all(color: c.line)),
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

  Widget _valueRow(BuildContext context, IconData icon, String label, String value, VoidCallback onTap) {
    final c = context.colors;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 13),
        child: Row(children: [
          Icon(icon, size: 18, color: c.inkMuted),
          const SizedBox(width: 14),
          Expanded(child: Text(label, style: AppText.body(c.ink).copyWith(fontWeight: FontWeight.w600, fontSize: 14.5))),
          Text(value, style: AppText.num(c.ink, 15)),
        ]),
      ),
    );
  }
}