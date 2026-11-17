import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons_300.dart';
import 'package:material_symbols_icons/symbols.dart';

const sizes = [14.0, 16.0, 20.0];

final rows = <(String, IconData, IconData)>[
  ('search', LucideIcons300.search, Symbols.search_rounded),
  ('plus', LucideIcons300.plus, Symbols.add_rounded),
  ('x', LucideIcons300.x, Symbols.close_rounded),
  ('check', LucideIcons300.check, Symbols.check_rounded),
  ('chevron-down', LucideIcons300.chevronDown, Symbols.keyboard_arrow_down_rounded),
  ('copy', LucideIcons300.copy, Symbols.content_copy_rounded),
  ('trash', LucideIcons300.trash, Symbols.delete_rounded),
  ('settings', LucideIcons300.settings, Symbols.settings_rounded),
  ('bookmark', LucideIcons300.bookmark, Symbols.bookmark_rounded),
  ('external-link', LucideIcons300.externalLink, Symbols.open_in_new_rounded),
];

class IconTable extends StatelessWidget {
  const IconTable({super.key});

  Widget _cell(IconData icon, double size, {double? weight}) => SizedBox(
        width: 48,
        height: 32,
        child: Center(
          child: Icon(icon, size: size, color: Colors.black, weight: weight, fill: 0),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const SizedBox(width: 110),
            for (final s in sizes) SizedBox(width: 48, child: Center(child: Text('L ${s.toInt()}'))),
            const SizedBox(width: 16),
            for (final s in sizes) SizedBox(width: 48, child: Center(child: Text('M ${s.toInt()}'))),
          ]),
          for (final (name, lucide, material) in rows)
            Row(children: [
              SizedBox(width: 110, child: Text(name, style: const TextStyle(fontSize: 12))),
              for (final s in sizes) _cell(lucide, s),
              const SizedBox(width: 16),
              for (final s in sizes) _cell(material, s, weight: 300),
            ]),
        ],
      ),
    );
  }
}
