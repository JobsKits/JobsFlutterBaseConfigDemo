import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

// Match the Material API exported by the existing demo foundation.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';
import 'package:jobs_flutter_base_config/demo_hub/workflow_strings.dart';
import 'package:jobs_flutter_base_config/demos/代码变更审阅/代码变更审阅.dart';
import 'package:jobs_flutter_base_config/demos/代码变更审阅/审阅模型.dart';
import 'package:jobs_flutter_base_config/demos/实时报价确认/实时报价确认.dart';
import 'package:jobs_flutter_base_config/demos/实时报价确认/报价模型.dart';
import 'package:jobs_flutter_base_config/demos/通知处理收件箱/通知处理收件箱.dart';
import 'package:jobs_flutter_base_config/demos/通知处理收件箱/通知模型.dart';
import 'package:jobs_flutter_base_config/demos/多来源额度归集/多来源额度归集.dart';
import 'package:jobs_flutter_base_config/demos/多来源额度归集/归集模型.dart';
import 'package:jobs_flutter_base_config/demos/工作流共用/演示数据.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/flutter_fonts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final robotoFont = flutterMaterialFont('Roboto-Regular.ttf');
    final fonts = {
      'Roboto': robotoFont,
      'monospace': robotoFont,
      'Ahem': robotoFont,
      'MaterialIcons': flutterMaterialFont('MaterialIcons-Regular.otf'),
      'packages/jobs_demo_foundation/NotoTibetan': File(
        'JobsByPubs/JobsDemoFoundationByPub/assets/fonts/NotoSerifTibetan-Regular.ttf',
      ),
    };
    for (final entry in fonts.entries) {
      final loader = FontLoader(entry.key)
        ..addFont(entry.value.readAsBytes().then(ByteData.sublistView));
      await loader.load();
    }
  });
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('unified patch keeps old/new lines, zero and omitted counts, CRLF and no-newline', () {
    final hunks = parseUnifiedPatch(
      '--- a/file\r\n+++ b/file\r\n@@ -10,2 +20,3 @@ title\r\n same\r\n-old\r\n+new\r\n+extra\r\n\\ No newline at end of file\r\n@@ -30 +40 @@\r\n-one\r\n+two\r\n',
    );
    expect(hunks.length, 2);
    expect(hunks.first.lines.map((l) => l.oldLine), [10, 11, null, null]);
    expect(hunks.first.lines.map((l) => l.newLine), [20, null, 21, 22]);
    expect(hunks[1].lines.first.oldLine, 30);
    expect(
      parseUnifiedPatch('@@ -0,0 +1 @@\n+new\n').single.lines.single.newLine,
      1,
    );
    expect(
      parseUnifiedPatch('@@ -1 +0,0 @@\n-old\n').single.lines.single.newLine,
      isNull,
    );
    expect(parseUnifiedPatch(''), isEmpty);
  });
  test(
    'unified patch rejects malformed, truncated, excess and unbounded input',
    () {
      for (final value in [
        '@@ bad\n+x',
        '@@ -1,2 +1 @@\n same\n',
        '@@ -0,0 +1 @@\n+a\n+b\n',
        '@@ -1 +1 @@\nnot diff',
      ]) {
        expect(() => parseUnifiedPatch(value), throwsFormatException);
      }
      expect(
        () => parseUnifiedPatch(List.filled(10001, '').join('\n')),
        throwsFormatException,
      );
    },
  );
  test('review joins side-aware inline and outdated threads, persists resolve/reopen', () {
    var board = ReviewBoard.sample;
    final lines = parseUnifiedPatch(board.files.first.patch).first.lines;
    expect(
      board
          .inlineFor(
            'price',
            lines.firstWhere((l) => l.kind == DiffKind.removal),
          )
          .single
          .id,
      't2',
    );
    expect(board.outdatedFor('price').map((t) => t.id), ['t3']);
    board = ReviewBoard.fromJson(board.toggle('t1').toJson());
    expect(board.threads.first.resolved, true);
    expect(board.toggle('t1').threads.first.resolved, false);
    final bad = board.toJson();
    (bad['threads'] as List).first['file'] = 'absent';
    expect(ReviewBoard.accepts(bad), false);
  });
  test(
    'quote policies separate accepted and latest, lower cost is favorable',
    () {
      final manual = QuoteBook.sample.tick();
      expect(manual.items[0].pending, true);
      expect(manual.canSubmit, false);
      final favorable = QuoteBook.sample
          .withPolicy(QuotePolicy.favorable)
          .tick();
      expect(favorable.items[0].pending, true);
      expect(favorable.items[1].pending, false);
      final any = QuoteBook.sample.withPolicy(QuotePolicy.any).tick();
      expect(any.selected.every((i) => !i.pending), true);
      expect(
        QuoteBook.fromJson(manual.accept().toJson()).items.first.pending,
        false,
      );
      expect(manual.fingerprint, isNot(manual.accept().fingerprint));
    },
  );
  test(
    'quote minimum, paused selection and empty selection each block submission',
    () {
      var book = QuoteBook.sample.edit('desk', (i) => i.copy(minimum: 3));
      expect(book.canSubmit, false);
      book = book.edit('desk', (i) => i.copy(quantity: 3));
      expect(book.canSubmit, true);
      expect(book.edit('desk', (i) => i.copy(active: false)).canSubmit, false);
      for (final item in book.items) {
        book = book.edit(item.id, (i) => i.copy(selected: false));
      }
      expect(book.canSubmit, false);
      expect(
        QuoteBook.accepts({'items': [], 'version': -1, 'policy': 0}),
        false,
      );
    },
  );
  test('inbox combines repository AND reason; read/archive/subscription remain independent', () {
    var board = InboxBoard.sample;
    expect(
      board.filter(repository: 'jobs/atlas', reason: '提及').map((i) => i.id),
      ['n1'],
    );
    final before = {'n1': board.items.first};
    board = board.change({'n1'}, InboxAction.subscription);
    expect(board.items.first.read, false);
    expect(board.items.first.archived, false);
    expect(board.items.first.subscribed, false);
    board = board.change({'n1'}, InboxAction.read).change({
      'n2',
    }, InboxAction.archive);
    expect(board.filter().any((i) => i.id == 'n1'), false);
    board = InboxBoard.fromJson(board.restore(before).toJson());
    expect(board.items.first.read, false);
    expect(board.items[1].archived, true);
  });
  test('collection two workers, partial failure, failure-only retry and idempotence', () async {
    final engine = CollectionEngine.sample();
    var active = 0, peak = 0;
    final calls = <String>[];
    Future<bool> action(CollectionSource source, String token) async {
      active++;
      peak = active > peak ? active : peak;
      calls.add(source.id);
      await Future<void>.delayed(Duration.zero);
      active--;
      return source.id != 'docs' || source.attempts > 1;
    }

    await engine.run(action, () {});
    expect(peak, 2);
    expect(engine.receipts.length, 3);
    expect(engine.collected, 26300);
    calls.clear();
    await engine.run(action, () {}, failuresOnly: true);
    expect(calls, ['docs']);
    expect(engine.collected, 34100);
    expect(engine.commit(engine.sources.first), false);
    await engine.run(action, () {});
    expect(calls, ['docs']);
    expect(CollectionEngine.fromJson(engine.toJson()).collected, 34100);
  });
  test('collection cancellation retains commits and rejects late results/duplicate run', () async {
    final engine = CollectionEngine.sample();
    final pending = <Completer<bool>>[];
    Future<bool> action(CollectionSource source, String token) {
      final c = Completer<bool>();
      pending.add(c);
      return c.future;
    }

    final run = engine.run(action, () {});
    await engine.run(action, () {});
    expect(pending.length, 2);
    pending[0].complete(true);
    await Future<void>.delayed(Duration.zero);
    expect(engine.receipts.length, 1);
    final committed = engine.collected;
    engine.cancel();
    for (final c in pending) {
      if (!c.isCompleted) c.complete(true);
    }
    await run;
    expect(engine.collected, committed);
    expect(
      engine.sources.any((s) => s.status == CollectionStatus.running),
      false,
    );
    final data = engine.toJson();
    (data['receipts'] as List).first['units'] = -1;
    expect(CollectionEngine.accepts(data), false);
  });
  test('store attempts API, rejects invalid response, caches offline, recovers authoritative response', () async {
    final requests = <http.Request>[];
    var mode = 0;
    final store = WorkflowStore(
      client: MockClient((r) async {
        requests.add(r);
        if (mode == 0) return http.Response('offline', 503);
        if (mode == 1) {
          return http.Response('{"value":{"revision":"broken"}}', 200);
        }
        return http.Response(
          jsonEncode({
            'value': InboxBoard.sample.change({
              'n1',
            }, InboxAction.archive).toJson(),
          }),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      }),
    );
    final local = InboxBoard.sample.change({'n2'}, InboxAction.read).toJson();
    expect(
      (await store.save('inbox-test', local, InboxBoard.accepts)).online,
      false,
    );
    mode = 1;
    expect(
      InboxBoard.fromJson(
        (await store.load(
          'inbox-test',
          InboxBoard.sample.toJson(),
          InboxBoard.accepts,
        )).value,
      ).items[1].read,
      true,
    );
    mode = 2;
    final result = await store.load('inbox-test', local, InboxBoard.accepts);
    expect(result.online, true);
    expect(InboxBoard.fromJson(result.value).items.first.archived, true);
    expect(requests.map((r) => r.method), ['PUT', 'GET', 'GET']);
    expect(requests.first.url.path, '/api/ui-demos/inbox-test');
    expect(jsonDecode(requests.first.body)['value'], local);
    store.close();
  });
  test(
    'store discards late response cache writes and checkpoints are serial',
    () async {
      final first = Completer<http.Response>();
      final entered = Completer<void>();
      var calls = 0;
      final store = WorkflowStore(
        client: MockClient((r) async {
          calls++;
          if (calls == 1) {
            entered.complete();
            return first.future;
          }
          return http.Response(
            jsonEncode({
              'value': {'n': 2},
            }),
            200,
          );
        }),
      );
      bool accepts(Map<String, dynamic> d) => d['n'] is int;
      final old = store.load('race', {'n': 0}, accepts);
      await entered.future;
      await store.save('race', {'n': 2}, accepts);
      first.complete(http.Response('{"value":{"n":1}}', 200));
      await old;
      final prefs = await SharedPreferences.getInstance();
      expect(jsonDecode(prefs.getString('workflow.race')!)['n'], 2);
      await Future.wait([
        store.checkpoint('race', {'n': 3}),
        store.checkpoint('race', {'n': 4}),
      ]);
      expect(jsonDecode(prefs.getString('workflow.race')!)['n'], 4);
      store.close();
    },
  );
  test('all workflow strings provide ten nonempty translations', () {
    expect(workflowTranslations.length, greaterThan(80));
    for (final row in workflowTranslations.entries) {
      expect(row.value.length, 10, reason: row.key);
      expect(
        row.value.every((text) => text.trim().isNotEmpty),
        true,
        reason: row.key,
      );
    }
  });

  test('timeout returns demo state and a later server response cannot overwrite it', () async {
    final response = Completer<http.Response>();
    final store = WorkflowStore(
      timeout: const Duration(milliseconds: 50),
      client: MockClient((_) => response.future),
    );
    final result = await store.save('timeout', {
      'value': 7,
    }, (d) => d['value'] is int);
    expect(result.online, false);
    expect(result.value['value'], 7);
    response.complete(http.Response('{"value":{"value":9}}', 200));
    await Future<void>.delayed(Duration.zero);
    final prefs = await SharedPreferences.getInstance();
    expect(jsonDecode(prefs.getString('workflow.timeout')!)['value'], 7);
    store.close();
  });

  WorkflowStore offline() =>
      WorkflowStore(client: MockClient((_) async => http.Response('', 503)));
  Future<void> mount(
    WidgetTester tester,
    Widget child, {
    Size size = const Size(1200, 1000),
    Locale locale = const Locale('zh'),
    ThemeMode theme = ThemeMode.light,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;
    await tester.pumpWidget(
      RepaintBoundary(
        key: const ValueKey('workflow-capture'),
        child: JobsDemoApp(
          settings: JobsDemoSettings(locale: locale, themeMode: theme),
          showSettings: false,
          home: child,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'review switches files, resolves/reopens, and tolerates late refresh after close',
    (tester) async {
      final store = offline();
      await mount(tester, CodeChangeReviewDemo(store: store));
      await tester.tap(find.byKey(const ValueKey('resolve-t1')));
      await tester.pumpAndSettle();
      expect(find.text('重新打开'), findsWidgets);
      await tester.tap(find.byKey(const ValueKey('file-cache')));
      await tester.pumpAndSettle();
      expect(find.text('缓存清除后应可重新加载'), findsOneWidget);
      expect(find.text('过时讨论'), findsNothing);
      await tester.tap(find.byKey(const ValueKey('file-binary')));
      await tester.pumpAndSettle();
      expect(find.text('此文件没有文本补丁'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      store.close();
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'quote tick blocks submit until accepted, then records only after final confirmation',
    (tester) async {
      final store = offline();
      await mount(
        tester,
        LiveQuoteConfirmationDemo(store: store, autoUpdate: false),
      );
      await tester.tap(find.byKey(const ValueKey('quote-tick')));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<FilledButton>(find.byKey(const ValueKey('quote-submit')))
            .onPressed,
        isNull,
      );
      await tester.ensureVisible(find.text('接受当前报价'));
      await tester.tap(find.text('接受当前报价'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('quote-submit')));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      await tester.tap(find.text('确认').last);
      await tester.pumpAndSettle();
      expect(find.text('样例订单已记录'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      store.close();
    },
  );
  testWidgets(
    'authoritative order correction replaces the quote instead of confirming an old snapshot',
    (tester) async {
      final store = WorkflowStore(
        client: MockClient(
          (request) async => http.Response(
            jsonEncode({
              'value': request.url.path.endsWith('workflow-quote-order')
                  ? QuoteBook.sample.tick().toJson()
                  : QuoteBook.sample.toJson(),
            }),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          ),
        ),
      );
      await mount(
        tester,
        LiveQuoteConfirmationDemo(store: store, autoUpdate: false),
      );
      await tester.ensureVisible(find.byKey(const ValueKey('quote-submit')));
      await tester.tap(find.byKey(const ValueKey('quote-submit')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('确认'));
      await tester.pumpAndSettle();
      expect(find.text('样例订单已记录'), findsNothing);
      expect(find.text('确认期间报价已变化，请重试'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      store.close();
    },
  );
  testWidgets('all four pages ignore pending load responses after disposal', (
    tester,
  ) async {
    for (var page = 0; page < 4; page++) {
      final response = Completer<http.Response>();
      var entered = false;
      final store = WorkflowStore(
        client: MockClient((_) {
          entered = true;
          return response.future;
        }),
      );
      final child = <Widget>[
        CodeChangeReviewDemo(store: store),
        LiveQuoteConfirmationDemo(store: store),
        NotificationInboxDemo(store: store),
        MultiSourceCollectionDemo(store: store),
      ][page];
      await tester.pumpWidget(
        JobsDemoApp(
          settings: JobsDemoSettings(),
          showSettings: false,
          home: child,
        ),
      );
      await tester.pump();
      expect(entered, true);
      await tester.pumpWidget(const SizedBox());
      response.complete(http.Response('', 503));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      store.close();
    }
  });
  testWidgets(
    'inbox batch read/undo, archive state and explicit failed action',
    (tester) async {
      final store = offline();
      await mount(tester, NotificationInboxDemo(store: store));
      await tester.tap(find.textContaining('选中可见项'));
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, '标为已读'));
      await tester.pumpAndSettle();
      expect(find.text('暂无结果'), findsOneWidget);
      await tester.tap(find.text('撤销上次操作'));
      await tester.pumpAndSettle();
      expect(find.text('请审阅缓存更新'), findsOneWidget);
      await tester.tap(find.text('模拟本次失败'));
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('选中可见项'));
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, '标为已读'));
      await tester.pumpAndSettle();
      expect(find.text('操作未完成，原条目已保留'), findsOneWidget);
      expect(find.text('请审阅缓存更新'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      store.close();
    },
  );
  testWidgets(
    'collection preview cancel has no receipt; confirmed run retries failures only',
    (tester) async {
      final store = offline();
      await mount(tester, MultiSourceCollectionDemo(store: store));
      await tester.tap(find.byKey(const ValueKey('collection-start')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('取消').last);
      await tester.pumpAndSettle();
      expect(find.text('选择来源后预览'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('collection-start')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('确认'));
      await tester.pumpAndSettle();
      expect(find.text('263.00'), findsOneWidget);
      await tester.ensureVisible(find.text('仅重试失败项'));
      await tester.tap(find.text('仅重试失败项'));
      await tester.pumpAndSettle();
      expect(find.textContaining('文档工作区  78.00'), findsOneWidget);
      await tester.tap(find.text('确认'));
      await tester.pumpAndSettle();
      expect(find.text('341.00'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      store.close();
    },
  );
  testWidgets(
    'four layouts support ten locales, light/dark/system, narrow/wide, keyboard focus',
    (tester) async {
      const locales = [
        Locale('zh'),
        Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
        Locale('bo'),
        Locale('en'),
        Locale('ja'),
        Locale('fr'),
        Locale('es'),
        Locale('de'),
        Locale('ru'),
        Locale('ko'),
      ];
      for (var i = 0; i < locales.length; i++) {
        for (var page = 0; page < 4; page++) {
          final store = offline();
          final child = <Widget>[
            CodeChangeReviewDemo(store: store),
            LiveQuoteConfirmationDemo(store: store, autoUpdate: false),
            NotificationInboxDemo(store: store),
            MultiSourceCollectionDemo(store: store),
          ][page];
          await mount(
            tester,
            child,
            size: i.isEven ? const Size(390, 844) : const Size(1440, 1000),
            locale: locales[i],
            theme: ThemeMode.values[i % 3],
          );
          await tester.sendKeyEvent(LogicalKeyboardKey.tab);
          await tester.pump();
          expect(
            tester.takeException(),
            isNull,
            reason: '${locales[i]} page $page',
          );
          if (i == 3) {
            await tester.runAsync(() async {
              final boundary = tester.firstRenderObject<RenderRepaintBoundary>(
                find.byKey(const ValueKey('workflow-capture')),
              );
              final image = await boundary.toImage(pixelRatio: 1);
              final data = await image.toByteData(
                format: ui.ImageByteFormat.png,
              );
              await File('/tmp/workflow-$page.png')
                  .writeAsBytes(data!.buffer.asUint8List());
              image.dispose();
            });
          }
          await tester.pumpWidget(const SizedBox());
          store.close();
        }
      }
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    },
  );
}
