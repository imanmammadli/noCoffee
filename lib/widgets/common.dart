import 'dart:math';
import 'package:flutter/material.dart';
import '../theme.dart';

class AppScaffold extends StatelessWidget {
  final Widget body;
  final int navIndex; // -1 = no nav bar (sub-screens)
  const AppScaffold({super.key, required this.body, this.navIndex = -1});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(child: body),
      bottomNavigationBar: navIndex >= 0 ? TaperNavBar(index: navIndex) : null,
    );
  }
}

class TaperNavBar extends StatelessWidget {
  final int index;
  const TaperNavBar({super.key, required this.index});

  static const _items = [
    (Icons.home_rounded, 'Home'),
    (Icons.inventory_2_outlined, 'Tracking'),
    (Icons.donut_large_rounded, 'Plan'),
    (Icons.bar_chart_rounded, 'Stats'),
    (Icons.person_outline_rounded, 'Profile'),
  ];
  static const _routes = ['/home', '/tracking', '/plan', '/stats', '/profile'];

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      height: 74,
      decoration: BoxDecoration(color: c.surface, border: Border(top: BorderSide(color: c.line))),
      child: Row(
        children: List.generate(_items.length, (i) {
          final on = i == index;
          final (icon, label) = _items[i];
          return Expanded(
            child: InkWell(
              onTap: on
                  ? null
                  : () => Navigator.pushNamedAndRemoveUntil(context, _routes[i], (r) => false),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: on ? c.accentSoft : Colors.transparent,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Icon(icon, size: 22, color: on ? c.accent : c.inkMuted),
                  ),
                  const SizedBox(height: 3),
                  Text(label, style: AppText.tiny(on ? c.accent : c.inkMuted)),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class TopBar extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final bool back;
  const TopBar({super.key, required this.title, this.trailing, this.back = false});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
      child: Row(
        children: [
          if (back)
            IconButton(
              onPressed: () => Navigator.maybePop(context),
              icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: c.ink),
            ),
          Expanded(
            child: Text(title,
                style: back ? AppText.h3(c.ink) : AppText.h1(c.ink),
                textAlign: back ? TextAlign.center : TextAlign.left),
          ),
          trailing ?? SizedBox(width: back ? 42 : 0),
        ],
      ),
    );
  }
}

class TCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final bool flat;
  final bool lift;
  final Color? borderColor;
  final Color? bg;
  const TCard(
      {super.key,
      required this.child,
      this.padding = const EdgeInsets.all(18),
      this.flat = false,
      this.lift = false,
      this.borderColor,
      this.bg});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bg ?? (flat ? c.surface2 : c.surface),
        borderRadius: const BorderRadius.all(rXL),
        border: flat ? null : Border.all(color: borderColor ?? c.line),
        boxShadow: lift
            ? [
                BoxShadow(
                    color: Colors.black.withOpacity(c.brightness == Brightness.dark ? 0.45 : 0.12),
                    blurRadius: 26,
                    offset: const Offset(0, 10))
              ]
            : null,
      ),
      child: child,
    );
  }
}

enum TBtnStyle { primary, accent, secondary, ghost, danger }

class TButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final TBtnStyle style;
  final IconData? icon;
  final bool small;
  const TButton(this.label,
      {super.key, this.onTap, this.style = TBtnStyle.primary, this.icon, this.small = false});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    Color bg, fg;
    BoxBorder? border;
    switch (style) {
      case TBtnStyle.primary:
        bg = c.coffee;
        fg = c.brightness == Brightness.dark ? const Color(0xFF1B1410) : const Color(0xFFFFF9F1);
        break;
      case TBtnStyle.accent:
        bg = c.accent;
        fg = c.brightness == Brightness.dark ? const Color(0xFF10201A) : const Color(0xFFF2FBF7);
        break;
      case TBtnStyle.secondary:
        bg = Colors.transparent;
        fg = c.ink;
        border = Border.all(color: c.line2, width: 1.4);
        break;
      case TBtnStyle.ghost:
        bg = c.surface2;
        fg = c.ink;
        break;
      case TBtnStyle.danger:
        bg = c.dangerSoft;
        fg = c.danger;
        break;
    }
    return SizedBox(
      height: small ? 46 : 56,
      width: double.infinity,
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(small ? 15 : 18),
        child: InkWell(
          borderRadius: BorderRadius.circular(small ? 15 : 18),
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(small ? 15 : 18), border: border),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[Icon(icon, size: 19, color: fg), const SizedBox(width: 8)],
                Text(label, style: AppText.button(fg).copyWith(fontSize: small ? 14.5 : 16)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool plain;
  final Color? color;
  const TIconButton(this.icon, {super.key, this.onTap, this.plain = false, this.color});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Material(
      color: plain ? Colors.transparent : c.surface,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: plain ? BorderSide.none : BorderSide(color: c.line)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: SizedBox(
            width: 42, height: 42, child: Icon(icon, size: 19, color: color ?? c.ink)),
      ),
    );
  }
}

class TChip extends StatelessWidget {
  final String label;
  final bool on;
  final VoidCallback? onTap;
  final IconData? icon;
  const TChip(this.label, {super.key, this.on = false, this.onTap, this.icon});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return InkWell(
      borderRadius: const BorderRadius.all(rChip),
      onTap: onTap,
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: on ? c.ink : c.surface2,
          borderRadius: const BorderRadius.all(rChip),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (icon != null) ...[Icon(icon, size: 14, color: on ? c.bg : c.inkMuted), const SizedBox(width: 5)],
          Text(label, style: AppText.tiny(on ? c.bg : c.inkMuted).copyWith(fontSize: 13)),
        ]),
      ),
    );
  }
}

class TPill extends StatelessWidget {
  final String label;
  final Color fg;
  final Color bg;
  const TPill(this.label, {super.key, required this.fg, required this.bg});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: bg, borderRadius: const BorderRadius.all(rChip)),
      child: Text(label, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: fg)),
    );
  }
}

class ProgressRing extends StatelessWidget {
  final double value; // 0..1, can exceed 1
  final double size;
  final double stroke;
  final Widget? center;
  final Color? color;
  const ProgressRing(
      {super.key, required this.value, this.size = 186, this.stroke = 13, this.center, this.color});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(alignment: Alignment.center, children: [
        CustomPaint(
          size: Size(size, size),
          painter: _RingPainter(
              value: value.clamp(0, 1.15), track: c.ring, color: color ?? c.accent, stroke: stroke),
        ),
        if (center != null) center!,
      ]),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double value, stroke;
  final Color track, color;
  _RingPainter({required this.value, required this.track, required this.color, required this.stroke});
  @override
  void paint(Canvas canvas, Size size) {
    final r = (size.width - stroke) / 2;
    final center = Offset(size.width / 2, size.height / 2);
    final base = Paint()
      ..color = track
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, r, base);
    final fg = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    final sweep = 2 * pi * value.clamp(0, 1);
    canvas.drawArc(Rect.fromCircle(center: center, radius: r), -pi / 2, sweep, false, fg);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.value != value || oldDelegate.color != color;
}

class TBar extends StatelessWidget {
  final double value; // 0..1
  final Color? color;
  const TBar({super.key, required this.value, this.color});
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ClipRRect(
      borderRadius: const BorderRadius.all(rChip),
      child: Container(
        height: 8,
        color: c.surface2,
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: value.clamp(0, 1),
          child: Container(color: color ?? c.accent, height: 8),
        ),
      ),
    );
  }
}

class SelectRow extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final bool on;
  final VoidCallback? onTap;
  const SelectRow(
      {super.key,
      required this.emoji,
      required this.title,
      required this.subtitle,
      this.on = false,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return InkWell(
      borderRadius: const BorderRadius.all(Radius.circular(20)),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: on ? c.coffeeSoft : c.surface,
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          border: Border.all(color: on ? c.coffee : c.line2, width: 1.4),
        ),
        child: Row(children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: on ? c.bg : c.surface2, borderRadius: BorderRadius.circular(14)),
            child: Text(emoji, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: AppText.h3(c.ink)),
              const SizedBox(height: 3),
              Text(subtitle, style: AppText.tiny(c.inkMuted)),
            ]),
          ),
          Icon(on ? Icons.check_circle_rounded : Icons.circle_outlined,
              color: on ? c.accent : c.line2, size: 22),
        ]),
      ),
    );
  }
}

class TInput extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final VoidCallback? onTap;
  const TInput({super.key, required this.label, required this.value, this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return InkWell(
      borderRadius: BorderRadius.circular(17),
      onTap: onTap,
      child: Container(
        height: 58,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: c.line2, width: 1.4)),
        child: Row(children: [
          if (icon != null) ...[Icon(icon, size: 18, color: c.inkMuted), const SizedBox(width: 10)],
          Text(label, style: AppText.body(c.ink).copyWith(fontWeight: FontWeight.w600)),
          const Spacer(),
          Text(value, style: AppText.body(c.ink).copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(width: 6),
          Icon(Icons.chevron_right_rounded, size: 18, color: c.inkMuted),
        ]),
      ),
    );
  }
}

class TToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  const TToggle({super.key, required this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 48,
        height: 29,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: value ? c.accent : c.surface2,
          borderRadius: BorderRadius.circular(99),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 160),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 23,
            height: 23,
            decoration: BoxDecoration(
              color: value ? Colors.white : c.bg,
              shape: BoxShape.circle,
              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 3, offset: Offset(0, 1))],
            ),
          ),
        ),
      ),
    );
  }
}

void showTaperSheet(BuildContext context, Widget child) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) {
      final c = ctx.colors;
      return Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: const BorderRadius.only(topLeft: rSheet, topRight: rSheet),
          ),
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
          child: SafeArea(
            top: false,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                  width: 40,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(color: c.line2, borderRadius: BorderRadius.circular(99))),
              child,
            ]),
          ),
        ),
      );
    },
  );
}

void showTaperToast(BuildContext context, String text, {bool isError = false}) {
  final c = context.colors;
  final overlay = Overlay.of(context);
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => Positioned(
      left: 22,
      right: 22,
      bottom: 100,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
              color: c.ink, borderRadius: BorderRadius.circular(18),
              boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 20, offset: Offset(0, 8))]),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 26,
              height: 26,
              decoration:
                  BoxDecoration(color: isError ? c.danger : c.accent, shape: BoxShape.circle),
              child: Icon(isError ? Icons.close_rounded : Icons.check_rounded,
                  size: 15, color: Colors.white),
            ),
            const SizedBox(width: 11),
            Flexible(
                child: Text(text,
                    style: TextStyle(color: c.bg, fontWeight: FontWeight.w700, fontSize: 14))),
          ]),
        ),
      ),
    ),
  );
  overlay.insert(entry);
  Future.delayed(const Duration(seconds: 2), () => entry.remove());
}

class InsightCard extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color? color;
  const InsightCard({super.key, required this.text, this.icon = Icons.auto_awesome_rounded, this.color});
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final col = color ?? c.accent;
    return TCard(
      flat: true,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: 18, color: col),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: AppText.body(c.ink).copyWith(fontWeight: FontWeight.w600, fontSize: 13.5))),
      ]),
    );
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? ctaLabel;
  final VoidCallback? onCta;
  const EmptyState(
      {super.key,
      required this.icon,
      required this.title,
      required this.subtitle,
      this.ctaLabel,
      this.onCta});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(color: c.surface2, shape: BoxShape.circle),
            child: Icon(icon, size: 34, color: c.inkMuted),
          ),
          const SizedBox(height: 20),
          Text(title, style: AppText.h2(c.ink), textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(subtitle, style: AppText.body(c.inkMuted), textAlign: TextAlign.center),
          if (ctaLabel != null) ...[
            const SizedBox(height: 20),
            SizedBox(width: 180, child: TButton(ctaLabel!, onTap: onCta)),
          ],
        ]),
      ),
    );
  }
}

class ErrorCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onRetry;
  const ErrorCard({super.key, required this.title, required this.subtitle, this.onRetry});
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return TCard(
      borderColor: c.dangerSoft,
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(Icons.error_outline_rounded, color: c.danger, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: AppText.h3(c.ink)),
            const SizedBox(height: 4),
            Text(subtitle, style: AppText.tiny(c.inkMuted)),
            if (onRetry != null) ...[
              const SizedBox(height: 10),
              SizedBox(
                  height: 38,
                  child: TextButton(
                      onPressed: onRetry,
                      style: TextButton.styleFrom(
                          backgroundColor: c.surface2,
                          padding: const EdgeInsets.symmetric(horizontal: 14)),
                      child: Text('Try again', style: AppText.tiny(c.ink)))),
            ],
          ]),
        ),
      ]),
    );
  }
}