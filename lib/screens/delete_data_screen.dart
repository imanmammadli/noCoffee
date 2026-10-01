import 'package:flutter/material.dart';
import '../main.dart';
import '../theme.dart';
import '../widgets/common.dart';

class DeleteDataScreen extends StatelessWidget {
  const DeleteDataScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final app = context.app;

    return AppScaffold(
      body: Column(children: [
        TopBar(title: 'Delete all data', back: true),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                width: 54,
                height: 54,
                decoration:
                    BoxDecoration(color: c.dangerSoft, shape: BoxShape.circle),
                child: Icon(Icons.warning_amber_rounded,
                    color: c.danger, size: 24),
              ),
              const SizedBox(height: 16),
              Text('Delete all data?', style: AppText.h1(c.ink)),
              const SizedBox(height: 8),
              Text(
                'This removes ${app.entries.length} coffee entries, your plan, ${app.cravings.length} cravings and unlocked achievements from this device.',
                style: AppText.body(c.inkMuted),
              ),
              const SizedBox(height: 16),
              const InsightCard(
                  icon: Icons.ios_share_rounded,
                  text: 'Export a copy first — it takes about five seconds.'),
              const Spacer(),
              Text('This action cannot be undone.',
                  style: AppText.tiny(c.danger)
                      .copyWith(fontSize: 13, fontWeight: FontWeight.w700)),
              const SizedBox(height: 14),
              TButton('Delete everything', style: TBtnStyle.danger, onTap: () {
                app.deleteAllData();
                Navigator.pushNamedAndRemoveUntil(
                    context, '/welcome', (r) => false);
              }),
              const SizedBox(height: 10),
              TButton('Cancel',
                  style: TBtnStyle.secondary,
                  onTap: () => Navigator.pop(context)),
            ]),
          ),
        ),
      ]),
    );
  }
}
