import '../lib/demo_hub/interop_catalog.dart';

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/demo_hub/data_parity_catalog.dart';
import '../lib/demo_hub/extra_catalog.dart';
import '../lib/demo_hub/legacy_catalog.dart';
import '../lib/demo_hub/native_catalog.dart';
import '../lib/demo_hub/parallel_catalog.dart';
import '../lib/demo_hub/platform_catalog.dart';
import '../lib/demo_hub/ui_parity_catalog.dart';

void main() {
  test(
    'Every native registration points to a real runnable Chinese-folder demo',
    () {
      final demos = [
        ...legacyDemos,
        ...nativeDemos,
        ...dataParityDemos,
        ...interopDemos,
        ...extraDemos,
        ...platformDemos,
        ...uiParityDemos,
      ];
      final ids = {
        for (final d in demos) d.id: d.sourcePath,
        for (final d in parallelDemos) d.id: d.sourcePath,
      };
      expect(
        ids.length,
        demos.length + parallelDemos.length,
        reason: 'Demo identifiers must be unique',
      );
      final inventory = jsonDecode(
        File('docs/native_feature_inventory.json').readAsStringSync(),
      ) as Map<String, dynamic>;
      final entries = inventory['entries'] as List;
      expect(entries.length, greaterThanOrEqualTo(385));
      for (final row in entries.cast<Map<String, dynamic>>()) {
        final targets = (row['flutter_ids'] as List).cast<String>();
        expect(
          targets,
          isNotEmpty,
          reason: '${row['project']} ${row['entry']}',
        );
        for (final id in targets) {
          expect(ids.containsKey(id), isTrue, reason: '${row['entry']} -> $id');
        }
      }
      for (final source in ids.values) {
        expect(File(source).existsSync(), isTrue, reason: source);
        expect(
          source.split('/')[2],
          matches(RegExp('[\u3400-\u9fff]')),
          reason: source,
        );
        expect(
          RegExp(r'\bmain\s*\(').hasMatch(File(source).readAsStringSync()),
          isTrue,
          reason: 'Standalone main(): $source',
        );
      }
    },
  );
}
