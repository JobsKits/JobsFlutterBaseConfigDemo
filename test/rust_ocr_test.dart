// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
// image_picker's public platform seam verifies the real plugin source selection.
// ignore: depend_on_referenced_packages
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';
import 'package:jobs_rust_ocr/jobs_rust_ocr.dart';

import 'package:jobs_flutter_base_config/demos/离线文字识别/离线文字识别.dart';
import 'package:jobs_flutter_base_config/demos/离线文字识别/识别文案.dart';

import 'support/flutter_fonts.dart';

final _sample = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+a7h8AAAAASUVORK5CYII=',
);
const _captureUI = bool.fromEnvironment('CAPTURE_OCR_UI');
final _captureKey = GlobalKey();

Map<String, Object> _resultMap([String text = 'Rust OCR']) => {
  'text': text,
  'width': 200,
  'height': 100,
  'elapsed_ms': 24.5,
  'engine': 'jobs-rust-ocr/indra',
  'lines': [
    {
      'text': text,
      'bbox': [10, 20, 180, 50],
      'confidence': 0.94,
    },
  ],
};

class _Client implements JobsOCRClient {
  Completer<JobsOCRResult>? pending;
  Object? loadError;
  int cancellations = 0;
  int recognitions = 0;
  String text = 'Rust OCR';
  Uint8List? lastImage;
  Uint8List? sampleOverride;

  @override
  Future<String> coreVersion() async => 'test-core';

  @override
  Future<Uint8List> sampleImage() async {
    if (loadError case final error?) throw error;
    return sampleOverride ?? _sample;
  }

  @override
  Future<JobsOCRResult> recognize({Uint8List? image}) {
    recognitions++;
    lastImage = image;
    return pending?.future ??
        Future.value(JobsOCRResult.fromMap(_resultMap(text)));
  }

  @override
  Future<void> cancel() async => cancellations++;
}

class _Picker extends ImagePickerPlatform {
  final sources = <ImageSource>[];
  final optionsReceived = <ImagePickerOptions>[];
  XFile? result;
  Object? failure;
  Completer<XFile?>? pending;

  @override
  Future<XFile?> getImageFromSource({
    required ImageSource source,
    ImagePickerOptions options = const ImagePickerOptions(),
  }) async {
    sources.add(source);
    optionsReceived.add(options);
    if (failure case final error?) throw error;
    return pending?.future ?? result;
  }
}

void _installPicker(_Picker picker) {
  final original = ImagePickerPlatform.instance;
  ImagePickerPlatform.instance = picker;
  addTearDown(() => ImagePickerPlatform.instance = original);
}

double _contrast(Color foreground, Color background) {
  final first = foreground.computeLuminance();
  final second = background.computeLuminance();
  return (first > second ? first + .05 : second + .05) /
      (first > second ? second + .05 : first + .05);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'native protocol sends bytes and parses geometry without inventing text',
    () async {
      final calls = <MethodCall>[];
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(JobsRustOCR.channel, (call) async {
        calls.add(call);
        return call.method == 'cancel' ? null : _resultMap();
      });
      addTearDown(
        () => messenger.setMockMethodCallHandler(JobsRustOCR.channel, null),
      );
      final result = await const JobsRustOCR().recognize(image: _sample);
      expect(calls.single.method, 'recognizeImage');
      expect((calls.single.arguments as Map)['bytes'], _sample);
      expect(result.text, 'Rust OCR');
      expect(result.lines.single.bbox, [10.0, 20.0, 180.0, 50.0]);
      expect(result.elapsedMs, 24.5);
      await const JobsRustOCR().cancel();
      expect(calls.last.method, 'cancel');
    },
  );

  test(
    'malformed native geometry fails instead of reporting recognition success',
    () {
      final data = _resultMap();
      data['lines'] = [
        {
          'text': 'bad',
          'bbox': [1, 2],
          'confidence': 1.0,
        },
      ];
      expect(() => JobsOCRResult.fromMap(data), throwsFormatException);
    },
  );

  test('OCR dictionary covers all ten supported locales', () {
    registerOCRTranslations();
    for (final row in ocrTranslations.values) {
      expect(row, hasLength(10));
      expect(row.every((text) => text.trim().isNotEmpty), isTrue);
    }
  });

  Future<void> mount(
    WidgetTester tester,
    _Client client, {
    bool auto = false,
    ValueChanged<JobsOCRResult>? onResult,
    ValueChanged<Object>? onFailure,
    Locale locale = const Locale('en'),
    ThemeMode theme = ThemeMode.light,
  }) async {
    final settings = JobsDemoSettings(locale: locale, themeMode: theme);
    addTearDown(settings.dispose);
    await tester.pumpWidget(
      JobsDemoApp(
        home: Builder(
          builder: (context) {
            final inherited = Theme.of(context);
            return Theme(
              data: !_captureUI
                  ? inherited
                  : inherited.copyWith(
                      textTheme: inherited.textTheme.apply(
                        fontFamily: 'JobsOCRCapture',
                      ),
                      primaryTextTheme: inherited.primaryTextTheme.apply(
                        fontFamily: 'JobsOCRCapture',
                      ),
                    ),
              child: RepaintBoundary(
                key: _captureKey,
                child: RustOCRDemo(
                  client: client,
                  autoRecognize: auto,
                  onResult: onResult,
                  onFailure: onFailure,
                ),
              ),
            );
          },
        ),
        settings: settings,
        showSettings: false,
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'camera and gallery select their real picker source and pass bytes',
    (tester) async {
      final picker = _Picker()
        ..result = XFile.fromData(_sample, name: 'capture.png');
      _installPicker(picker);
      final client = _Client();
      await mount(tester, client);
      for (final key in ['rust-ocr-camera', 'rust-ocr-gallery']) {
        await tester.ensureVisible(find.byKey(ValueKey(key)));
        await tester.tap(find.byKey(ValueKey(key)));
        await tester.pumpAndSettle();
        await tester.ensureVisible(
          find.byKey(const ValueKey('rust-ocr-recognize')),
        );
        await tester.tap(find.byKey(const ValueKey('rust-ocr-recognize')));
        await tester.pumpAndSettle();
        expect(client.lastImage, _sample);
      }
      expect(picker.sources, [ImageSource.camera, ImageSource.gallery]);
      expect(
        picker.optionsReceived.every((options) => !options.requestFullMetadata),
        isTrue,
      );
      expect(client.recognitions, 2);
    },
  );

  testWidgets(
    'cancelled capture preserves the current recognized image and result',
    (tester) async {
      final picker = _Picker();
      _installPicker(picker);
      final client = _Client();
      await mount(tester, client);
      await tester.tap(find.byKey(const ValueKey('rust-ocr-recognize')));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const ValueKey('rust-ocr-camera')));
      await tester.tap(find.byKey(const ValueKey('rust-ocr-camera')));
      await tester.pumpAndSettle();
      expect(picker.sources, [ImageSource.camera]);
      expect(find.text('Rust OCR'), findsOneWidget);
      expect(find.byKey(const ValueKey('rust-ocr-image-error')), findsNothing);
      expect(client.recognitions, 1);
    },
  );

  testWidgets(
    'unavailable camera and permission errors preserve results with recovery guidance',
    (tester) async {
      final picker = _Picker()
        ..failure = PlatformException(code: 'camera_unavailable');
      _installPicker(picker);
      final client = _Client();
      await mount(tester, client);
      await tester.tap(find.byKey(const ValueKey('rust-ocr-recognize')));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const ValueKey('rust-ocr-camera')));
      await tester.tap(find.byKey(const ValueKey('rust-ocr-camera')));
      await tester.pumpAndSettle();
      expect(
        find.text(
          'Camera unavailable on this device or simulator. Use the gallery or sample.',
        ),
        findsOneWidget,
      );
      expect(find.text('Rust OCR'), findsOneWidget);
      picker.failure = PlatformException(code: 'camera_access_denied');
      await tester.tap(find.byKey(const ValueKey('rust-ocr-camera')));
      await tester.pumpAndSettle();
      expect(
        find.text('Allow camera access in system settings to take a photo.'),
        findsOneWidget,
      );
      expect(find.text('Rust OCR'), findsOneWidget);
    },
  );

  testWidgets(
    'picker returning after page disposal cannot update the former page',
    (tester) async {
      final picker = _Picker()..pending = Completer<XFile?>();
      _installPicker(picker);
      await mount(tester, _Client());
      await tester.tap(find.byKey(const ValueKey('rust-ocr-camera')));
      await tester.pump();
      await tester.pumpWidget(const SizedBox.shrink());
      picker.pending!.complete(XFile.fromData(_sample, name: 'late.png'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'long results scroll with the page and the result header copies the full text',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 700);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      final client = _Client()
        ..text = List.generate(
          100,
          (index) => 'Line ${index + 1}: offline OCR text',
        ).join('\n');
      final copied = <String>[];
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
        if (call.method == 'Clipboard.setData') {
          copied.add((call.arguments as Map)['text'] as String);
        }
        return null;
      });
      addTearDown(
        () => messenger.setMockMethodCallHandler(SystemChannels.platform, null),
      );
      await mount(tester, client);
      await tester.ensureVisible(
        find.byKey(const ValueKey('rust-ocr-recognize')),
      );
      await tester.tap(find.byKey(const ValueKey('rust-ocr-recognize')));
      await tester.pumpAndSettle();
      final text = tester.widget<SelectableText>(
        find.byKey(const ValueKey('rust-ocr-text')),
      );
      expect(text.maxLines, isNull);
      expect(text.scrollPhysics, isA<NeverScrollableScrollPhysics>());
      final page = tester.state<ScrollableState>(find.byType(Scrollable).first);
      page.position.jumpTo(page.position.maxScrollExtent / 2);
      await tester.pump();
      final before = page.position.pixels;
      await tester.dragFrom(const Offset(160, 400), const Offset(0, -180));
      await tester.pumpAndSettle();
      expect(page.position.pixels, greaterThan(before));
      await tester.ensureVisible(find.byKey(const ValueKey('rust-ocr-copy')));
      await tester.tap(find.byKey(const ValueKey('rust-ocr-copy')));
      await tester.pumpAndSettle();
      expect(copied, [client.text]);
      expect(find.text('Text copied'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'input and compact start buttons remain readable in ten locales and both themes',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 700);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      for (final locale in jobsDemoLocales) {
        for (final theme in [ThemeMode.light, ThemeMode.dark]) {
          await mount(tester, _Client(), locale: locale, theme: theme);
          final input = tester.widget<OutlinedButton>(
            find.byKey(const ValueKey('rust-ocr-camera')),
          );
          final start = tester.widget<FilledButton>(
            find.byKey(const ValueKey('rust-ocr-recognize')),
          );
          for (final style in [input.style!, start.style!]) {
            for (final states in [
              <WidgetState>{},
              {WidgetState.disabled},
            ]) {
              final foreground = style.foregroundColor!.resolve(states)!;
              final background = style.backgroundColor!.resolve(states)!;
              expect(
                _contrast(foreground, background),
                greaterThanOrEqualTo(4.5),
                reason: '$locale / $theme / $states',
              );
            }
          }
          await tester.ensureVisible(
            find.byKey(const ValueKey('rust-ocr-recognize')),
          );
          final size = tester.getSize(
            find.byKey(const ValueKey('rust-ocr-recognize')),
          );
          expect(
            size.height,
            inInclusiveRange(44, 56),
            reason: '$locale / $theme',
          );
          expect(
            size.width,
            lessThanOrEqualTo(288),
            reason: '$locale / $theme',
          );
          expect(start.style!.fixedSize, isNull);
          if (locale.languageCode == 'zh') {
            expect(size.width, lessThan(240), reason: '$locale / $theme');
          } else if (locale.languageCode == 'en') {
            expect(size.width, lessThan(288), reason: '$locale / $theme');
          }
          expect(tester.takeException(), isNull, reason: '$locale / $theme');
          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pump();
        }
      }
    },
  );

  testWidgets(
    'capture OCR inputs and result with actual fonts and the bundled image',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      final output = Directory('项目相关报告/截图/OCR交互');
      await tester.runAsync(() async {
        final fontFile = File(
          const String.fromEnvironment(
            'OCR_CAPTURE_FONT',
            defaultValue: '/System/Library/Fonts/STHeiti Medium.ttc',
          ),
        );
        final font = FontLoader('JobsOCRCapture')
          ..addFont(
            Future.value(ByteData.sublistView(await fontFile.readAsBytes())),
          );
        await font.load();
        final icons = FontLoader('MaterialIcons')
          ..addFont(
            Future.value(
              ByteData.sublistView(
                await flutterMaterialFont(
                  'MaterialIcons-Regular.otf',
                ).readAsBytes(),
              ),
            ),
          );
        await icons.load();
        await output.create(recursive: true);
      });
      Future<void> capture(String filename) async {
        await tester.pump();
        final boundary =
            _captureKey.currentContext!.findRenderObject()!
                as RenderRepaintBoundary;
        await tester.runAsync(() async {
          final image = await boundary.toImage(pixelRatio: 2);
          final data = await image.toByteData(format: ui.ImageByteFormat.png);
          await File('${output.path}/$filename.png')
              .writeAsBytes(data!.buffer.asUint8List());
          image.dispose();
        });
      }

      for (final theme in [ThemeMode.light, ThemeMode.dark]) {
        final client = _Client()
          ..sampleOverride = File(
            'JobsByPubs/JobsRustOCRByPub/ios/JobsRustOCR/Resource/JobsRustOCRResources.bundle/sample.png',
          ).readAsBytesSync()
          ..text = List.generate(
            16,
            (index) => '第${index + 1}行：在设备上识别文字，结果可以快捷复制。',
          ).join('\n');
        await mount(tester, client, locale: const Locale('zh'), theme: theme);
        await tester.runAsync(() async {
          await precacheImage(
            MemoryImage(client.sampleOverride!),
            tester.element(find.byType(RustOCRDemo)),
          );
        });
        await tester.pumpAndSettle();
        final label = theme == ThemeMode.light ? '浅色' : '深色';
        await capture('FlutterOCR-$label-输入');
        await tester.ensureVisible(
          find.byKey(const ValueKey('rust-ocr-recognize')),
        );
        await tester.tap(find.byKey(const ValueKey('rust-ocr-recognize')));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.byKey(const ValueKey('rust-ocr-copy')));
        await capture('FlutterOCR-$label-结果');
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
      }
    },
    skip: !_captureUI,
  );

  testWidgets('explicit recognition displays the core result and copy action', (
    tester,
  ) async {
    final client = _Client();
    await mount(tester, client);
    expect(client.recognitions, 0);
    await tester.tap(find.byKey(const ValueKey('rust-ocr-recognize')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('rust-ocr-text')),
      150,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.byKey(const ValueKey('rust-ocr-text')), findsOneWidget);
    expect(find.text('Rust OCR'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Copy text'),
      150,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Copy text'), findsOneWidget);
  });

  testWidgets('cancel suppresses a late successful native callback', (
    tester,
  ) async {
    final client = _Client()..pending = Completer<JobsOCRResult>();
    await mount(tester, client);
    await tester.tap(find.byKey(const ValueKey('rust-ocr-recognize')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('rust-ocr-cancel')));
    await tester.pump();
    expect(client.cancellations, 1);
    client.pending!.complete(JobsOCRResult.fromMap(_resultMap()));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('rust-ocr-text')), findsNothing);
    expect(find.text('Recognition cancelled'), findsWidgets);
  });

  testWidgets('acceptance auto entry waits for a native result exactly once', (
    tester,
  ) async {
    final client = _Client()..pending = Completer<JobsOCRResult>();
    final results = <JobsOCRResult>[];
    final errors = <Object>[];
    // Do not pumpAndSettle while the real caller is still waiting for OCR.
    final settings = JobsDemoSettings(locale: const Locale('en'));
    addTearDown(settings.dispose);
    await tester.pumpWidget(
      JobsDemoApp(
        home: RustOCRDemo(
          client: client,
          autoRecognize: true,
          onResult: results.add,
          onFailure: errors.add,
        ),
        settings: settings,
        showSettings: false,
      ),
    );
    await tester.pump();
    expect(client.recognitions, 1);
    expect(results, isEmpty);
    final result = JobsOCRResult.fromMap(_resultMap('DIOCESE OF SEOUL'));
    client.pending!.complete(result);
    await tester.pumpAndSettle();
    expect(results, [same(result)]);
    expect(errors, isEmpty);
    await tester.tap(find.text('Bundled sample'));
    await tester.pumpAndSettle();
    expect(client.recognitions, 1);
    expect(results, hasLength(1));
  });

  testWidgets(
    'acceptance auto entry reports load failure without recognition',
    (tester) async {
      final client = _Client()
        ..loadError = MissingPluginException('native absent');
      final results = <JobsOCRResult>[];
      final errors = <Object>[];
      await mount(
        tester,
        client,
        auto: true,
        onResult: results.add,
        onFailure: errors.add,
      );
      expect(client.recognitions, 0);
      expect(results, isEmpty);
      expect(errors.single, isA<MissingPluginException>());
    },
  );

  testWidgets(
    'missing native plugin remains an actionable error without fake results',
    (tester) async {
      final client = _Client()..loadError = MissingPluginException();
      await mount(tester, client);
      expect(find.byKey(const ValueKey('rust-ocr-text')), findsNothing);
      expect(
        find.text('The native OCR plugin is not connected on this platform'),
        findsOneWidget,
      );
      expect(find.text('Reload'), findsOneWidget);
      expect(client.recognitions, 0);
    },
  );
}
