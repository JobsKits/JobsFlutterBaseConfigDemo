import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';
import 'package:jobs_interactive_geometry/jobs_interactive_geometry.dart';

import 'package:jobs_flutter_base_config/demo_hub/geometry_strings.dart';
import 'package:jobs_flutter_base_config/demos/圆弧拖动进度/圆弧拖动进度.dart';
import 'package:jobs_flutter_base_config/demos/迟滞霓虹滑块/迟滞霓虹滑块.dart';
import 'package:jobs_flutter_base_config/demos/透视螺旋列表/透视螺旋列表.dart';
import 'package:jobs_flutter_base_config/demos/矩阵坐标实验/矩阵坐标实验.dart';
import 'package:jobs_flutter_base_config/demos/粒子形态实验/粒子形态实验.dart';
import 'package:jobs_flutter_base_config/demos/几何表面实验/几何表面实验.dart';

const _pages = <Widget>[
  ArcProgressPage(),
  HysteresisSliderPage(),
  PerspectiveSpiralPage(),
  MatrixCoordinatesPage(),
  ParticleShapesPage(),
  GeometrySurfacesPage(),
];

Future<void> _page(
  WidgetTester tester,
  Widget page, {
  Locale locale = const Locale('zh'),
  ThemeMode theme = ThemeMode.light,
}) async {
  final settings = JobsDemoSettings(locale: locale, themeMode: theme);
  addTearDown(settings.dispose);
  await tester.pumpWidget(
    JobsDemoApp(home: page, settings: settings, showSettings: false),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 80));
}

void main() {
  setUp(registerGeometryTranslations);

  test('几何全部文案有十种非空翻译', () {
    for (final entry in geometryTranslations.entries) {
      expect(entry.value.length, 10, reason: entry.key);
      expect(
        entry.value.every((v) => v.trim().isNotEmpty),
        isTrue,
        reason: entry.key,
      );
    }
  });

  testWidgets('六个操作页在320窄屏和1100宽屏、明暗主题均正常布局并销毁ticker', (tester) async {
    addTearDown(() => tester.view.resetPhysicalSize());
    addTearDown(() => tester.view.resetDevicePixelRatio());
    tester.view.devicePixelRatio = 1;
    for (final size in const [Size(320, 680), Size(1100, 720)]) {
      tester.view.physicalSize = size;
      for (final theme in [ThemeMode.light, ThemeMode.dark]) {
        for (final page in _pages) {
          await _page(tester, page, theme: theme);
          expect(
            tester.takeException(),
            isNull,
            reason: '${page.runtimeType}/$size/$theme',
          );
          expect(find.byType(JobsGeometryLabLayout), findsOneWidget);
          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pump();
          expect(tester.takeException(), isNull);
        }
      }
    }
  });

  testWidgets('十种语言在页面内实际切换标题', (tester) async {
    for (var i = 0; i < jobsDemoLocales.length; i++) {
      await tester.pumpWidget(const SizedBox.shrink());
      await _page(tester, const ArcProgressPage(), locale: jobsDemoLocales[i]);
      expect(find.text(geometryTranslations['圆弧拖动进度']![i]), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('圆弧和霓虹滑块可用键盘而不依赖拖动', (tester) async {
    var arcValue = .35, neonValue = .25;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => Column(
              children: [
                SizedBox(
                  height: 240,
                  child: JobsArcSlider(
                    value: arcValue,
                    onChanged: (v) => setState(() => arcValue = v),
                    semanticLabel: 'arc',
                  ),
                ),
                JobsNeonSlider(
                  value: neonValue,
                  onChanged: (v) => setState(() => neonValue = v),
                  semanticLabel: 'neon',
                ),
              ],
            ),
          ),
        ),
      ),
    );
    final arcFocus = find
        .descendant(
          of: find.byType(JobsArcSlider),
          matching: find.byType(Focus),
        )
        .first;
    Focus.of(
      tester.element(
        find.descendant(of: arcFocus, matching: find.byType(Semantics)).first,
      ),
    ).requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(arcValue, closeTo(.37, 1e-9));
    await tester.sendKeyEvent(LogicalKeyboardKey.end);
    expect(arcValue, 1);
    final neonFocus = tester.widget<Focus>(
      find
          .descendant(
            of: find.byType(JobsNeonSlider),
            matching: find.byType(Focus),
          )
          .first,
    );
    final focusContext = tester.element(
      find
          .descendant(
            of: find.byType(JobsNeonSlider),
            matching: find.byType(Semantics),
          )
          .first,
    );
    expect(neonFocus.onKeyEvent, isNotNull);
    Focus.of(focusContext).requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    expect(neonValue, closeTo(.23, 1e-9));
  });

  testWidgets('霓虹主画布在窄宽屏都有实际宽度且真实拖动改变值', (tester) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final size in const [Size(320, 700), Size(1100, 800)]) {
      tester.view.physicalSize = size;
      await _page(tester, const HysteresisSliderPage());
      final slider = find.byType(JobsNeonSlider);
      final paint = find.descendant(
        of: slider,
        matching: find.byType(CustomPaint),
      );
      final rect = tester.getRect(paint);
      expect(rect.width, greaterThan(150), reason: '$size');
      expect(rect.height, 72);
      final before = tester.widget<JobsNeonSlider>(slider).value;
      await tester.dragFrom(
        Offset(rect.left + rect.width * .15, rect.center.dy),
        Offset(rect.width * .65, 0),
      );
      await tester.pump();
      final after = tester.widget<JobsNeonSlider>(slider).value;
      expect(after, isNot(before));
      expect(after, inInclusiveRange(.75, .85));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    }
  });

  testWidgets('迟滞按钮穿越门限后只触发一次，复位后可再次触发', (tester) async {
    tester.view.physicalSize = const Size(1100, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await _page(tester, const HysteresisSliderPage());
    Future<void> press(String label) async {
      final button = find.widgetWithText(OutlinedButton, label);
      await tester.ensureVisible(button);
      await tester.tap(button);
      await tester.pump();
    }

    await press('99%');
    await press('100%');
    await press('95%');
    await press('99%');
    expect(find.textContaining('触发次数: 1'), findsOneWidget);
    await press('89%');
    await press('99%');
    expect(find.textContaining('触发次数: 2'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('矩阵局部命中和螺旋按钮选项连接到实际页面状态', (tester) async {
    tester.view.physicalSize = const Size(1100, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await _page(tester, const MatrixCoordinatesPage());
    await tester.tapAt(
      tester.getCenter(find.byType(JobsGeometryCanvas)) +
          const Offset(-67.5, -20),
    );
    await tester.pump();
    expect(find.textContaining('选中项目: 1'), findsOneWidget);
    expect(find.textContaining('局部坐标: (-67.5, -20.0)'), findsOneWidget);
    final selectSecond = find.widgetWithText(OutlinedButton, '选中项目 2');
    await tester.ensureVisible(selectSecond);
    await tester.tap(selectSecond);
    await tester.pump();
    expect(find.textContaining('选中项目: 2'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await _page(tester, const PerspectiveSpiralPage());
    await tester.ensureVisible(find.text('后一项'));
    await tester.tap(find.text('后一项'));
    await tester.pump();
    expect(find.text('选中项目: 16'), findsOneWidget);
    await tester.tap(find.text('前一项'));
    await tester.pump();
    expect(find.text('选中项目: 15'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('动画时钟尊重暂停、TickerMode、减弱动画和后台，恢复无大delta', (tester) async {
    var ticks = 0;
    var maxDelta = 0.0;
    Future<void> clock({
      bool paused = false,
      bool enabled = true,
      bool reduce = false,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(disableAnimations: reduce),
            child: TickerMode(
              enabled: enabled,
              child: JobsGeometryClock(
                paused: paused,
                onTick: (dt) {
                  ticks++;
                  if (dt > maxDelta) maxDelta = dt;
                },
                builder: (_, elapsed) => Text('$elapsed'),
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 30));
      await tester.pump(const Duration(milliseconds: 30));
    }

    await clock();
    expect(ticks, greaterThan(0));
    for (final mode in [0, 1, 2]) {
      await clock(paused: mode == 0, enabled: mode != 1, reduce: mode == 2);
      final before = ticks;
      await tester.pump(const Duration(seconds: 2));
      expect(ticks, before);
    }
    await clock();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    final before = ticks;
    await tester.pump(const Duration(seconds: 5));
    expect(ticks, before);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump(const Duration(seconds: 10));
    await tester.pump(const Duration(milliseconds: 16));
    expect(maxDelta, lessThanOrEqualTo(.05));
    await tester.pumpWidget(const SizedBox.shrink());
    expect(tester.takeException(), isNull);
  });

  testWidgets('粒子形态能切换真实吸引子、单步推进，面片球能切换及暂停', (tester) async {
    tester.view.physicalSize = const Size(1100, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await _page(tester, const ParticleShapesPage());
    await tester.tap(find.byType(DropdownButtonFormField<ParticleMode>));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Lorenz').last);
    await tester.pump();
    expect(find.textContaining('σ=10'), findsOneWidget);
    expect(find.text('变形进度'), findsNothing);
    await tester.ensureVisible(find.text('暂停'));
    await tester.tap(find.text('暂停'));
    await tester.pump();
    expect(find.text('播放'), findsOneWidget);
    await tester.tap(find.text('单步'));
    await tester.pump();
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await _page(tester, const GeometrySurfacesPage());
    await tester.tap(find.text('面片球'));
    await tester.pump();
    expect(
      tester
          .widget<ChoiceChip>(
            find.ancestor(
              of: find.text('面片球'),
              matching: find.byType(ChoiceChip),
            ),
          )
          .selected,
      isTrue,
    );
    await tester.ensureVisible(find.text('暂停'));
    await tester.tap(find.text('暂停'));
    await tester.pump();
    await tester.tap(find.text('单步'));
    await tester.pump();
    expect(find.text('播放'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
