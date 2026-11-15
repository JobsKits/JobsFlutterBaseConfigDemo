import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('plugins.flutter.io/shared_preferences');
  late Completer<Map<String, Object>> preferences;
  late Completer<void> readStarted;
  const persisted = <String, Object>{
    'flutter.jobs_demo_theme': 2,
    'flutter.jobs_demo_locale': 'fr',
  };

  setUp(() {
    SharedPreferences.resetStatic();
    preferences = Completer<Map<String, Object>>();
    readStarted = Completer<void>();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          if (call.method == 'getAll') {
            readStarted.complete();
            return preferences.future;
          }
          return true;
        });
  });
  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    SharedPreferences.resetStatic();
  });

  test('设置释放后，延迟的SharedPreferences结果不再通知或修改设置', () async {
    final settings = JobsDemoSettings();
    var notifications = 0;
    settings.addListener(() => notifications++);
    final loading = settings.init();
    await readStarted.future;
    settings.dispose();
    preferences.complete(persisted);
    await expectLater(loading, completes);
    expect(notifications, 0);
    expect(settings.themeMode, ThemeMode.system);
    expect(settings.locale, const Locale('zh'));
  });

  testWidgets('独立App卸载自有设置后，原生偏好读取晚完成仍安全', (tester) async {
    late JobsDemoSettings owned;
    await tester.pumpWidget(
      JobsDemoApp(
        showSettings: false,
        home: Builder(
          builder: (context) {
            owned = JobsDemoScope.of(context);
            return const SizedBox();
          },
        ),
      ),
    );
    expect(readStarted.isCompleted, isTrue);
    await tester.pumpWidget(const SizedBox());
    preferences.complete(persisted);
    await tester.pump();
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(owned.themeMode, ThemeMode.system);
  });

  test('仍存活时正常应用持久化主题和语言并通知一次', () async {
    final settings = JobsDemoSettings();
    var notifications = 0;
    settings.addListener(() => notifications++);
    final loading = settings.init();
    await readStarted.future;
    preferences.complete(persisted);
    await loading;
    expect(settings.themeMode, ThemeMode.dark);
    expect(settings.locale, const Locale('fr'));
    expect(notifications, 1);
    settings.dispose();
  });
}
