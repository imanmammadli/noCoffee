import 'package:flutter/material.dart';
import '../main.dart';
import '../theme.dart';
import '../widgets/common.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final app = context.app;
    final p = app.profile;
    final daysIn = app.plan?.dayNumber ?? 0;

    return AppScaffold(
      navIndex: 4,
      body: Column(children: [
        TopBar(title: 'Profile'),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            children: [
              TCard(
                child: Row(children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: c.coffee,
                    child: Text(p.firstName.substring(0, 1),
                        style: const TextStyle(
                            color: Color(0xFFFFF9F1),
                            fontWeight: FontWeight.w700,
                            fontSize: 22)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${p.firstName} ${p.lastName}',
                              style: AppText.h2(c.ink)),
                          const SizedBox(height: 4),
                          Text(p.email, style: AppText.tiny(c.inkMuted)),
                        ]),
                  ),
                ]),
              ),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _stat(context, '$daysIn', 'days in')),
                const SizedBox(width: 12),
                Expanded(child: _stat(context, '${app.streak}', 'day streak')),
                const SizedBox(width: 12),
                Expanded(
                    child: _stat(
                        context,
                        '${app.achievements.where((a) => a.isUnlocked(app.snapshot)).length}',
                        'badges',
                        color: c.accent)),
              ]),
              const SizedBox(height: 24),
              Text('Personal information', style: AppText.label(c.inkMuted)),
              const SizedBox(height: 8),
              TCard(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                child: Column(children: [
                  _row(context, Icons.person_outline_rounded, 'Name',
                      '${p.firstName} ${p.lastName}'),
                  Divider(color: c.line, height: 1),
                  _row(
                      context, Icons.calendar_today_rounded, 'Age', '${p.age}'),
                  Divider(color: c.line, height: 1),
                  _row(context, Icons.coffee_rounded, 'Daily coffee',
                      '${p.dailyCups} cups'),
                  Divider(color: c.line, height: 1),
                  _row(context, Icons.attach_money_rounded, 'Coffee price',
                      '${p.coffeePrice.toStringAsFixed(2)} ${p.currency}'),
                ]),
              ),
              const SizedBox(height: 12),
              TButton('Edit profile',
                  style: TBtnStyle.secondary,
                  small: true,
                  onTap: () => Navigator.pushNamed(context, '/editProfile')),
              const SizedBox(height: 16),
              TCard(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                child: Column(children: [
                  InkWell(
                    onTap: () => Navigator.pushNamed(context, '/achievements'),
                    child: _row(
                        context,
                        Icons.auto_awesome_rounded,
                        'Achievements',
                        '${app.achievements.where((a) => a.isUnlocked(app.snapshot)).length} of ${app.achievements.length}',
                        chevron: true),
                  ),
                  Divider(color: c.line, height: 1),
                  InkWell(
                    onTap: () => Navigator.pushNamed(context, '/settings'),
                    child: _row(
                        context, Icons.settings_outlined, 'Settings', '',
                        chevron: true),
                  ),
                ]),
              ),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _stat(BuildContext context, String value, String label,
      {Color? color}) {
    final c = context.colors;
    return TCard(
      padding: const EdgeInsets.all(14),
      child: Column(children: [
        Text(value, style: AppText.num(color ?? c.ink, 22)),
        const SizedBox(height: 4),
        Text(label, style: AppText.tiny(c.inkMuted)),
      ]),
    );
  }

  Widget _row(BuildContext context, IconData icon, String label, String value,
      {bool chevron = false}) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Row(children: [
        Icon(icon, size: 19, color: c.inkMuted),
        const SizedBox(width: 14),
        Expanded(
            child: Text(label,
                style: AppText.body(c.ink)
                    .copyWith(fontWeight: FontWeight.w600, fontSize: 14.5))),
        Text(value, style: AppText.tiny(c.inkMuted)),
        if (chevron) ...[
          const SizedBox(width: 4),
          Icon(Icons.chevron_right_rounded, size: 17, color: c.inkMuted)
        ],
      ]),
    );
  }
}
