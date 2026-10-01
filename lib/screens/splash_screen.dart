import 'package:flutter/material.dart';
import '../main.dart';
import '../theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..forward();

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      final done = context.app.onboardingDone;
      Navigator.pushReplacementNamed(context, done ? '/home' : '/welcome');
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      backgroundColor: c.bg,
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          AnimatedBuilder(
            animation: _ctrl,
            builder: (_, __) => SizedBox(
              width: 120,
              height: 120,
              child: Stack(alignment: Alignment.center, children: [
                CircularProgressIndicator(
                  value: _ctrl.value * 0.74,
                  strokeWidth: 3,
                  color: c.coffee,
                  backgroundColor: c.ring,
                ),
                Icon(Icons.coffee_rounded, size: 44, color: c.coffee),
              ]),
            ),
          ),
          const SizedBox(height: 22),
          Text('Taper', style: AppText.num(c.ink, 38)),
          const SizedBox(height: 8),
          Text('Quit coffee. Feel better.', style: AppText.body(c.inkMuted)),
        ]),
      ),
    );
  }
}