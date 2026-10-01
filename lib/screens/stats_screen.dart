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
    final days = [7, 30, 90, 365][range];
    final now = DateTime.now();
    final series = List.generate(days.clamp(0, 14), (i) {
      final d = now.subtract(Duration(days: (days.clamp(0, 14) - 1 - i)));
      final total = app.entries
          .where((e) =>
              e.time.year == d.year &&
              e.time.month == d.month &&
              e.time.day == d.day)
          .fold(0, (s, e) => s + e.mg);
      return total.toDouble();
    });
    final avg = app.entries.isEmpty
        ? 0
        : (app.entries.fold(0, (s, e) => s + e.mg) / days).round();

    return AppScaffold(
      navIndex: 3,
      body: Column(children: [
        TopBar(
            title: 'Statistics',
            trailing: TIconButton(Icons.ios_share_rounded,
                onTap: () => Navigator.pushNamed(context, '/export'))),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            children: [
              Row(children: [
                TChip('7 days',
                    on: range == 0, onTap: () => setState(() => range = 0)),
                const SizedBox(width: 8),
                TChip('30 days',
                    on: range == 1, onTap: () => setState(() => range = 1)),
                const SizedBox(width: 8),
                TChip('90 days',
                    on: range == 2, onTap: () => setState(() => range = 2)),
                const SizedBox(width: 8),
                TChip('All time',
                    on: range == 3, onTap: () => setState(() => range = 3)),
              ]),
              const SizedBox(height: 16),
              TCard(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Daily caffeine intake',
                                style: AppText.h3(c.ink)),
                            TPill('-32%', fg: c.accent, bg: c.accentSoft),
                          ]),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 130,
                        child: CustomPaint(
                          size: const Size(double.infinity, 130),
                          painter: _LinePainter(
                              series.isEmpty ? [0, 0] : series,
                              c.accent,
                              c.coffee),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${days.clamp(0, 14)} pts',
                                style: AppText.tiny(c.inkMuted)),
                            Text('today', style: AppText.tiny(c.inkMuted)),
                          ]),
                    ]),
              ),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: _metric(context, '$avg', 'mg average / day')),
                const SizedBox(width: 12),
                Expanded(
                    child: _metric(context, '-32%', 'vs 30 days ago',
                        color: c.accent)),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                    child: _metric(context, '${app.coffeeFreeDaysCount}',
                        'coffee-free days')),
                const SizedBox(width: 12),
                Expanded(
                    child: _metric(
                        context,
                        '${app.moneySaved.toStringAsFixed(0)} ${app.profile.currency}',
                        'money saved')),
              ]),
              const SizedBox(height: 16),
              const InsightCard(
                  text:
                      'Wednesdays are your highest day, most weeks. Worth a look at what happens on Wednesdays.'),
              const SizedBox(height: 24),
              Text('Everything else', style: AppText.h3(c.ink)),
              const SizedBox(height: 8),
              TCard(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                child: Column(children: [
                  _row(context, 'Total drinks', '${app.entries.length}'),
                  Divider(color: c.line, height: 1),
                  _row(context, 'Total caffeine consumed',
                      '${app.entries.fold(0, (s, e) => s + e.mg)} mg'),
                  Divider(color: c.line, height: 1),
                  _row(context, 'Longest streak', '${app.streak} days'),
                  Divider(color: c.line, height: 1),
                  _row(context, 'Cravings recorded', '${app.cravingsTotal}'),
                  Divider(color: c.line, height: 1),
                  _row(context, 'Cravings resisted', '${app.cravingsResisted}',
                      color: c.accent),
                  Divider(color: c.line, height: 1),
                  _row(context, 'Coffee-free days',
                      '${app.coffeeFreeDaysCount}'),
                  Divider(color: c.line, height: 1),
                  _row(context, 'Money saved',
                      '${app.moneySaved.toStringAsFixed(2)} ${app.profile.currency}'),
                ]),
              ),
              const SizedBox(height: 16),
              TButton('View achievements',
                  style: TBtnStyle.secondary,
                  onTap: () => Navigator.pushNamed(context, '/achievements')),
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
  final Color lineColor;
  final Color dashColor;
  _LinePainter(this.values, this.lineColor, this.dashColor);

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final maxV = (values.reduce((a, b) => a > b ? a : b)).clamp(1, 999999);
    final stepX = size.width / (values.length - 1).clamp(1, 999999);
    final points = <Offset>[
      for (int i = 0; i < values.length; i++)
        Offset(i * stepX,
            size.height - (values[i] / maxV) * (size.height - 14) - 4)
    ];

    final dashPaint = Paint()
      ..color = dashColor.withOpacity(.5)
      ..strokeWidth = 1.4;
    double dx = 0;
    final y = size.height * 0.55;
    while (dx < size.width) {
      canvas.drawLine(Offset(dx, y * 0.7), Offset(dx + 5, y * 0.85), dashPaint);
      dx += 9;
    }

    final path = Path()..moveTo(points.first.dx, size.height);
    for (final p in points) path.lineTo(p.dx, p.dy);
    path.lineTo(points.last.dx, size.height);
    path.close();
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [lineColor.withOpacity(.22), lineColor.withOpacity(0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(path, fillPaint);

    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (final p in points.skip(1)) linePath.lineTo(p.dx, p.dy);
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
