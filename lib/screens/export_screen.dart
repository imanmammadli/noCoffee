import 'package:flutter/material.dart';
import '../main.dart';
import '../theme.dart';
import '../widgets/common.dart';

class ExportScreen extends StatefulWidget {
  const ExportScreen({super.key});
  @override
  State<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  final Map<String, bool> options = {
    'Coffee history': true,
    'Daily caffeine totals': true,
    'Plans': true,
    'Statistics': false,
    'Cravings': true,
    'Achievements': false,
  };
  String format = 'CSV';

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final app = context.app;
    final n = DateTime.now();
    final filename =
        'taper-export-${n.day.toString().padLeft(2, '0')}-${n.month.toString().padLeft(2, '0')}.${format.toLowerCase()}';
    final setCount = options.values.where((v) => v).length;

    return AppScaffold(
      body: Column(children: [
        TopBar(title: 'Export data', back: true),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            children: [
              Text(
                  'Choose what to include. Exports are generated on your device.',
                  style: AppText.body(c.inkMuted)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                decoration: BoxDecoration(
                    color: c.surface,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: c.line)),
                child: Column(
                  children: options.entries
                      .map((e) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            child: Row(children: [
                              Expanded(
                                  child: Text(e.key,
                                      style: AppText.body(c.ink).copyWith(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14.5))),
                              GestureDetector(
                                onTap: () =>
                                    setState(() => options[e.key] = !e.value),
                                child: Container(
                                  width: 23,
                                  height: 23,
                                  decoration: BoxDecoration(
                                    color:
                                        e.value ? c.accent : Colors.transparent,
                                    border: Border.all(
                                        color: e.value ? c.accent : c.line2,
                                        width: 2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: e.value
                                      ? const Icon(Icons.check_rounded,
                                          size: 14, color: Colors.white)
                                      : null,
                                ),
                              ),
                            ]),
                          ))
                      .toList()
                      .expand((w) => [w, Divider(color: c.line, height: 1)])
                      .toList()
                    ..removeLast(),
                ),
              ),
              const SizedBox(height: 20),
              Text('Format', style: AppText.label(c.inkMuted)),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(
                    child: TChip('CSV',
                        on: format == 'CSV',
                        onTap: () => setState(() => format = 'CSV'))),
                const SizedBox(width: 8),
                Expanded(
                    child: TChip('JSON',
                        on: format == 'JSON',
                        onTap: () => setState(() => format = 'JSON'))),
              ]),
              const SizedBox(height: 20),
              TCard(
                flat: true,
                child: Row(children: [
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(filename, style: AppText.h3(c.ink)),
                          const SizedBox(height: 4),
                          Text('$setCount sets · ${app.entries.length} entries',
                              style: AppText.tiny(c.inkMuted)),
                        ]),
                  ),
                  Icon(Icons.check_circle_rounded, color: c.accent, size: 20),
                ]),
              ),
              const SizedBox(height: 24),
              TButton('Export', icon: Icons.ios_share_rounded, onTap: () {
                showTaperToast(context, '$filename ready');
              }),
            ],
          ),
        ),
      ]),
    );
  }
}
