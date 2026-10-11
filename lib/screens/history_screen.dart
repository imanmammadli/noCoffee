import 'package:flutter/material.dart';
import '../main.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'tracking_screen.dart';

const _months = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December'
];
const _short = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

DateTime _dayOnly(DateTime t) => DateTime(t.year, t.month, t.day);

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int filter = 1; // 0 day, 1 week, 2 month
  DateTime anchor = _dayOnly(DateTime.now());

  DateTime get _weekStart => DateTime(anchor.year, anchor.month, anchor.day - (anchor.weekday - 1));

  void _move(int dir) {
    setState(() {
      if (filter == 0) {
        anchor = DateTime(anchor.year, anchor.month, anchor.day + dir);
      } else if (filter == 1) {
        anchor = DateTime(anchor.year, anchor.month, anchor.day + 7 * dir);
      } else {
        anchor = DateTime(anchor.year, anchor.month + dir, 1);
      }
    });
  }

  bool get _canGoForward {
    final today = _dayOnly(DateTime.now());
    if (filter == 0) return anchor.isBefore(today);
    if (filter == 1) return _weekStart.add(const Duration(days: 7)).isBefore(today.add(const Duration(days: 1)));
    return DateTime(anchor.year, anchor.month + 1, 1).isBefore(today.add(const Duration(days: 1)));
  }

  String get _title {
    if (filter == 0) {
      final today = _dayOnly(DateTime.now());
      final diff = today.difference(anchor).inDays;
      if (diff == 0) return 'Today';
      if (diff == 1) return 'Yesterday';
      return '${anchor.day} ${_short[anchor.month - 1]} ${anchor.year}';
    }
    if (filter == 1) {
      final s = _weekStart;
      final e = DateTime(s.year, s.month, s.day + 6);
      return '${s.day} ${_short[s.month - 1]} – ${e.day} ${_short[e.month - 1]}';
    }
    return '${_months[anchor.month - 1]} ${anchor.year}';
  }

  void _setFilter(int f) => setState(() {
        filter = f;
        if (f == 2) anchor = DateTime(anchor.year, anchor.month, anchor.day);
      });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AppScaffold(
      body: Column(children: [
        const TopBar(title: 'History', back: true),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            children: [
              Row(children: [
                TChip('Day', on: filter == 0, onTap: () => _setFilter(0)),
                const SizedBox(width: 8),
                TChip('Week', on: filter == 1, onTap: () => _setFilter(1)),
                const SizedBox(width: 8),
                TChip('Month', on: filter == 2, onTap: () => _setFilter(2)),
              ]),
              const SizedBox(height: 16),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                IconButton(
                    onPressed: () => _move(-1),
                    icon: Icon(Icons.chevron_left_rounded, color: c.ink)),
                Text(_title, style: AppText.h3(c.ink)),
                IconButton(
                    onPressed: _canGoForward ? () => _move(1) : null,
                    icon: Icon(Icons.chevron_right_rounded,
                        color: _canGoForward ? c.ink : c.inkMuted.withValues(alpha: 0.3))),
              ]),
              const SizedBox(height: 8),
              if (filter == 0) _dayView(context),
              if (filter == 1) _weekView(context),
              if (filter == 2) _monthView(context),
            ],
          ),
        ),
      ]),
    );
  }

  // ---------- day ----------
  Widget _dayView(BuildContext context) {
    final c = context.colors;
    final app = context.app;
    final entries = app.entriesOnDay(anchor);
    final total = app.mgOnDay(anchor);
    final limit = app.limitOnDay(anchor);
    return Column(children: [
      TCard(
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            _big(context, '$total', 'mg caffeine'),
            _big(context, '${entries.length}', 'drinks'),
            _big(context, '$limit', 'daily limit'),
          ]),
          const SizedBox(height: 16),
          TBar(value: limit == 0 ? (total == 0 ? 0.0 : 1.0) : (total / limit).clamp(0.0, 1.0).toDouble()),
        ]),
      ),
      const SizedBox(height: 16),
      TCard(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        child: entries.isEmpty
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 18),
                child: Center(child: Text('No drinks logged this day.', style: AppText.body(c.inkMuted))),
              )
            : Column(
                children: entries
                    .map((e) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(children: [
                            SizedBox(width: 46, child: Text(fmtTime(e.time), style: AppText.tiny(c.inkMuted))),
                            Text(drinkInfo(e.drink).emoji, style: const TextStyle(fontSize: 18)),
                            const SizedBox(width: 12),
                            Expanded(child: Text(drinkInfo(e.drink).label, style: AppText.h3(c.ink))),
                            Text('${e.mg} mg', style: AppText.num(c.ink, 16)),
                          ]),
                        ))
                    .toList()
                    .expand((w) => [w, Divider(color: c.line, height: 1)])
                    .toList()
                  ..removeLast(),
              ),
      ),
      const SizedBox(height: 16),
      TButton('Open in Tracking',
          style: TBtnStyle.secondary,
          onTap: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => TrackingScreen(initialDay: anchor)))),
    ]);
  }

  Widget _big(BuildContext context, String v, String l) {
    final c = context.colors;
    return Column(children: [
      Text(v, style: AppText.num(c.ink, 26)),
      const SizedBox(height: 4),
      Text(l, style: AppText.tiny(c.inkMuted)),
    ]);
  }

  // ---------- week ----------
  Widget _weekView(BuildContext context) {
    final c = context.colors;
    final app = context.app;
    final today = _dayOnly(DateTime.now());
    final start = _weekStart;
    final days = [for (var i = 0; i < 7; i++) DateTime(start.year, start.month, start.day + i)];
    final totals = [for (final d in days) app.mgOnDay(d)];
    final counted = [for (final d in days) !d.isAfter(today)];
    final shownTotals = [for (var i = 0; i < 7; i++) if (counted[i]) totals[i]];
    final avg = shownTotals.isEmpty ? 0 : (shownTotals.reduce((a, b) => a + b) / shownTotals.length).round();
    final under = [for (var i = 0; i < 7; i++) if (counted[i] && days[i].isBefore(today) && totals[i] <= app.limitOnDay(days[i])) 1].length;
    final pastDays = days.where((d) => d.isBefore(today)).length;
    final maxV = [1, ...totals, ...days.map(app.limitOnDay)].reduce((a, b) => a > b ? a : b);

    return TCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Week overview', style: AppText.h3(c.ink)),
          TPill('$under of $pastDays under limit', fg: c.accent, bg: c.accentSoft),
        ]),
        const SizedBox(height: 16),
        SizedBox(
          height: 100,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(7, (i) {
              final h = totals[i] / maxV;
              final over = totals[i] > app.limitOnDay(days[i]);
              final free = counted[i] && totals[i] == 0;
              return Expanded(
                child: InkWell(
                  onTap: () => setState(() {
                    anchor = days[i];
                    filter = 0;
                  }),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        height: (h * 90).clamp(6, 90).toDouble(),
                        decoration: BoxDecoration(
                          color: !counted[i]
                              ? c.coffee.withValues(alpha: 0.15)
                              : (free ? c.accent : (over ? c.warn : c.coffee)),
                          borderRadius: BorderRadius.circular(7),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
              .map((d) => Expanded(child: Text(d, style: AppText.tiny(c.inkMuted), textAlign: TextAlign.center)))
              .toList(),
        ),
        const SizedBox(height: 12),
        Divider(color: c.line, height: 1),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Weekly average', style: AppText.label(c.inkMuted)),
          Text('$avg mg/day', style: AppText.num(c.ink, 17)),
        ]),
        const SizedBox(height: 6),
        Text('Tap a bar to see that day.', style: AppText.tiny(c.inkMuted)),
      ]),
    );
  }

  // ---------- month ----------
  Widget _monthView(BuildContext context) {
    final c = context.colors;
    final app = context.app;
    final today = _dayOnly(DateTime.now());
    final dim = DateTime(anchor.year, anchor.month + 1, 0).day;
    var free = 0, under = 0, total = 0, counted = 0;
    final first = app.firstDay;
    for (var d = 1; d <= dim; d++) {
      final date = DateTime(anchor.year, anchor.month, d);
      if (!date.isBefore(today) || (first != null && date.isBefore(first))) continue;
      final mg = app.mgOnDay(date);
      counted++;
      total += mg;
      if (mg == 0) free++;
      if (mg <= app.limitOnDay(date)) under++;
    }
    return Column(children: [
      TCard(
        child: Column(children: [
          _MiniCalendar(
            month: anchor,
            onDayTap: (d) => setState(() {
              anchor = d;
              filter = 0;
            }),
          ),
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
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
        child: Column(children: [
          _row(context, 'Average per day', counted == 0 ? '—' : '${(total / counted).round()} mg'),
          Divider(color: c.line, height: 1),
          _row(context, 'Days under limit', '$under of $counted'),
          Divider(color: c.line, height: 1),
          _row(context, 'Coffee-free days', '$free', color: c.accent),
        ]),
      ),
    ]);
  }

  Widget _row(BuildContext context, String label, String value, {Color? color}) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: AppText.label(c.inkMuted)),
        Text(value, style: AppText.num(color ?? c.ink, 16)),
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
  final ValueChanged<DateTime> onDayTap;
  const _MiniCalendar({required this.month, required this.onDayTap});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final app = context.app;
    final first = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final leading = first.weekday - 1; // Monday = 0
    final today = _dayOnly(DateTime.now());
    final firstData = app.firstDay;

    final cells = <Widget>[];
    for (final l in ['M', 'T', 'W', 'T', 'F', 'S', 'S']) {
      cells.add(Center(child: Text(l, style: AppText.tiny(c.inkMuted))));
    }
    for (int i = 0; i < leading; i++) {
      cells.add(const SizedBox());
    }
    for (int d = 1; d <= daysInMonth; d++) {
      final date = DateTime(month.year, month.month, d);
      final isToday = date == today;
      final future = date.isAfter(today);
      final total = app.mgOnDay(date);
      Color? dot;
      if (!future && (firstData != null && !date.isBefore(firstData))) {
        if (date.isBefore(today) || total > 0) {
          dot = total == 0 ? c.accent : (total > app.limitOnDay(date) ? c.warn : c.coffee);
        }
      }
      cells.add(
        InkWell(
          borderRadius: BorderRadius.circular(13),
          onTap: future ? null : () => onDayTap(date),
          child: Container(
            margin: const EdgeInsets.all(1),
            decoration: BoxDecoration(
              color: isToday ? c.ink : Colors.transparent,
              borderRadius: BorderRadius.circular(13),
            ),
            alignment: Alignment.center,
            child: Column(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [
              Text('$d',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isToday ? c.bg : (future ? c.inkMuted.withValues(alpha: 0.4) : c.ink))),
              const SizedBox(height: 3),
              if (dot != null)
                Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(color: isToday ? c.bg : dot, shape: BoxShape.circle))
              else
                const SizedBox(height: 5),
            ]),
          ),
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
