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
  final price = TextEditingController();
  bool triedSubmit = false;

  @override
  void dispose() {
    first.dispose();
    last.dispose();
    email.dispose();
    age.dispose();
    price.dispose();
    super.dispose();
  }

  bool get emailValid => RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email.text.trim());
  bool get ageValid => int.tryParse(age.text.trim()) != null && int.parse(age.text.trim()) > 0;
  bool get priceValid => double.tryParse(price.text.trim()) != null && double.parse(price.text.trim()) >= 0;
  bool get formValid =>
      first.text.trim().isNotEmpty &&
      last.text.trim().isNotEmpty &&
      emailValid &&
      ageValid &&
      priceValid;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('A little about you', style: AppText.h1(c.ink)),
            const SizedBox(height: 8),
            Text("We'll use this to personalize your plan and track money saved.",
                style: AppText.body(c.inkMuted)),
            const SizedBox(height: 28),
            Row(children: [
              Expanded(
                  child: _field(context, 'First name', first,
                      autofocus: true, error: triedSubmit && first.text.trim().isEmpty ? 'Required' : null)),
              const SizedBox(width: 10),
              Expanded(
                  child: _field(context, 'Last name', last,
                      error: triedSubmit && last.text.trim().isEmpty ? 'Required' : null)),
            ]),
            const SizedBox(height: 14),
            _field(context, 'Email', email,
                icon: Icons.mail_outline_rounded,
                error: triedSubmit && !emailValid ? 'Enter a valid email' : null),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(
                child: _field(context, 'Age', age,
                    numeric: true, error: triedSubmit && !ageValid ? 'Required' : null),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _field(context, 'Avg. coffee price', price,
                    numeric: true,
                    icon: Icons.attach_money_rounded,
                    error: triedSubmit && !priceValid ? 'Required' : null),
              ),
            ]),
            const SizedBox(height: 28),
            TButton('Continue', onTap: () {
              setState(() => triedSubmit = true);
              if (!formValid) return;
              final p = context.app.profile;
              p.firstName = first.text.trim();
              p.lastName = last.text.trim();
              p.email = email.text.trim();
              p.age = int.parse(age.text.trim());
              p.coffeePrice = double.parse(price.text.trim());
              context.app.refresh();
              Navigator.pushReplacementNamed(context, '/onboarding');
            }),
          ]),
        ),
      ),
    );
  }

  Widget _field(BuildContext context, String label, TextEditingController ctrl,
      {bool autofocus = false, bool numeric = false, IconData? icon, String? error}) {
    final c = context.colors;
    final hasError = error != null;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: AppText.label(c.inkMuted)),
      const SizedBox(height: 7),
      Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: hasError ? c.danger : c.line2, width: 1.4)),
        child: Row(children: [
          if (icon != null) ...[Icon(icon, size: 18, color: c.inkMuted), const SizedBox(width: 10)],
          Expanded(
            child: TextField(
              controller: ctrl,
              autofocus: autofocus,
              onChanged: (_) => setState(() {}),
              textCapitalization: numeric ? TextCapitalization.none : TextCapitalization.words,
              keyboardType: numeric
                  ? const TextInputType.numberWithOptions(decimal: true)
                  : TextInputType.text,
              style: AppText.body(c.ink).copyWith(fontWeight: FontWeight.w600, fontSize: 15.5),
              decoration: const InputDecoration(border: InputBorder.none, isDense: true),
            ),
          ),
        ]),
      ),
      if (hasError) ...[
        const SizedBox(height: 5),
        Text(error, style: AppText.tiny(c.danger)),
      ],
    ]);
  }
}