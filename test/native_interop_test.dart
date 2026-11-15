import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';
import 'package:jobs_flutter_base_config/demos/原生与Flutter往返/原生与Flutter往返.dart';
import 'package:jobs_flutter_base_config/demos/原生与Flutter往返/独立引擎页面.dart';
import 'package:jobs_platform_lab/jobs_platform_lab.dart';
import 'package:shared_preferences/shared_preferences.dart';

// flutter test test/native_interop_test.dart；验证通道载荷与独立引擎入口，不替代原生双引擎实机操作。
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));
  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      JobsPlatformLab.methods,
      null,
    );
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      nativeRoundTripChannel,
      null,
    );
  });

  testWidgets(
    'parent passes localized host parameters and receives round-trip result',
    (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      MethodCall? request;
      binding.defaultBinaryMessenger.setMockMethodCallHandler(
        JobsPlatformLab.methods,
        (call) async {
          request = call;
          return {
            'host': 'UIViewController',
            'payload': {'value': 'from secondary'},
          };
        },
      );
      await tester.pumpWidget(
        JobsDemoApp(
          settings: JobsDemoSettings(
            locale: const Locale('en'),
            themeMode: ThemeMode.dark,
          ),
          showSettings: false,
          home: const NativeFlutterRoundTripDemo(),
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'prefill test');
      await tester.tap(find.text('Open native host'));
      await tester.pumpAndSettle();
      expect(request!.method, 'bridge.presentHost');
      final args = request!.arguments as Map;
      expect(args['prefill'], 'prefill test');
      expect(args['locale'], 'en');
      expect(args['theme'], 'dark');
      expect((args['labels'] as Map)['原生宿主页面'], 'Native host screen');
      expect(find.textContaining('from secondary'), findsOneWidget);
      debugDefaultTargetPlatformOverride = null;
    },
  );

  testWidgets('secondary entry loads parameters and returns edited payload', (
    tester,
  ) async {
    MethodCall? returned;
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      nativeRoundTripChannel,
      (call) async {
        if (call.method == 'load')
          return {
            'requestId': 'request-test',
            'prefill': 'initial',
            'locale': 'en',
            'theme': 'dark',
          };
        returned = call;
        return null;
      },
    );
    await launchNativeBridgeEntry();
    await tester.pumpAndSettle();
    expect(find.text('Separate Flutter engine'), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      'initial',
    );
    await tester.enterText(find.byType(TextField), 'edited');
    await tester.tap(
      find.text('Read/write through the secondary engine plugin'),
    );
    await tester.pumpAndSettle();
    expect(find.text('SharedPreferences: edited'), findsOneWidget);
    await tester.tap(find.text('Return and close Flutter'));
    await tester.pumpAndSettle();
    expect(returned!.method, 'finish');
    expect(returned!.arguments, {
      'requestId': 'request-test',
      'value': 'edited',
      'cancelled': false,
      'engine': 'secondary',
    });
  });

  testWidgets(
    'unsupported target explains native requirement and disables launch',
    (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      await tester.pumpWidget(
        const JobsDemoApp(
          home: NativeFlutterRoundTripDemo(),
          showSettings: false,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('此往返示例需要iOS原生宿主'), findsOneWidget);
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );
      debugDefaultTargetPlatformOverride = null;
    },
  );
}
