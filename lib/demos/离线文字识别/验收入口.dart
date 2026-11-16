// 独立验收：flutter run -t "lib/demos/离线文字识别/验收入口.dart" --dart-define=JOBS_OCR_AUTO=true
// 只调用真实原生插件；结构化输出供原生验收脚本收集。
// ignore_for_file: deprecated_member_use

import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';
import 'package:jobs_rust_ocr/jobs_rust_ocr.dart';

import '离线文字识别.dart';
import '识别文案.dart';

void main() {
  registerOCRTranslations();
  const auto = bool.fromEnvironment('JOBS_OCR_AUTO');
  const runId = String.fromEnvironment('JOBS_OCR_RUN_ID');
  var emitted = false;
  void emit(Map<String, Object?> evidence) {
    if (emitted || !auto) return;
    emitted = true;
    debugPrint(
      'JOBS_OCR_EVIDENCE: ${jsonEncode({'schema_version': 1, 'run_id': runId, 'platform': defaultTargetPlatform.name, 'recorded_at': DateTime.now().toUtc().toIso8601String(), 'source': 'JobsRustOCR/real-native-sample', ...evidence})}',
      wrapWidth: null,
    );
  }

  runApp(
    JobsDemoApp(
      home: RustOCRDemo(
        autoRecognize: auto,
        onResult: (JobsOCRResult result) {
          // Stable literal from the bundled official scan, not a fabricated OCR result.
          final anchor = result.text.contains('DIOCESE OF SEOUL');
          final passed =
              result.engine == 'jobs-rust-ocr/indra' &&
              result.width > 0 &&
              result.height > 0 &&
              result.lines.isNotEmpty &&
              anchor;
          emit({
            'passed': passed,
            'engine': result.engine,
            'width': result.width,
            'height': result.height,
            'line_count': result.lines.length,
            'elapsed_ms': result.elapsedMs,
            'anchor': 'DIOCESE OF SEOUL',
            'anchor_found': anchor,
            'text_sha256': sha256.convert(utf8.encode(result.text)).toString(),
            'text_preview': String.fromCharCodes(result.text.runes.take(200)),
          });
        },
        onFailure: (Object error) =>
            emit({'passed': false, 'error': error.toString()}),
      ),
    ),
  );
}
