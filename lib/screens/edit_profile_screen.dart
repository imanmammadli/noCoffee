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
  late final TextEditingController weight;
  late final TextEditingController cups;
  late final TextEditingController price;

  @override
  void initState() {
    super.initState();
    final p = context.app.profile;
    first = TextEditingController(text: p.firstName);
    last = TextEditingController(text: p.lastName);
    email = TextEditingController(text: p.email);
    age = TextEditingController(text: '${p.age}');
    weight = TextEditingController(text: p.weightKg.toStringAsFixed(0));
    cups = TextEditingController(text: '${p.dailyCups}');
    price = TextEditingController(text: p.coffeePrice.toStringAsFixed(2));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AppScaffold(
      body: Column(children: [
        TopBar(title: 'Edit profile', back: true),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            children: [
              Center(
                child: Column(children: [
                  CircleAvatar(radius: 38, backgroundColor: c.coffee,
                      child: Text(first.text.isEmpty ? 'A' : first.text.substring(0,1),
                          style: const TextStyle(color: Color(0xFFFFF9F1), fontWeight: FontWeight.w700, fontSize: 26))),
                  const SizedBox(height: 8),
                  Text('Change photo', style: AppText.tiny(c.coffee)),
                ]),
              ),
              const SizedBox(height: 24),
              Row(children: [
                Expanded(child: _field(context, 'First name', first)),
                const SizedBox(width: 10),
                Expanded(child: _field(context, 'Last name', last)),
              ]),
              const SizedBox(height: 14),
              _field(context, 'Email', email, icon: Icons.mail_outline_rounded),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(child: _field(context, 'Age', age, numeric: true)),
                const SizedBox(width: 10),
                Expanded(child: _field(context, 'Weight (kg)', weight, numeric: true)),
              ]),
              const SizedBox(height: 14),
              _field(context, 'Daily coffee (cups)', cups, numeric: true),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(flex: 3, child: _field(context, 'Coffee price', price, numeric: true)),
                const SizedBox(width: 10),
                Expanded(flex: 2, child: TInput(label: 'Currency', value: context.app.profile.currency)),
              ]),
              const SizedBox(height: 24),
              TButton('Save changes', onTap: () {
                final p = context.app.profile;
                p.firstName = first.text;
                p.lastName = last.text;
                p.email = email.text;
                p.age = int.tryParse(age.text) ?? p.age;
                p.weightKg = double.tryParse(weight.text) ?? p.weightKg;
                p.dailyCups = int.tryParse(cups.text) ?? p.dailyCups;
                p.coffeePrice = double.tryParse(price.text) ?? p.coffeePrice;
                context.app.notifyListeners();
                Navigator.pop(context);
                showTaperToast(context, 'Profile updated');
              }),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _field(BuildContext context, String label, TextEditingController ctrl, {IconData? icon, bool numeric = false}) {
    final c = context.colors;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: AppText.label(c.inkMuted)),
      const SizedBox(height: 7),
      Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(color: c.surface, borderRadius: BorderRadius.circular(17), border: Border.all(color: c.line2, width: 1.4)),
        child: Row(children: [
          if (icon != null) ...[Icon(icon, size: 18, color: c.inkMuted), const SizedBox(width: 10)],
          Expanded(
            child: TextField(
              controller: ctrl,
              keyboardType: numeric ? TextInputType.number : TextInputType.text,
              style: AppText.body(c.ink).copyWith(fontWeight: FontWeight.w600, fontSize: 15.5),
              decoration: const InputDecoration(border: InputBorder.none, isDense: true),
            ),
          ),
        ]),
      ),
    ]);
  }
}