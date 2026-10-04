import 'package:flutter/material.dart';
import '../main.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets/common.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final app = context.app;

    return AppScaffold(
      body: Column(children: [
        const TopBar(title: 'Settings', back: true),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            children: [
              _section(context, 'Account'),
              _group(context, [
                _tile(context, Icons.person_outline_rounded, 'Personal information', onTap: () => Navigator.pushNamed(context, '/editProfile')),
                _tile(context, Icons.mail_outline_rounded, 'Change email', onTap: () {}),
                _tile(context, Icons.lock_outline_rounded, 'Change password', onTap: () {}),
                _tile(context, Icons.logout_rounded, 'Log out', onTap: () {}),
                _tile(context, Icons.delete_outline_rounded, 'Delete account', danger: true, onTap: () => Navigator.pushNamed(context, '/deleteData')),
              ]),
              _section(context, 'Notifications'),
              _group(context, [
                _tile(context, Icons.notifications_none_rounded, 'Notifications', value: '${_onCount(app)} on', onTap: () => Navigator.pushNamed(context, '/notificationSettings')),
              ]),
              _section(context, 'Appearance'),
              Row(children: [
                Expanded(child: _themeChip(context, 'Light', Icons.wb_sunny_outlined, ThemeMode.light)),
                const SizedBox(width: 8),
                Expanded(child: _themeChip(context, 'Dark', Icons.nightlight_round, ThemeMode.dark)),
                const SizedBox(width: 8),
                Expanded(child: _themeChip(context, 'System', Icons.smartphone_rounded, ThemeMode.system)),
              ]),
              const SizedBox(height: 8),
              _section(context, 'Data'),
              _group(context, [
                _tile(context, Icons.refresh_rounded, 'Refresh data', value: 'Local only', onTap: () => _refresh(context)),
                _tile(context, Icons.file_download_outlined, 'Import data', onTap: () {}),
                _tile(context, Icons.delete_outline_rounded, 'Delete all data', danger: true, onTap: () => Navigator.pushNamed(context, '/deleteData')),
              ]),
              _section(context, 'Support'),
              _group(context, [
                _tile(context, Icons.help_outline_rounded, 'Help centre & FAQ', onTap: () {}),
                _tile(context, Icons.mail_outline_rounded, 'Contact support', onTap: () {}),
                _tile(context, Icons.privacy_tip_outlined, 'Privacy & terms', onTap: () {}),
              ]),
            ],
          ),
        ),
      ]),
    );
  }

  int _onCount(AppState app) {
    final n = app.notifications;
    return [n.coffeeReminders, n.dailyProgress, n.limitWarning, n.streakReminders, n.motivation].where((e) => e).length;
  }

  Widget _section(BuildContext context, String title) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 8, left: 2),
      child: Text(title, style: AppText.label(c.inkMuted)),
    );
  }

  Widget _group(BuildContext context, List<Widget> tiles) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(color: c.surface, borderRadius: BorderRadius.circular(22), border: Border.all(color: c.line)),
      child: Column(
        children: tiles
            .expand((t) => [t, Divider(color: c.line, height: 1)])
            .toList()
          ..removeLast(),
      ),
    );
  }

  Widget _tile(BuildContext context, IconData icon, String label, {String? value, bool danger = false, VoidCallback? onTap}) {
    final c = context.colors;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 13),
        child: Row(children: [
          Icon(icon, size: 19, color: danger ? c.danger : c.inkMuted),
          const SizedBox(width: 14),
          Expanded(
            child: Text(label,
                style: AppText.body(danger ? c.danger : c.ink).copyWith(fontWeight: FontWeight.w600, fontSize: 14.5)),
          ),
          if (value != null) Text(value, style: AppText.tiny(c.inkMuted)),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right_rounded, size: 17, color: c.inkMuted),
        ]),
      ),
    );
  }

  Widget _themeChip(BuildContext context, String label, IconData icon, ThemeMode mode) {
    final app = context.app;
    final on = app.themeMode == mode;
    return InkWell(
      borderRadius: BorderRadius.circular(99),
      onTap: () => app.setThemeMode(mode),
      child: Builder(builder: (context) {
        final c = context.colors;
        return Container(
          height: 44,
          decoration: BoxDecoration(color: on ? c.ink : c.surface2, borderRadius: BorderRadius.circular(99)),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, size: 15, color: on ? c.bg : c.inkMuted),
            const SizedBox(width: 6),
            Text(label, style: AppText.tiny(on ? c.bg : c.inkMuted).copyWith(fontSize: 13)),
          ]),
        );
      }),
    );
  }

  void _refresh(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        Future.delayed(const Duration(milliseconds: 900), () {
          if (ctx.mounted) Navigator.pop(ctx);
        });
        final c = ctx.colors;
        return Dialog(
          backgroundColor: c.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.4, color: c.coffee)),
              const SizedBox(width: 14),
              Text('Updating your data…', style: AppText.body(c.ink).copyWith(fontWeight: FontWeight.w600)),
            ]),
          ),
        );
      },
    ).then((_) {
      if (context.mounted) showTaperToast(context, 'Your data is up to date');
    });
  }
}