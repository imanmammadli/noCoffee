import 'package:flutter/material.dart';
import '../main.dart';
import '../theme.dart';
import '../widgets/common.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController first;
  late final TextEditingController last;
  late final TextEditingController email;
  late final TextEditingController age;
  late final TextEditingController cups;
  late final TextEditingController price;
  bool initialized = false;
  bool triedSubmit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!initialized) {
      final p = context.app.profile;
      first = TextEditingController(text: p.firstName);
      last = TextEditingController(text: p.lastName);
      email = TextEditingController(text: p.email);
      age = TextEditingController(text: '${p.age}');
      cups = TextEditingController(text: '${p.dailyCups}');
      price = TextEditingController(text: p.coffeePrice.toStringAsFixed(2));
      initialized = true;
    }
  }

  @override
  void dispose() {
    first.dispose();
    last.dispose();
    email.dispose();
    age.dispose();
    cups.dispose();
    price.dispose();
    super.dispose();
  }

  bool get emailValid => RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email.text.trim());
  bool get ageValid => int.tryParse(age.text.trim()) != null && int.parse(age.text.trim()) > 0;
  bool get priceValid => double.tryParse(price.text.trim()) != null && double.parse(price.text.trim()) >= 0;
  bool get formValid =>
      first.text.trim().isNotEmpty && last.text.trim().isNotEmpty && emailValid && ageValid && priceValid;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AppScaffold(
      body: Column(children: [
        const TopBar(title: 'Edit profile', back: true),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            children: [
              Center(
                child: Column(children: [
                  CircleAvatar(
                    radius: 38,
                    backgroundColor: c.coffee,
                    child: Text(
                      first.text.isEmpty ? '?' : first.text.substring(0, 1).toUpperCase(),
                      style: const TextStyle(color: Color(0xFFFFF9F1), fontWeight: FontWeight.w700, fontSize: 26),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Change photo', style: AppText.tiny(c.coffee)),
                ]),
              ),
              const SizedBox(height: 24),
              Row(children: [
                Expanded(
                    child: _field(context, 'First name', first,
                        error: triedSubmit && first.text.trim().isEmpty ? 'Required' : null)),
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
              _field(context, 'Age', age, numeric: true, error: triedSubmit && !ageValid ? 'Required' : null),
              const SizedBox(height: 14),
              _field(context, 'Daily coffee (cups)', cups, numeric: true),
              const SizedBox(height: 14),
              _field(context, 'Coffee price', price,
                  numeric: true, error: triedSubmit && !priceValid ? 'Required' : null),
              const SizedBox(height: 24),
              TButton('Save changes', onTap: () {
                setState(() => triedSubmit = true);
                if (!formValid) return;
                final p = context.app.profile;
                p.firstName = first.text.trim();
                p.lastName = last.text.trim();
                p.email = email.text.trim();
                p.age = int.parse(age.text.trim());
                p.dailyCups = int.tryParse(cups.text.trim()) ?? p.dailyCups;
                p.coffeePrice = double.parse(price.text.trim());
                context.app.refresh();
                Navigator.pop(context);
                showTaperToast(context, 'Profile updated');
              }),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _field(BuildContext context, String label, TextEditingController ctrl,
      {IconData? icon, bool numeric = false, String? error}) {
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
              onChanged: (_) => setState(() {}),
              keyboardType: numeric ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
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