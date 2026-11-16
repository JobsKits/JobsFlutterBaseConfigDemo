import 'dart:ui' as ui;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';
import 'package:jobs_flutter_base_config/demo_hub/curated_catalog.dart';
import 'package:jobs_flutter_base_config/demo_hub/legacy_catalog.dart';
import 'package:jobs_flutter_base_config/demo_hub/parallel_catalog.dart';
import 'package:jobs_flutter_base_config/demo_hub/native_catalog.dart';
import 'package:jobs_flutter_base_config/demo_hub/data_parity_catalog.dart';
import 'package:jobs_flutter_base_config/demo_hub/interop_catalog.dart';
import 'package:jobs_flutter_base_config/demo_hub/extra_catalog.dart';
import 'package:jobs_flutter_base_config/demo_hub/ui_parity_catalog.dart';
import 'package:jobs_flutter_base_config/demo_hub/platform_catalog.dart';
import 'package:jobs_flutter_base_config/demo_hub/geometry_strings.dart';
import 'package:jobs_flutter_base_config/demo_hub/interaction_strings.dart';
import 'package:jobs_flutter_base_config/demo_hub/workflow_strings.dart';
import 'package:jobs_flutter_base_config/demo_hub/render_strings.dart';
import 'package:jobs_flutter_base_config/demos/八向取景画廊/八向取景画廊.dart';
import 'package:jobs_flutter_base_config/demos/片段着色器实验室/片段着色器实验室.dart';
import 'package:jobs_flutter_base_config/demos/贝塞尔纸张翻页/贝塞尔纸张翻页.dart';
import 'package:jobs_flutter_base_config/demos/视觉素材共用/场景绘制.dart';
import 'package:shared_preferences/shared_preferences.dart';

const pages = <Widget>[
  FragmentShaderStudioPage(),
  BezierPageTurnPage(),
  EightDirectionGalleryPage(),
];

Future<void> mount(
  WidgetTester tester,
  Widget page, {
  Locale locale = const Locale('zh'),
  ThemeMode theme = ThemeMode.light,
  bool reducedMotion = false,
}) async {
  await tester.pumpWidget(
    JobsDemoApp(
      settings: JobsDemoSettings(locale: locale, themeMode: theme),
      showSettings: false,
      home: Builder(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(disableAnimations: reducedMotion),
          child: page,
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 950));
}

Future<void> unmount(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(seconds: 1));
  expect(tester.takeException(), isNull);
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('18个入口具有独立ID、文件与十语标题，分组亦完整翻译', () {
    expect(curatedDemos.length, 18);
    expect(curatedDemos.map((entry) => entry.id).toSet().length, 18);
    final allIds = [
      ...curatedDemos.map((e) => e.id),
      ...legacyDemos.map((e) => e.id),
      ...parallelDemos.map((e) => e.id),
      ...nativeDemos.map((e) => e.id),
      ...dataParityDemos.map((e) => e.id),
      ...interopDemos.map((e) => e.id),
      ...extraDemos.map((e) => e.id),
      ...uiParityDemos.map((e) => e.id),
      ...platformDemos.map((e) => e.id),
    ];
    expect(allIds.toSet().length, allIds.length);
    debugPrint('当前目录入口总数: ${allIds.length}');
    final translations = {
      ...geometryTranslations,
      ...interactionTranslations,
      ...workflowTranslations,
      ...renderTranslations,
    };
    for (final entry in curatedDemos) {
      expect(File(entry.sourcePath).existsSync(), isTrue, reason: entry.id);
      expect(
        File(entry.sourcePath).readAsStringSync(),
        matches(RegExp(r'\bmain\s*\(')),
        reason: entry.id,
      );
      for (final key in [entry.title, entry.group]) {
        expect(translations[key]?.length, 10, reason: key);
        expect(
          translations[key]!.every((v) => v.trim().isNotEmpty),
          isTrue,
          reason: key,
        );
      }
    }
    for (final entry in renderTranslations.entries) {
      expect(entry.value.length, 10, reason: entry.key);
      expect(
        entry.value.every((v) => v.trim().isNotEmpty),
        isTrue,
        reason: entry.key,
      );
    }
  });

  test('画廊边界及响应校验保留有效空态并拒绝畸形数据', () {
    expect(const GalleryPosition(0, 0).move(-1, -1).index, 0);
    expect(const GalleryPosition(2, 2).move(1, 1).index, 8);
    expect(const GalleryPosition(1, 1).move(-1, 1).index, 6);
    expect(parseGalleryScenes({'scenes': <int>[]}), isEmpty);
    expect(
      parseGalleryScenes({
        'scenes': [8, 0, 3],
      }),
      [8, 0, 3],
    );
    for (final value in [
      null,
      {},
      {
        'scenes': [1, 1],
      },
      {
        'scenes': [1.2],
      },
      {
        'scenes': [double.nan],
      },
      {
        'scenes': [9],
      },
      {
        'scenes': ['1'],
      },
    ]) {
      expect(parseGalleryScenes(value), isNull);
    }
  });

  test('折页正反半平面、四角退化与越界拖动均保持有限几何', () {
    const size = Size(400, 320);
    final folded = FoldedPageGeometry.calculate(
      size,
      const Offset(400, 320),
      const Offset(200, 240),
    );
    expect(folded.front.contains(const Offset(10, 10)), isTrue);
    expect(folded.front.contains(const Offset(395, 315)), isFalse);
    expect(folded.back.computeMetrics().isNotEmpty, isTrue);
    expect(folded.crease.length, 2);
    for (final corner in [
      Offset.zero,
      const Offset(400, 0),
      const Offset(0, 320),
      const Offset(400, 320),
    ]) {
      for (final touch in [
        corner,
        const Offset(-300, 500),
        const Offset(700, -90),
      ]) {
        final geometry = FoldedPageGeometry.calculate(size, corner, touch);
        for (final path in [geometry.front, geometry.back]) {
          final bounds = path.getBounds();
          expect(
            [
              bounds.left,
              bounds.top,
              bounds.right,
              bounds.bottom,
            ].every((v) => v.isFinite),
            isTrue,
          );
        }
      }
    }
  });

  testWidgets('三页十语、窄宽窗口与明暗主题均可构建及销毁', (tester) async {
    final semantics = tester.ensureSemantics();
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    for (var index = 0; index < jobsDemoLocales.length; index++) {
      tester.view.physicalSize = index.isEven
          ? const Size(320, 700)
          : const Size(1100, 800);
      for (final theme in [ThemeMode.light, ThemeMode.dark]) {
        for (final page in pages) {
          await mount(
            tester,
            page,
            locale: jobsDemoLocales[index],
            theme: theme,
            reducedMotion: true,
          );
          expect(
            tester.takeException(),
            isNull,
            reason: '${page.runtimeType}/$index/$theme',
          );
          await unmount(tester);
        }
      }
    }
    semantics.dispose();
  });

  testWidgets('书页按钮翻页、短拖回弹与后台取消不提交半页', (tester) async {
    await mount(tester, const BezierPageTurnPage());
    final next = find.text(renderTranslations['render.next']!.first);
    await tester.scrollUntilVisible(next, 200);
    await tester.ensureVisible(next);
    await tester.pump();
    await tester.tap(next);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 450));
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('book-page'))).data,
      contains('2 / 3'),
    );
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('book-paper')),
      -200,
    );
    await tester.ensureVisible(find.byKey(const ValueKey('book-paper')));
    await tester.pump();
    final rect = tester.getRect(find.byKey(const ValueKey('book-paper')));
    await tester.dragFrom(
      rect.centerRight - const Offset(12, 0),
      const Offset(-35, 0),
    );
    await tester.pump();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump(const Duration(seconds: 1));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('book-page')),
      200,
    );
    await tester.ensureVisible(find.byKey(const ValueKey('book-page')));
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('book-page'))).data,
      contains('2 / 3'),
    );
    await unmount(tester);
  });

  testWidgets('画廊斜向拖动和键盘实际更新取景坐标', (tester) async {
    await mount(tester, const EightDirectionGalleryPage(), reducedMotion: true);
    await tester.drag(
      find.byKey(const ValueKey('gallery-viewfinder')),
      const Offset(-65, -65),
    );
    await tester.pump();
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('gallery-position'))).data,
      contains('3 / 3'),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pump();
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('gallery-position'))).data,
      contains('3 / 2'),
    );
    await unmount(tester);
  });

  testWidgets('减弱动画下可手动控制Shader时相且后台无ticker残留', (tester) async {
    await mount(tester, const FragmentShaderStudioPage(), reducedMotion: true);
    await tester.scrollUntilVisible(
      find.text(renderTranslations['render.wave']!.first),
      200,
    );
    await tester.tap(find.text(renderTranslations['render.wave']!.first));
    await tester.pump();
    final time = find.byKey(const ValueKey('shader-manual-time'));
    await tester.scrollUntilVisible(time, 240);
    final slider = tester.widget<Slider>(time);
    slider.onChanged!(4.5);
    await tester.pump();
    expect(tester.widget<Slider>(time).value, 4.5);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump(const Duration(seconds: 3));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    expect(tester.widget<Slider>(time).value, 4.5);
    await unmount(tester);
  });

  testWidgets('场景纹理是真实绘制的图像且可释放', (tester) async {
    ui.Image? texture;
    await tester.runAsync(
      () async => texture = await createCuratedTexture(Brightness.light),
    );
    expect(texture!.width, 768);
    expect(texture!.height, 512);
    texture!.dispose();
  });

  testWidgets('编译后的FragmentProgram真实采样并输出不同效果', (tester) async {
    await tester.runAsync(() async {
      final program = await ui.FragmentProgram.fromAsset(
        'shaders/jobs_visual_effects.frag',
      );
      final texture = await createCuratedTexture(Brightness.light);
      try {
        Future<List<int>> render(int mode, double strength) async {
          final shader = program.fragmentShader();
          final values = [
            96.0,
            64.0,
            2.3,
            .5,
            .5,
            strength,
            .32,
            1.0,
            mode.toDouble(),
            0.0,
          ];
          for (var i = 0; i < values.length; i++) {
            shader.setFloat(i, values[i]);
          }
          shader.setImageSampler(0, texture);
          final recorder = ui.PictureRecorder();
          final canvas = Canvas(recorder);
          canvas.drawRect(
            const Rect.fromLTWH(0, 0, 96, 64),
            Paint()..shader = shader,
          );
          final picture = recorder.endRecording();
          final image = await picture.toImage(96, 64);
          try {
            final bytes = await image.toByteData(
              format: ui.ImageByteFormat.rawRgba,
            );
            return bytes!.buffer.asUint8List().toList();
          } finally {
            image.dispose();
            picture.dispose();
            shader.dispose();
          }
        }

        final original = await render(0, 0);
        expect(original.where((v) => v > 0).length, greaterThan(96 * 64));
        for (var mode = 0; mode < 4; mode++) {
          final output = await render(mode, 1);
          var different = 0;
          for (var i = 0; i < output.length; i++) {
            if (output[i] != original[i]) different++;
          }
          expect(
            different,
            greaterThan(50),
            reason: 'mode $mode must alter real texture samples',
          );
        }
      } finally {
        texture.dispose();
      }
    });
  });
}
