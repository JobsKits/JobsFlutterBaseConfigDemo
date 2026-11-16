import 'package:flutter/services.dart';

/// OCR coordinates use the upright image's pixel space.
class JobsOCRLine {
  const JobsOCRLine({
    required this.text,
    required this.bbox,
    required this.confidence,
  });

  final String text;
  final List<double> bbox;
  final double confidence;

  factory JobsOCRLine.fromMap(Map<Object?, Object?> value) {
    final box = (value['bbox'] as List?)?.cast<num>();
    if (box == null || box.length != 4) {
      throw const FormatException('OCR line requires four box coordinates');
    }
    final coordinates = box.map((v) => v.toDouble()).toList();
    final confidence = (value['confidence'] as num?)?.toDouble() ?? 0;
    if (coordinates.any((v) => !v.isFinite) ||
        coordinates[2] < coordinates[0] ||
        coordinates[3] < coordinates[1] ||
        !confidence.isFinite ||
        confidence < 0 ||
        confidence > 1) {
      throw const FormatException('Invalid OCR line geometry or confidence');
    }
    return JobsOCRLine(
      text: value['text'] as String? ?? '',
      bbox: List.unmodifiable(coordinates),
      confidence: confidence,
    );
  }
}

class JobsOCRResult {
  const JobsOCRResult({
    required this.text,
    required this.lines,
    required this.width,
    required this.height,
    required this.elapsedMs,
    required this.engine,
  });

  final String text;
  final List<JobsOCRLine> lines;
  final int width;
  final int height;
  final double elapsedMs;
  final String engine;

  factory JobsOCRResult.fromMap(Map<Object?, Object?> value) {
    final width = (value['width'] as num?)?.toInt() ?? 0;
    final height = (value['height'] as num?)?.toInt() ?? 0;
    if (width <= 0 || height <= 0 || value['text'] is! String) {
      throw const FormatException('Invalid OCR result');
    }
    return JobsOCRResult(
      text: value['text'] as String,
      lines: List.unmodifiable(
        (value['lines'] as List? ?? const []).map(
          (line) =>
              JobsOCRLine.fromMap(Map<Object?, Object?>.from(line as Map)),
        ),
      ),
      width: width,
      height: height,
      elapsedMs: (value['elapsed_ms'] as num?)?.toDouble() ?? 0,
      engine: value['engine'] as String? ?? '',
    );
  }
}

abstract interface class JobsOCRClient {
  Future<String> coreVersion();
  Future<Uint8List> sampleImage();
  Future<JobsOCRResult> recognize({Uint8List? image});
  Future<void> cancel();
}

/// Only the platform bridge owns model loading and the shared Rust engine.
class JobsRustOCR implements JobsOCRClient {
  const JobsRustOCR();

  static const channel = MethodChannel('jobs/rust_ocr');

  @override
  Future<String> coreVersion() async =>
      await channel.invokeMethod<String>('coreVersion') ?? '';

  @override
  Future<Uint8List> sampleImage() async {
    final value = await channel.invokeMethod<Uint8List>('sampleImage');
    if (value == null || value.isEmpty) {
      throw const FormatException('Bundled OCR sample is unavailable');
    }
    return value;
  }

  @override
  Future<JobsOCRResult> recognize({Uint8List? image}) async {
    final value = await channel.invokeMapMethod<Object?, Object?>(
      image == null ? 'recognizeSample' : 'recognizeImage',
      image == null ? null : {'bytes': image},
    );
    if (value == null) throw const FormatException('OCR returned no result');
    return JobsOCRResult.fromMap(value);
  }

  @override
  Future<void> cancel() => channel.invokeMethod<void>('cancel');
}
