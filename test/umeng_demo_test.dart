import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/Data/Data.3rd/Umeng/umeng_demo.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/Data/Data.3rd/Umeng/umeng_demo_page.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/Data/Data.3rd/Umeng/umeng_demo_sdk_client.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/Data/Data.3rd/Umeng/umeng_demo_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('未同意时不初始化，也不发送事件或异常', () async {
    final sdk = _FakeUmengSdk();
    final service = UmengDemoService(client: sdk);
    addTearDown(service.dispose);

    await service.initialize(consent: false);
    await service.trackEvent();
    await service.signIn('test_user_001');
    await service.reportCaughtException();

    expect(sdk.initializeCount, 0);
    expect(sdk.events, isEmpty);
    expect(sdk.signedInUser, isNull);
    expect(sdk.caughtExceptions, isEmpty);
    expect(service.isInitialized, isFalse);
  });

  test('初始化并发点击与初始化后再次点击只调用一次 SDK', () async {
    final sdk = _FakeUmengSdk()..initializationGate = Completer<void>();
    final service = UmengDemoService(client: sdk);
    addTearDown(service.dispose);

    final first = service.initialize(consent: true);
    final duplicate = service.initialize(consent: true);
    expect(service.isInitializing, isTrue);
    expect(sdk.initializeCount, 1);

    sdk.initializationGate!.complete();
    await Future.wait([first, duplicate]);
    await service.initialize(consent: true);

    expect(service.isInitialized, isTrue);
    expect(service.isInitializing, isFalse);
    expect(sdk.initializeCount, 1);
  });

  test('SDK 初始化失败保留重试能力', () async {
    final sdk = _FakeUmengSdk()..initializationFailures = 1;
    final service = UmengDemoService(client: sdk);
    addTearDown(service.dispose);

    await service.initialize(consent: true);
    expect(service.isInitialized, isFalse);
    expect(service.isInitializing, isFalse);
    expect(service.logs.any((log) => log.isError), isTrue);

    await service.initialize(consent: true);
    await service.trackEvent();

    expect(sdk.initializeCount, 2);
    expect(service.isInitialized, isTrue);
    expect(sdk.events.single, 'demo_button_click');
  });

  test('初始化未完成时释放服务不会在完成后重新通知或采集', () async {
    final sdk = _FakeUmengSdk()..initializationGate = Completer<void>();
    final service = UmengDemoService(client: sdk);
    service.setVisiblePage('/umeng');
    final initialization = service.initialize(consent: true);
    service.dispose();
    sdk.initializationGate!.complete();

    await expectLater(initialization, completes);
    expect(service.isInitialized, isFalse);
    expect(sdk.pageCalls, isEmpty);
  });

  test('路由切换和多次后台回调的页面开始结束保持配对', () async {
    final sdk = _FakeUmengSdk();
    final service = UmengDemoService(client: sdk);
    addTearDown(service.dispose);
    service.setVisiblePage('/umeng');
    await service.initialize(consent: true);

    service.setVisiblePage('/umeng');
    service.setVisiblePage('/umeng/detail');
    service.didChangeAppLifecycleState(AppLifecycleState.inactive);
    service.didChangeAppLifecycleState(AppLifecycleState.hidden);
    service.didChangeAppLifecycleState(AppLifecycleState.paused);
    service.didChangeAppLifecycleState(AppLifecycleState.resumed);
    service.didChangeAppLifecycleState(AppLifecycleState.resumed);
    service.setVisiblePage('/umeng');
    service.setVisiblePage(null);

    expect(sdk.pageCalls, [
      'start:/umeng',
      'end:/umeng',
      'start:/umeng/detail',
      'end:/umeng/detail',
      'start:/umeng/detail',
      'end:/umeng/detail',
      'start:/umeng',
      'end:/umeng',
    ]);
  });

  test('SDK 页面与未捕获异常接口抛错时记录失败并继续运行', () async {
    final sdk = _FakeUmengSdk()
      ..failPageCalls = true
      ..failUnhandledCapture = true;
    final service = UmengDemoService(client: sdk);
    addTearDown(service.dispose);
    await service.initialize(consent: true);

    expect(() => service.setVisiblePage('/umeng'), returnsNormally);
    expect(
      () => service.didChangeAppLifecycleState(AppLifecycleState.paused),
      returnsNormally,
    );
    expect(
      () => service.handleUnhandled(StateError('test error'), StackTrace.empty),
      returnsNormally,
    );
    expect(service.logs.where((log) => log.isError).length, 3);
  });

  testWidgets('窄屏大字支持空态、授权、统计操作与详情往返', (tester) async {
    _setCompactLargeTextView(tester);
    final sdk = _FakeUmengSdk();
    final service = UmengDemoService(client: sdk);
    addTearDown(service.dispose);
    await tester.pumpWidget(UmengDemoApp(service: service));
    await tester.pumpAndSettle();

    final eventButton = find.widgetWithText(FilledButton, '发送自定义事件');
    expect(tester.widget<FilledButton>(eventButton).onPressed, isNull);
    expect(find.text('暂无调用记录'), findsOneWidget);
    await _tapVisible(tester, find.text('重新加载日志'));
    expect(sdk.initializeCount, 0);
    expect(sdk.events, isEmpty);

    await _tapVisible(tester, find.byType(CheckboxListTile));
    await _tapVisible(tester, find.text('同意并初始化 / 重试'));
    expect(service.isInitialized, isTrue);
    expect(tester.widget<FilledButton>(eventButton).onPressed, isNotNull);
    await _tapVisible(tester, eventButton);
    await _tapVisible(tester, find.text('登录演示账号'));
    await _tapVisible(tester, find.text('捕获异常上报'));
    expect(sdk.events, ['demo_button_click']);
    expect(sdk.signedInUser, 'test_user_001');
    expect(sdk.caughtExceptions, hasLength(1));

    await _tapVisible(tester, find.text('打开统计子页'));
    expect(find.text('页面统计子页'), findsOneWidget);
    await _tapVisible(tester, find.text('返回演示主页'));
    expect(sdk.pageCalls, [
      'start:/',
      'end:/',
      'start:/umeng/detail',
      'end:/umeng/detail',
      'start:/',
    ]);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('白天、黑夜和跟随系统在大字窄屏保持可读且可切换', (tester) async {
    _setCompactLargeTextView(tester);
    final service = UmengDemoService(client: _FakeUmengSdk());
    addTearDown(service.dispose);
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    await tester.pumpWidget(UmengDemoApp(service: service));
    await tester.pumpAndSettle();
    _expectThemeContrast(tester, Brightness.light);

    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    await tester.pumpAndSettle();
    _expectThemeContrast(tester, Brightness.dark);

    await _selectTheme(tester, '主题：白天');
    _expectThemeContrast(tester, Brightness.light);

    tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    await _selectTheme(tester, '主题：黑夜');
    _expectThemeContrast(tester, Brightness.dark);

    await _selectTheme(tester, '主题：跟随系统');
    _expectThemeContrast(tester, Brightness.light);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('原生能力不可用时保留界面且不允许上报', (tester) async {
    final sdk = _FakeUmengSdk(supported: false);
    final service = UmengDemoService(client: sdk);
    addTearDown(service.dispose);
    await tester.pumpWidget(UmengDemoApp(service: service));
    await tester.pumpAndSettle();

    expect(find.textContaining('当前平台不支持此原生 SDK'), findsOneWidget);
    await _tapVisible(tester, find.byType(CheckboxListTile));
    expect(
      tester
          .widget<FilledButton>(
              find.widgetWithText(FilledButton, '同意并初始化 / 重试'))
          .onPressed,
      isNull,
    );
    expect(sdk.initializeCount, 0);
    expect(sdk.events, isEmpty);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('build 期间的 SDK 错误不会同步引发重复 build 错误', (tester) async {
    final sdk = _FakeUmengSdk();
    final service = UmengDemoService(client: sdk);
    addTearDown(service.dispose);
    await service.initialize(consent: true);
    var reportDuringBuild = false;

    Widget harness() => MaterialApp(
          home: Column(
            children: [
              Expanded(child: UmengDemoPage(service: service)),
              Builder(builder: (context) {
                if (reportDuringBuild) {
                  reportDuringBuild = false;
                  sdk.onError!(
                      StateError('SDK build callback'), StackTrace.empty);
                }
                return const SizedBox.shrink();
              }),
            ],
          ),
        );

    await tester.pumpWidget(harness());
    reportDuringBuild = true;
    await tester.pumpWidget(harness());
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(service.logs.first.isError, isTrue);
    expect(service.logs.first.message, contains('SDK build callback'));
    await tester.pumpWidget(const SizedBox.shrink());
  });
}

void _setCompactLargeTextView(WidgetTester tester) {
  tester.view.physicalSize = const Size(320, 640);
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = 2;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
}

Future<void> _tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> _selectTheme(WidgetTester tester, String label) async {
  await tester.tap(find.widgetWithText(ChoiceChip, label));
  await tester.pumpAndSettle();
}

void _expectThemeContrast(WidgetTester tester, Brightness brightness) {
  final context = tester.element(find.byType(UmengDemoPage));
  final colors = Theme.of(context).colorScheme;
  expect(Theme.of(context).brightness, brightness);
  final pairs = [
    (colors.onSurface, colors.surface),
    (Color.lerp(colors.onSurface, colors.surface, 0.18)!, colors.surface),
    (colors.onSurface, colors.surfaceContainerHighest),
    (colors.onPrimaryContainer, colors.primaryContainer),
    (colors.onErrorContainer, colors.errorContainer),
  ];
  for (final (foreground, background) in pairs) {
    final first = foreground.computeLuminance();
    final second = background.computeLuminance();
    final contrast =
        (math.max(first, second) + 0.05) / (math.min(first, second) + 0.05);
    expect(contrast, greaterThanOrEqualTo(4.5));
  }
}

class _FakeUmengSdk implements UmengSdkClient {
  _FakeUmengSdk({this.supported = true});

  final bool supported;
  int initializeCount = 0;
  int initializationFailures = 0;
  Completer<void>? initializationGate;
  bool failPageCalls = false;
  bool failUnhandledCapture = false;
  void Function(Object, StackTrace?)? onError;
  final events = <String>[];
  final pageCalls = <String>[];
  final caughtExceptions = <Exception>[];
  String? signedInUser;

  @override
  bool get isSupported => supported;

  @override
  String get platformLabel => supported ? 'Android 测试替身' : 'Web 测试替身';

  @override
  Future<void> initialize(void Function(Object, StackTrace?) onError) async {
    initializeCount++;
    this.onError = onError;
    if (initializationFailures > 0) {
      initializationFailures--;
      throw StateError('SDK initialization failed');
    }
    await initializationGate?.future;
  }

  @override
  void trackEvent(String eventId, Map<String, Object> properties) {
    events.add(eventId);
  }

  @override
  void signIn(String userId) {
    signedInUser = userId;
  }

  @override
  void signOut() {
    signedInUser = null;
  }

  @override
  void pageStart(String name) {
    if (failPageCalls) {
      throw StateError('SDK page start failed');
    }
    pageCalls.add('start:$name');
  }

  @override
  void pageEnd(String name) {
    if (failPageCalls) {
      throw StateError('SDK page end failed');
    }
    pageCalls.add('end:$name');
  }

  @override
  void captureException(Exception exception, StackTrace stack) {
    caughtExceptions.add(exception);
  }

  @override
  void captureUnhandled(Object error, StackTrace stack) {
    if (failUnhandledCapture) {
      throw StateError('SDK unhandled capture failed');
    }
  }
}
