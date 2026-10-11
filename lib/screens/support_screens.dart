import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';
import '../widgets/common.dart';

/// TODO: put your real support address here before publishing.
const String kSupportEmail = 'support@example.com';

class _Page extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Page({required this.title, required this.children});
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Column(children: [
        TopBar(title: title, back: true),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            children: children,
          ),
        ),
      ]),
    );
  }
}

Widget _heading(BuildContext context, String text) {
  final c = context.colors;
  return Padding(
    padding: const EdgeInsets.only(top: 22, bottom: 8),
    child: Text(text, style: AppText.h3(c.ink)),
  );
}

Widget _para(BuildContext context, String text) {
  final c = context.colors;
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: AppText.body(c.inkMuted).copyWith(height: 1.5)),
  );
}

// ---------------------------------------------------------------- FAQ

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  static const _faq = [
    (
      'How is my daily limit decided?',
      'Your plan starts from the amount you told us you drink (cups × about 90 mg). Each week the limit steps down by a set share, depending on the speed you chose, until it reaches your target.'
    ),
    (
      'Can I change my plan?',
      'Yes. Open the Plan tab and tap the pencil. You can change the goal, method, start date and speed, and the preview updates before you save.'
    ),
    (
      'Why is a drink’s caffeine only an estimate?',
      'Caffeine varies by bean, brew and size. We use typical values per cup. If you know the real number, edit the entry and enter it.'
    ),
    (
      'How does the streak work?',
      'A day counts when you stay at or under that day’s limit. A day with no drinks counts too. Going over the limit resets the streak.'
    ),
    (
      'How is money saved calculated?',
      'We compare the cups you usually drink with the cups you actually logged, and multiply by your average coffee price from your profile.'
    ),
    (
      'Will I get withdrawal symptoms?',
      'Headaches, tiredness and irritability are common in the first days, especially when stopping suddenly. A gradual plan is gentler. If symptoms are severe, speak to a doctor.'
    ),
    (
      'Where is my data stored?',
      'Only on this device. There are no accounts and nothing is uploaded. Deleting the app or using Delete all data removes it.'
    ),
    (
      'Why am I not getting notifications?',
      'Turn them on in Settings › Notifications and allow notifications for Taper in your phone settings. Some phones also limit background activity for apps; if reminders arrive late, exclude Taper from battery optimisation.'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return _Page(
      title: 'Help centre & FAQ',
      children: [
        for (final (q, a) in _faq)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              decoration: BoxDecoration(
                  color: c.surface, borderRadius: BorderRadius.circular(18), border: Border.all(color: c.line)),
              child: Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  expandedCrossAxisAlignment: CrossAxisAlignment.start,
                  iconColor: c.inkMuted,
                  collapsedIconColor: c.inkMuted,
                  title: Text(q, style: AppText.h3(c.ink)),
                  children: [Text(a, style: AppText.body(c.inkMuted).copyWith(height: 1.5))],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ------------------------------------------------------------ Contact

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return _Page(
      title: 'Contact support',
      children: [
        _para(context, 'Found a bug or have an idea? Send us an email and we’ll get back to you.'),
        const SizedBox(height: 8),
        TCard(
          child: Row(children: [
            Icon(Icons.mail_outline_rounded, color: c.inkMuted),
            const SizedBox(width: 14),
            Expanded(child: Text(kSupportEmail, style: AppText.h3(c.ink))),
          ]),
        ),
        const SizedBox(height: 16),
        TButton('Copy email address', onTap: () async {
          await Clipboard.setData(const ClipboardData(text: kSupportEmail));
          if (context.mounted) showTaperToast(context, 'Email address copied');
        }),
        _heading(context, 'Helpful to include'),
        _para(context, '• What you were doing when it happened\n• Your phone model and Android/iOS version\n• A screenshot, if you can'),
        _para(context, 'Please don’t send health details you’d rather keep private. Taper never needs them to help you.'),
      ],
    );
  }
}

// -------------------------------------------------------------- Legal

enum LegalKind { privacyTerms, disclaimer }

class LegalScreen extends StatelessWidget {
  final LegalKind kind;
  const LegalScreen({super.key, required this.kind});

  @override
  Widget build(BuildContext context) {
    if (kind == LegalKind.disclaimer) {
      return _Page(title: 'Health disclaimer', children: _disclaimer(context));
    }
    return _Page(title: 'Privacy & terms', children: [
      _heading(context, 'Privacy'),
      _para(context,
          'Taper has no accounts and no servers. Everything you enter (drinks, plan, cravings, profile) is stored only on your device.'),
      _para(context,
          'We do not collect analytics, advertising identifiers or location. Notifications are created on your device and are not sent from any server.'),
      _para(context,
          'Because your data lives on your device, we cannot recover it if you delete the app or lose the phone. You can erase everything at any time with Settings › Delete all data.'),
      _heading(context, 'Terms of use'),
      _para(context,
          'Taper is provided “as is”, without warranties. Caffeine amounts, limits and plans are estimates and may be inaccurate.'),
      _para(context,
          'You are responsible for decisions about your health and diet. To the extent the law allows, the developers are not liable for any loss or harm arising from use of the app.'),
      _para(context, 'We may update these terms as the app changes. Continued use means you accept the updated version.'),
      ..._disclaimer(context),
    ]);
  }

  List<Widget> _disclaimer(BuildContext context) => [
        _heading(context, 'Health disclaimer'),
        _para(context,
            'Taper is a tracking and habit tool. It is not a medical device and does not give medical advice, diagnosis or treatment.'),
        _para(context,
            'Talk to your doctor before reducing caffeine if you are pregnant or breastfeeding, have a heart condition, anxiety, high blood pressure, or take medication.'),
        _para(context,
            'Stopping caffeine can cause headaches, tiredness and low mood. If symptoms are severe or last long, stop following the plan and seek medical advice. In an emergency, contact your local emergency number.'),
      ];
}
