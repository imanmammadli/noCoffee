import 'package:flutter/material.dart';
import '../main.dart';
import '../theme.dart';
import '../widgets/common.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final app = context.app;
    final snap = app.snapshot;
    final list = app.achievements;
    final unlocked = list.where((a) => a.isUnlocked(snap)).length;

    return AppScaffold(
      body: Column(children: [
        TopBar(title: 'Achievements', back: true),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            children: [
              TCard(
                child: Row(children: [
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text.rich(TextSpan(children: [
                            TextSpan(
                                text: '$unlocked',
                                style: AppText.num(c.ink, 30)),
                            TextSpan(
                                text: ' of ${list.length}',
                                style: AppText.num(c.inkMuted, 16)),
                          ])),
                          const SizedBox(height: 4),
                          Text('unlocked', style: AppText.tiny(c.inkMuted)),
                        ]),
                  ),
                  SizedBox(
                      width: 120, child: TBar(value: unlocked / list.length)),
                ]),
              ),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.35,
                children: list.map((a) {
                  final on = a.isUnlocked(snap);
                  return Opacity(
                    opacity: on ? 1 : 0.45,
                    child: TCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(a.emoji, style: const TextStyle(fontSize: 26)),
                            const SizedBox(height: 8),
                            Text(a.title, style: AppText.h3(c.ink)),
                            const SizedBox(height: 4),
                            Text(a.progressLabel(snap),
                                style: AppText.tiny(c.inkMuted)),
                          ]),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
