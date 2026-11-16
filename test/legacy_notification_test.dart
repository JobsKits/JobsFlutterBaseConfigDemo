import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';
import 'package:jobs_flutter_base_config/demos/本地系统通知/LocalNotificationsDemo.dart'
    as example;
import 'package:jobs_flutter_base_config/demo_hub/legacy_strings.dart';

void main() {
  testWidgets('通知初始化及Android权限成功前按钮禁用，发送使用实际资源', (tester) async {
    registerLegacyTranslations();
    final previousPlatform = AndroidFlutterLocalNotificationsPlugin();
    FlutterLocalNotificationsPlatform.instance =
        AndroidFlutterLocalNotificationsPlugin();
    addTearDown(
      () => FlutterLocalNotificationsPlatform.instance = previousPlatform,
    );
    final pending = Completer<bool>();
    final calls = <MethodCall>[];
    const channel = MethodChannel('dexterous.com/flutter/local_notifications');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          if (call.method == 'initialize') return pending.future;
          if (call.method == 'requestNotificationsPermission') return true;
          return null;
        });
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null),
    );
    await tester.pumpWidget(
      const JobsDemoApp(showSettings: false, home: example.MyApp()),
    );
    await tester.pump();
    final button = find.byKey(const ValueKey('show-legacy-notification'));
    expect(tester.widget<ElevatedButton>(button).onPressed, isNull);
    pending.complete(true);
    await tester.pumpAndSettle();
    expect(
      calls.any((c) => c.method == 'requestNotificationsPermission'),
      isTrue,
    );
    await tester.tap(button);
    await tester.pumpAndSettle();
    final initialize =
        calls.firstWhere((c) => c.method == 'initialize').arguments as Map;
    expect(initialize['defaultIcon'], 'ic_jobs_notification');
    final show = calls.firstWhere((c) => c.method == 'show').arguments as Map;
    expect((show['platformSpecifics'] as Map)['icon'], 'ic_jobs_notification');
    expect(tester.takeException(), isNull);
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));
  testWidgets('通知授权拒绝显示可重试状态，再授权后恢复按钮', (tester) async {
    FlutterLocalNotificationsPlatform.instance =
        AndroidFlutterLocalNotificationsPlugin();
    var granted = false;
    const channel = MethodChannel('dexterous.com/flutter/local_notifications');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          if (call.method == 'initialize') return true;
          if (call.method == 'requestNotificationsPermission') return granted;
          return null;
        });
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null),
    );
    await tester.pumpWidget(
      const JobsDemoApp(showSettings: false, home: example.MyApp()),
    );
    await tester.pumpAndSettle();
    final button = find.byKey(const ValueKey('show-legacy-notification'));
    expect(tester.widget<ElevatedButton>(button).onPressed, isNull);
    expect(
      find.textContaining('Notification permission denied'),
      findsOneWidget,
    );
    granted = true;
    await tester.tap(find.text('重试'));
    await tester.pumpAndSettle();
    expect(tester.widget<ElevatedButton>(button).onPressed, isNotNull);
    expect(tester.takeException(), isNull);
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));
}
