import 'package:flutter/material.dart';
import '../main.dart';
import '../theme.dart';
import '../widgets/common.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int filter = 1; // 0 day, 1 week, 2 month

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final app = context.app;
    final now = DateTime.now();
    const months = ['January','February','March','April','May','June','July','August','September','October','November','December'];

    // Build totals for last 7 days for the bar chart.
    final last7 = List.generate(7, (i) {
      final d = now.subtract(Duration(days: 6 - i));
      final total = app.entries
          .where((e) => e.time.year == d.year && e.time.month == d.month && e.time.day == d.day)
          .fold(0, (s, e) => s + e.mg);
      return total;
    });
    final maxV = (last7.reduce((a, b) => a > b ? a : b)).clamp(1, 999999);

    return AppScaffold(
      body: Column(children: [
        TopBar(title: 'History', back: true),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            children: [
              Row(children: [
                TChip('Day', on: filter == 0, onTap: () => setState(() => filter = 0)),
                const SizedBox(width: 8),
                TChip('Week', on: filter == 1, onTap: () => setState(() => filter = 1)),
                const SizedBox(width: 8),
                TChip('Month', on: filter == 2, onTap: () => setState(() => filter = 2)),
              ]),
              const SizedBox(height: 16),
              TCard(
                child: Column(children: [
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.chevron_left_rounded, color: c.inkMuted),
                    Text('${months[now.month - 1]} ${now.year}', style: AppText.h3(c.ink)),
                    Icon(Icons.chevron_right_rounded, color: c.inkMuted),
                  ]),
                  const SizedBox(height: 14),
                  _MiniCalendar(month: now),
                  const SizedBox(height: 14),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    _legendDot(c.coffee, 'Under limit'),
                    const SizedBox(width: 14),
                    _legendDot(c.warn, 'Over'),
                    const SizedBox(width: 14),
                    _legendDot(c.accent, 'Coffee-free'),
                  ]),
                ]),
              ),
              const SizedBox(height: 16),
              TCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('This week', style: AppText.h3(c.ink)),
                    TPill('7 days', fg: c.accent, bg: c.accentSoft),
                  ]),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 100,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(7, (i) {
                        final h = last7[i] / maxV;
                        final isFree = last7[i] == 0;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            child: Container(
                              height: (h * 90).clamp(6, 90),
                              decoration: BoxDecoration(
                                color: isFree ? c.accent : c.coffee.withOpacity(0.5 + h * 0.5),
                                borderRadius: BorderRadius.circular(7),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: ['M','T','W','T','F','S','S']
                        .map((d) => Expanded(child: Text(d, style: AppText.tiny(c.inkMuted), textAlign: TextAlign.center)))
                        .toList(),
                  ),
                  const SizedBox(height: 12),
                  Divider(color: c.line, height: 1),
                  const SizedBox(height: 12),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('Weekly average', style: AppText.label(c.inkMuted)),
                    Text('${(last7.reduce((a, b) => a + b) / 7).round()} mg/day', style: AppText.num(c.ink, 17)),
                  ]),
                ]),
              ),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Builder(builder: (context) {
      final c = context.colors;
      return Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: AppText.tiny(c.inkMuted)),
      ]);
    });
  }
}

class _MiniCalendar extends StatelessWidget {
  final DateTime month;
  const _MiniCalendar({required this.month});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final app = context.app;
    final first = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final leading = first.weekday - 1; // Monday = 0
    final today = DateTime.now();

    final cells = <Widget>[];
    for (final l in ['M','T','W','T','F','S','S']) {
      cells.add(Center(child: Text(l, style: AppText.tiny(c.inkMuted))));
    }
    for (int i = 0; i < leading; i++) {
      cells.add(const SizedBox());
    }
    for (int d = 1; d <= daysInMonth; d++) {
      final date = DateTime(month.year, month.month, d);
      final isToday = date.year == today.year && date.month == today.month && date.day == today.day;
      final total = app.entries
          .where((e) => e.time.year == date.year && e.time.month == date.month && e.time.day == date.day)
          .fold(0, (s, e) => s + e.mg);
      final hasData = date.isBefore(today.add(const Duration(days: 1)));
      Color? dot;
      if (hasData && date.isBefore(today)) {
        dot = total == 0 ? c.accent : (total > app.todayLimit ? c.warn : c.coffee);
      }
      cells.add(
        Container(
          margin: const EdgeInsets.all(1),
          decoration: BoxDecoration(
            color: isToday ? c.ink : Colors.transparent,
            borderRadius: BorderRadius.circular(13),
          ),
          alignment: Alignment.center,
          child: Column(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [
            Text('$d', style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600,
                color: isToday ? c.bg : (date.isAfter(today) ? c.inkMuted.withOpacity(0.4) : c.ink))),
            const SizedBox(height: 3),
            if (dot != null) Container(width: 5, height: 5, decoration: BoxDecoration(color: isToday ? c.bg : dot, shape: BoxShape.circle))
            else const SizedBox(height: 5),
          ]),
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 2,
      crossAxisSpacing: 2,
      childAspectRatio: 1,
      children: cells,
    );
  }
}