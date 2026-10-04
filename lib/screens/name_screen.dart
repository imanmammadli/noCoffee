import 'package:flutter/material.dart';
import '../main.dart';
import '../theme.dart';
import '../widgets/common.dart';

class NameScreen extends StatefulWidget {
  const NameScreen({super.key});
  @override
  State<NameScreen> createState() => _NameScreenState();
}

class _NameScreenState extends State<NameScreen> {
  final first = TextEditingController();
  final last = TextEditingController();
  final email = TextEditingController();
  final age = TextEditingController();
  final price = TextEditingController(text: '3.50');

  @override
  void dispose() {
    first.dispose();
    last.dispose();
    email.dispose();
    age.dispose();
    price.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('A little about you', style: AppText.h1(c.ink)),
            const SizedBox(height: 8),
            Text(
                "We'll use this to personalize your plan and track money saved.",
                style: AppText.body(c.inkMuted)),
            const SizedBox(height: 28),
            Row(children: [
              Expanded(
                  child: _field(context, 'First name', first, autofocus: true)),
              const SizedBox(width: 10),
              Expanded(child: _field(context, 'Last name', last)),
            ]),
            const SizedBox(height: 14),
            _field(context, 'Email', email, icon: Icons.mail_outline_rounded),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: _field(context, 'Age', age, numeric: true)),
              const SizedBox(width: 10),
              Expanded(
                child: _field(context, 'Avg. coffee price', price,
                    numeric: true, icon: Icons.attach_money_rounded),
              ),
            ]),
            const SizedBox(height: 28),
            TButton('Continue', onTap: () {
              final p = context.app.profile;
              if (first.text.trim().isNotEmpty) p.firstName = first.text.trim();
              if (last.text.trim().isNotEmpty) p.lastName = last.text.trim();
              if (email.text.trim().isNotEmpty) p.email = email.text.trim();
              final parsedAge = int.tryParse(age.text.trim());
              if (parsedAge != null) p.age = parsedAge;
              final parsedPrice = double.tryParse(price.text.trim());
              if (parsedPrice != null) p.coffeePrice = parsedPrice;
              context.app.refresh();
              Navigator.pushReplacementNamed(context, '/onboarding');
            }),
          ]),
        ),
      ),
    );
  }

  Widget _field(BuildContext context, String label, TextEditingController ctrl,
      {bool autofocus = false, bool numeric = false, IconData? icon}) {
    final c = context.colors;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: AppText.label(c.inkMuted)),
      const SizedBox(height: 7),
      Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: c.line2, width: 1.4)),
        child: Row(children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: c.inkMuted),
            const SizedBox(width: 10)
          ],
          Expanded(
            child: TextField(
              controller: ctrl,
              autofocus: autofocus,
              textCapitalization:
                  numeric ? TextCapitalization.none : TextCapitalization.words,
              keyboardType: numeric ? TextInputType.number : TextInputType.text,
              style: AppText.body(c.ink)
                  .copyWith(fontWeight: FontWeight.w600, fontSize: 15.5),
              decoration: const InputDecoration(
                  border: InputBorder.none, isDense: true),
            ),
          ),
        ]),
      ),
    ]);
  }
}
