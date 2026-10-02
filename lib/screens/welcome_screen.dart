import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/common.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(color: c.coffee, borderRadius: BorderRadius.circular(22)),
                    child: const Icon(Icons.coffee_rounded, color: Color(0xFFFFF9F1), size: 30),
                  ),
                  const SizedBox(height: 24),
                  Text('Quit coffee.\nFeel better.', style: AppText.display(c.ink).copyWith(fontSize: 42)),
                  const SizedBox(height: 16),
                  Text(
                    'One cup at a time, at a pace your body can actually keep up with.',
                    style: AppText.body(c.inkMuted).copyWith(fontSize: 15.5),
                  ),
                ],
              ),
            ),
            TButton('Start', onTap: () => Navigator.pushNamed(context, '/name')),
            const SizedBox(height: 10),
            Text('No account needed — your data stays on this device.',
                style: AppText.tiny(c.inkMuted), textAlign: TextAlign.center),
          ]),
        ),
      ),
    );
  }
}