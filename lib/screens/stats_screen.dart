import 'package:flutter/material.dart';
import '../main.dart';
import '../theme.dart';
import '../widgets/common.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});
  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  int range = 1; // 0=7d 1=30d 2=90d 3=all

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final app = context.app;
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final first = app.firstDay;

    int days;
    if (range == 3) {
      days = first == null ? 7 : today.difference(first).inDays + 1;
      if (days < 7) days = 7;
    } else {
      days = [7, 30, 90][range];
    }
    final from = DateTime(today.year, today.month, today.day - (days - 1));

    // The chart shows at most the last 60 days.
    final points = days > 60 ? 60 : days;
    final series = List.generate(points, (i) {
      final d = DateTime(today.year, today.month, today.day - (points - 1 - i));
      return app.mgOnDay(d).toDouble();
    });

    final avgRaw = app.avgMgBetween(from, today);
    final avg = avgRaw?.round();
    final baseline = app.baselineMg;
    final change = (avg == null || baseline == 0) ? null : ((avg - baseline) / baseline * 100).round();
    final changeLabel = change == null ? null : '${change > 0 ? '+' : ''}$change%';
    final changeColor = (change ?? 0) <= 0 ? c.accent : c.warn;

    final inRange = app.entries.where((e) {
      final d = DateTime(e.time.year, e.time.month, e.time.day);
      return !d.isBefore(from) && !d.isAfter(today);
    }).toList();
    final busiest = app.busiestWeekday;

    return AppScaffold(
      navIndex: 3,
      body: Column(children: [
        const TopBar(title: 'Statistics'),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            children: [
              Row(children: [
                Expanded(child: TChip('7 days', on: range == 0, onTap: () => setState(() => range = 0))),
                const SizedBox(width: 6),
                Expanded(child: TChip('30 days', on: range == 1, onTap: () => setState(() => range = 1))),
                const SizedBox(width: 6),
                Expanded(child: TChip('90 days', on: range == 2, onTap: () => setState(() => range = 2))),
                const SizedBox(width: 6),
                Expanded(child: TChip('All time', on: range == 3, onTap: () => setState(() => range = 3))),
              ]),
              const SizedBox(height: 16),
              TCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('Daily caffeine intake', style: AppText.h3(c.ink)),
                    if (changeLabel != null)
                      TPill(changeLabel, fg: changeColor, bg: change! <= 0 ? c.accentSoft : c.warnSoft),
                  ]),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 130,
                    child: CustomPaint(
                      size: const Size(double.infinity, 130),
                      painter: _LinePainter(series, app.todayLimit.toDouble(), c.accent, c.coffee),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('Last $points days', style: AppText.tiny(c.inkMuted)),
                    Text('Dashed line: today\'s limit', style: AppText.tiny(c.inkMuted)),
                  ]),
                ]),
              ),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: _metric(context, avg == null ? '—' : '$avg', 'mg average / day')),
                const SizedBox(width: 12),
                Expanded(
                    child: _metric(context, changeLabel ?? '—', 'vs your usual intake',
                        color: change == null ? null : changeColor)),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _metric(context, '${app.coffeeFreeDaysCount}', 'coffee-free days')),
                const SizedBox(width: 12),
                Expanded(child: _metric(context, app.moneySaved.toStringAsFixed(0), 'money saved')),
              ]),
              if (busiest != null) ...[
                const SizedBox(height: 16),
                InsightCard(
                    text: '${busiest}s are your highest day, on average. Worth a look at what happens on ${busiest}s.'),
              ],
              const SizedBox(height: 24),
              Text('Everything else', style: AppText.h3(c.ink)),
              const SizedBox(height: 8),
              TCard(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                child: Column(children: [
                  _row(context, 'Total drinks', '${inRange.fold<int>(0, (s, e) => s + e.cups)}'),
                  Divider(color: c.line, height: 1),
                  _row(context, 'Total caffeine consumed', '${inRange.fold<int>(0, (s, e) => s + e.mg)} mg'),
                  Divider(color: c.line, height: 1),
                  _row(context, 'Longest streak', '${app.longestStreak} days'),
                  Divider(color: c.line, height: 1),
                  _row(context, 'Cravings recorded', '${app.cravingsTotal}'),
                  Divider(color: c.line, height: 1),
                  _row(context, 'Cravings resisted', '${app.cravingsResisted}', color: c.accent),
                  Divider(color: c.line, height: 1),
                  _row(context, 'Coffee-free days', '${app.coffeeFreeDaysCount}'),
                  Divider(color: c.line, height: 1),
                  _row(context, 'Money saved', app.moneySaved.toStringAsFixed(2)),
                ]),
              ),
              const SizedBox(height: 16),
              TButton('View achievements',
                  style: TBtnStyle.secondary, onTap: () => Navigator.pushNamed(context, '/achievements')),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _metric(BuildContext context, String value, String label,
      {Color? color}) {
    final c = context.colors;
    return TCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value, style: AppText.num(color ?? c.ink, 24)),
        const SizedBox(height: 4),
        Text(label, style: AppText.tiny(c.inkMuted)),
      ]),
    );
  }

  Widget _row(BuildContext context, String label, String value,
      {Color? color}) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: AppText.label(c.inkMuted)),
        Text(value, style: AppText.num(color ?? c.ink, 16)),
      ]),
    );
  }
}

class _LinePainter extends CustomPainter {
  final List<double> values;
  final double limit;
  final Color lineColor;
  final Color dashColor;
  _LinePainter(this.values, this.limit, this.lineColor, this.dashColor);

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final maxV = [1.0, limit, ...values].reduce((a, b) => a > b ? a : b);
    double yOf(double v) => size.height - (v / maxV) * (size.height - 14) - 4;
    final stepX = values.length > 1 ? size.width / (values.length - 1) : 0.0;
    final points = <Offset>[
      for (int i = 0; i < values.length; i++) Offset(values.length > 1 ? i * stepX : size.width / 2, yOf(values[i]))
    ];

    // Dashed line at today's limit.
    final dashPaint = Paint()
      ..color = dashColor.withValues(alpha: .5)
      ..strokeWidth = 1.4;
    final ly = yOf(limit);
    double dx = 0;
    while (dx < size.width) {
      canvas.drawLine(Offset(dx, ly), Offset(dx + 5, ly), dashPaint);
      dx += 9;
    }

    final path = Path()..moveTo(points.first.dx, size.height);
    for (final p in points) {
      path.lineTo(p.dx, p.dy);
    }
    path.lineTo(points.last.dx, size.height);
    path.close();
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [lineColor.withValues(alpha: .22), lineColor.withValues(alpha: 0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(path, fillPaint);

    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (final p in points.skip(1)) {
      linePath.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(
        linePath,
        Paint()
          ..color = lineColor
          ..strokeWidth = 2.6
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round);

    canvas.drawCircle(points.last, 5, Paint()..color = Colors.white);
    canvas.drawCircle(
        points.last,
        5,
        Paint()
          ..color = lineColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3);
  }

  @override
  bool shouldRepaint(covariant _LinePainter oldDelegate) => true;
}
