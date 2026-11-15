import 'dart:convert';

import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';
import 'package:jobs_demo_foundation/jobs_input_tools.dart';
import 'package:jobs_demo_foundation/jobs_edge_refresh.dart';
import 'package:jobs_flutter_base_config/demo_hub/legacy_strings.dart';
import 'package:jobs_flutter_base_config/demos/输入框与多行文本组合/入口.dart';
import 'package:jobs_flutter_base_config/demos/横纵刷新与加载组合/入口.dart';

void main() {
  test('输入格式化保留输入法组合区，金额及手机号实际约束', () {
    final money = JobsMoneyInputFormatter(), phone = JobsPhoneInputFormatter();
    TextEditingValue input(String value) => TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
    expect(money.formatEditUpdate(input(''), input('12.3.456')).text, '12.34');
    expect(
      phone.formatEditUpdate(input(''), input('138001380009')).text,
      '138 0013 8000',
    );
    const composing = TextEditingValue(
      text: 'ni',
      composing: TextRange(start: 0, end: 2),
    );
    expect(phone.formatEditUpdate(input(''), composing), composing);
    expect(jobsValidMoney('1000000'), isFalse);
    expect(jobsValidPhone('138 0013 8000'), isTrue);
    expect(jobsInputMode('abc', 'ab'), 'delete');
  });
  testWidgets('单多行输入、焦点、格式化、双向绑定与删除实际联动', (tester) async {
    registerLegacyTranslations();
    await tester.pumpWidget(
      const JobsDemoApp(showSettings: false, home: InputCombinationDemo()),
    );
    await tester.pumpAndSettle();
    final email = find.byKey(const ValueKey('input-email'));
    await tester.enterText(email, ' a@b cdefgh ');
    await tester.pump();
    expect(tester.widget<TextField>(email).controller!.text, 'a@bcdefg');
    await tester.testTextInput.receiveAction(TextInputAction.next);
    await tester.pump();
    final password = find.byKey(const ValueKey('input-password'));
    expect(tester.widget<TextField>(password).focusNode!.hasFocus, isTrue);
    await tester.enterText(password, '123456789');
    expect(tester.widget<TextField>(password).controller!.text, '12345');
    final a = find.byKey(const ValueKey('input-binding-a')),
        b = find.byKey(const ValueKey('input-binding-b'));
    await tester.scrollUntilVisible(
      a,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.enterText(a, '同步值');
    await tester.pump();
    expect(tester.widget<TextField>(b).controller!.text, '同步值');
    await tester.scrollUntilVisible(
      b,
      150,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.enterText(b, '反向值');
    await tester.pump();
    expect(tester.widget<TextField>(a).controller!.text, '反向值');
    final deletion = find.byKey(const ValueKey('input-delete'));
    await tester.scrollUntilVisible(
      deletion,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.enterText(deletion, '');
    await tester.pump();
    expect(find.text('检测到删除键'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  test('刷新边缘状态按阈值与异步闭包完成，销毁后不通知', () async {
    var count = 0;
    final controller = JobsEdgeRefreshController(
      onTrigger: (edge) async {
        count++;
      },
    );
    controller.pull(-40);
    expect(controller.phase, JobsEdgeRefreshPhase.pulling);
    controller.pull(-30);
    expect(controller.phase, JobsEdgeRefreshPhase.ready);
    await controller.release();
    expect(count, 1);
    expect(controller.phase, JobsEdgeRefreshPhase.idle);
    controller.dispose();
    await controller.run(JobsRefreshEdge.trailing);
    expect(count, 1);
  });
  testWidgets('横纵刷新及加载真实请求，七种动效可选', (tester) async {
    registerLegacyTranslations();
    var requests = 0;
    final client = MockClient((request) async {
      requests++;
      expect(request.method, 'POST');
      await Future<void>.delayed(const Duration(milliseconds: 150));
      return http.Response(
        jsonEncode({
          'items': ['server $requests'],
        }),
        200,
      );
    });
    await tester.pumpWidget(
      JobsDemoApp(
        showSettings: false,
        home: EdgeRefreshCombinationDemo(transport: client),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    await tester.tap(find.byKey(const ValueKey('横向refresh')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    await tester.tap(find.byKey(const ValueKey('横向load')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    await tester.tap(find.byKey(const ValueKey('纵向load')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    expect(requests, 4);
    expect(find.textContaining('横向刷新 1 / 加载 1'), findsOneWidget);
    for (final name in ['头条', '抖音', '单图', '多图', 'GIF', 'Lottie', '系统指示器']) {
      final chip = find.ancestor(
        of: find.text(name),
        matching: find.byType(ChoiceChip),
      );
      await tester.tap(chip);
      await tester.pump();
      expect(tester.widget<ChoiceChip>(chip).selected, isTrue);
      await tester.tap(find.byKey(const ValueKey('纵向refresh')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 30));
      if (name == 'Lottie') expect(find.byType(Lottie), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 200));
      expect(tester.takeException(), isNull);
    }
    await tester.pumpWidget(const SizedBox());
    client.close();
  });
  testWidgets('组合页面在十语和手机尺寸下保持可操作', (tester) async {
    registerLegacyTranslations();
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final client = MockClient((_) async => http.Response('{}', 400));
    final settings = JobsDemoSettings();
    await tester.pumpWidget(
      JobsDemoApp(
        settings: settings,
        showSettings: false,
        home: EdgeRefreshCombinationDemo(transport: client),
      ),
    );
    for (final locale in jobsDemoLocales) {
      settings.setLocale(locale);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(
        find.text(legacyUiTextForLocale(locale, '横纵刷新与加载组合')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    }
    await tester.pumpWidget(const SizedBox());
    client.close();
    settings.dispose();
  });
  testWidgets('横纵列表实际边缘拖动触发对应请求', (tester) async {
    registerLegacyTranslations();
    final requests = <Map<String, dynamic>>[];
    final client = MockClient((request) async {
      requests.add(jsonDecode(request.body) as Map<String, dynamic>);
      return http.Response('{"items":["one"]}', 200);
    });
    await tester.pumpWidget(
      JobsDemoApp(
        showSettings: false,
        home: EdgeRefreshCombinationDemo(transport: client),
      ),
    );
    await tester.pumpAndSettle();
    await tester.drag(
      find.byKey(const ValueKey('refresh-horizontal')),
      const Offset(200, 0),
    );
    await tester.pumpAndSettle();
    expect(
      requests.any((e) => e['axis'] == 'horizontal' && e['edge'] == 'leading'),
      isTrue,
    );
    await tester.drag(
      find.byKey(const ValueKey('refresh-vertical')),
      const Offset(0, -200),
    );
    await tester.pumpAndSettle();
    expect(
      requests.any((e) => e['axis'] == 'vertical' && e['edge'] == 'trailing'),
      isTrue,
    );
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    client.close();
  });
}
