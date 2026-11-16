import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';
import 'package:jobs_flutter_base_config/demo_hub/interaction_strings.dart';
import 'package:jobs_flutter_base_config/demo_hub/interaction_support.dart';
import 'package:jobs_flutter_base_config/demos/可拖面板吸顶列表/可拖面板吸顶列表.dart';
import 'package:jobs_flutter_base_config/demos/同轴滚动接力/同轴滚动接力.dart';
import 'package:jobs_flutter_base_config/demos/礼物双槽连击/礼物双槽连击.dart';
import 'package:jobs_flutter_base_config/demos/聊天阅读锚点/聊天阅读锚点.dart';
import 'package:jobs_flutter_base_config/demos/麦位互动与声浪/麦位互动与声浪.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/demo_toolbar.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  InteractionRepository offline() {
    final repo = InteractionRepository(
      client: MockClient((_) async => http.Response('{}', 503)),
    );
    addTearDown(repo.dispose);
    return repo;
  }

  Future<void> mount(
    WidgetTester tester,
    Widget page, {
    ThemeMode theme = ThemeMode.light,
    Locale locale = const Locale('zh'),
    bool compact = false,
  }) async {
    final settings = JobsDemoSettings(locale: locale, themeMode: theme);
    addTearDown(settings.dispose);
    if (compact) {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    }
    await tester.pumpWidget(
      JobsDemoApp(
        settings: settings,
        showSettings: false,
        home: Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(compact ? 1.5 : 1)),
            child: page,
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    if (page is ChatReadingAnchorDemo) {
      await tester.pumpAndSettle();
    }
  }

  Future<void> unmount(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 4));
    expect(tester.takeException(), isNull);
  }

  test('All interaction labels have ten nonempty translations', () {
    expect(interactionTranslations.length, greaterThan(50));
    for (final row in interactionTranslations.entries) {
      expect(row.value.length, 10, reason: row.key);
      expect(
        row.value.every((v) => v.trim().isNotEmpty),
        isTrue,
        reason: row.key,
      );
    }
  });

  final builders = <String, Widget Function(InteractionRepository)>{
    'anchor': (repo) => ChatReadingAnchorDemo(repository: repo),
    'relay': (repo) => ScrollHandoffDemo(repository: repo),
    'sheet': (repo) => DraggablePinnedSheetDemo(repository: repo),
    'seats': (repo) => VoiceSeatDemo(repository: repo),
    'gifts': (repo) => GiftComboDemo(repository: repo),
  };
  for (final builder in builders.entries) {
    for (final theme in [ThemeMode.light, ThemeMode.dark]) {
      testWidgets(
        '${builder.key} compact 1.5x German ${theme.name} mounts and disposes',
        (tester) async {
          await mount(
            tester,
            builder.value(offline()),
            theme: theme,
            locale: const Locale('de'),
            compact: true,
          );
          expect(tester.takeException(), isNull);
          await unmount(tester);
        },
      );
    }
  }

  testWidgets(
    'Prepending variable height history preserves actual visible message geometry',
    (tester) async {
      await mount(tester, ChatReadingAnchorDemo(repository: offline()));
      final scroll = tester
          .widget<CustomScrollView>(find.byKey(const ValueKey('anchor-scroll')))
          .controller!;
      scroll.jumpTo(230);
      await tester.pump();
      final viewport = tester.getRect(
        find.byKey(const ValueKey('anchor-scroll')),
      );
      final anchor = find.byWidgetPredicate(
        (w) =>
            w.key is ValueKey<String> &&
            (w.key as ValueKey<String>).value.startsWith('anchor-message-'),
      );
      final visible = anchor
          .evaluate()
          .where((e) {
            final box = e.renderObject as RenderBox;
            return box.localToGlobal(Offset.zero).dy > viewport.top &&
                box.localToGlobal(Offset.zero).dy < viewport.bottom - 30;
          })
          .first
          .widget
          .key!;
      final before = tester.getTopLeft(find.byKey(visible)).dy;
      final pixels = scroll.offset;
      await tapDemoMenuAction(
        tester,
        find.byKey(const ValueKey('prepend-history')),
      );
      await tester.pump();
      expect(tester.getTopLeft(find.byKey(visible)).dy, closeTo(before, .1));
      expect(scroll.offset, closeTo(pixels, .1));
      // Read into the negative (older) sliver, then prepend more older rows.
      scroll.jumpTo(-180);
      await tester.pump();
      final old = find.byKey(const ValueKey('anchor-message--2'));
      final oldY = tester.getTopLeft(old).dy;
      await tapDemoMenuAction(
        tester,
        find.byKey(const ValueKey('prepend-history')),
      );
      await tester.pump();
      expect(tester.getTopLeft(old).dy, closeTo(oldY, .1));
      await unmount(tester);
    },
  );

  testWidgets(
    'Off-bottom incoming messages keep position, expose unread and jump to latest',
    (tester) async {
      await mount(tester, ChatReadingAnchorDemo(repository: offline()));
      final scroll = tester
          .widget<CustomScrollView>(find.byKey(const ValueKey('anchor-scroll')))
          .controller!;
      scroll.jumpTo(70);
      await tester.pump();
      final before = scroll.offset;
      await tapDemoMenuAction(
        tester,
        find.byKey(const ValueKey('receive-message')),
      );
      await tester.pump();
      expect(scroll.offset, closeTo(before, .1));
      expect(find.byKey(const ValueKey('unread-prompt')), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('unread-prompt')));
      await tester.pumpAndSettle();
      expect(scroll.position.extentAfter, lessThan(2));
      expect(find.byKey(const ValueKey('unread-prompt')), findsNothing);
      await tapDemoMenuAction(
        tester,
        find.byKey(const ValueKey('receive-message')),
      );
      await tester.pumpAndSettle();
      expect(scroll.position.extentAfter, lessThan(2));
      await unmount(tester);
    },
  );

  testWidgets(
    'Same-axis gesture consumes inner pixels then passes only remainder outward and back',
    (tester) async {
      final relay = ScrollHandoffController();
      addTearDown(relay.dispose);
      await mount(
        tester,
        ScrollHandoffDemo(repository: offline(), controller: relay),
      );
      final gesture = await tester.startGesture(
        tester.getCenter(find.byKey(const ValueKey('relay-inner'))),
      );
      await gesture.moveBy(const Offset(0, -60));
      await gesture.moveBy(const Offset(0, -40));
      await tester.pump();
      expect(relay.inner.offset, greaterThan(0));
      expect(relay.outer.offset, 0);
      relay.inner.jumpTo(relay.inner.position.maxScrollExtent - 15);
      final prior = relay.outer.offset;
      await gesture.moveBy(const Offset(0, -80));
      await tester.pump();
      expect(
        relay.inner.offset,
        closeTo(relay.inner.position.maxScrollExtent, .01),
      );
      expect(relay.outer.offset - prior, closeTo(65, .01));
      expect(relay.owner, ScrollRelayOwner.outer);
      await gesture.moveBy(const Offset(0, 100));
      await tester.pump();
      expect(relay.outer.offset, 0);
      expect(
        relay.inner.offset,
        closeTo(relay.inner.position.maxScrollExtent - 35, .01),
      );
      expect(relay.handoffs, greaterThanOrEqualTo(2));
      await gesture.cancel();
      await tester.pump();
      expect(relay.owner, ScrollRelayOwner.idle);
      await unmount(tester);
    },
  );

  testWidgets(
    'Touch slop ignores small motion; orthogonal page/list gestures remain independent',
    (tester) async {
      final relay = ScrollHandoffController();
      addTearDown(relay.dispose);
      await mount(
        tester,
        ScrollHandoffDemo(repository: offline(), controller: relay),
      );
      final touch = await tester.startGesture(
        tester.getCenter(find.byKey(const ValueKey('relay-inner'))),
      );
      await touch.moveBy(const Offset(0, -5));
      await tester.pump();
      expect(relay.inner.offset, 0);
      await touch.cancel();
      await tester.tap(find.byKey(const ValueKey('orthogonal-mode')));
      await tester.pump();
      final pages = find.byKey(const ValueKey('orthogonal-pages'));
      await tester.drag(pages, const Offset(-650, 0));
      await tester.pumpAndSettle();
      expect(relay.pages.page, closeTo(1, .01));
      final page = relay.pages.page;
      final list = find.byKey(const PageStorageKey('orthogonal-list-1'));
      await tester.drag(list, const Offset(0, -200));
      await tester.pumpAndSettle();
      expect(relay.pages.page, closeTo(page!, .01));
      expect(
        tester
            .state<ScrollableState>(
              find
                  .descendant(of: list, matching: find.byType(Scrollable))
                  .first,
            )
            .position
            .pixels,
        greaterThan(0),
      );
      await unmount(tester);
    },
  );

  testWidgets(
    'Official sheet expands before list scrolls, pinned handle stays fixed and presets work',
    (tester) async {
      final sheet = DraggableScrollableController();
      addTearDown(sheet.dispose);
      await mount(
        tester,
        DraggablePinnedSheetDemo(repository: offline(), controller: sheet),
      );
      final scrollView = find.byKey(const ValueKey('sheet-list'));
      final shared = tester.widget<CustomScrollView>(scrollView).controller!;
      expect(sheet.size, closeTo(.55, .001));
      await tester.drag(scrollView, const Offset(0, -300));
      await tester.pumpAndSettle();
      expect(sheet.size, closeTo(.95, .001));
      final handleY = tester
          .getTopLeft(find.byKey(const ValueKey('sheet-pinned-handle')))
          .dy;
      await tester.drag(scrollView, const Offset(0, -220));
      await tester.pumpAndSettle();
      expect(shared.offset, greaterThan(0));
      expect(
        tester.getTopLeft(find.byKey(const ValueKey('sheet-pinned-handle'))).dy,
        closeTo(handleY, .1),
      );
      shared.jumpTo(0);
      await tester.pump();
      await tester.drag(scrollView, const Offset(0, 200));
      await tester.pumpAndSettle();
      expect(sheet.size, lessThan(.95));
      await tester.tap(find.byKey(const ValueKey('sheet-collapse')));
      await tester.pumpAndSettle();
      expect(sheet.size, closeTo(.25, .001));
      await unmount(tester);
    },
  );

  test(
    'Voice seats enforce occupancy, one local seat, mute and leave transitions',
    () {
      final seats = VoiceSeatController();
      addTearDown(seats.dispose);
      seats.select(1);
      expect(seats.join(), isFalse);
      seats.select(0);
      expect(seats.join(), isTrue);
      expect(seats.mine, 0);
      seats.toggleMute();
      expect(seats.seats[0].muted, isTrue);
      seats.select(2);
      expect(seats.join(), isTrue);
      expect(seats.seats[0].name, isNull);
      expect(seats.mine, 2);
      expect(seats.seats.where((s) => s.name == 'Jobs').length, 1);
      seats.leave();
      expect(seats.mine, -1);
      expect(
        seats.apply({
          'seats': [
            {'name': 'Jobs', 'muted': false},
            {'name': 'Jobs', 'muted': false},
          ],
          'selected': 0,
          'level': .5,
        }),
        isFalse,
      );
    },
  );

  testWidgets(
    'Seat buttons edit real model; background waveform and exit leave no tickers',
    (tester) async {
      final model = VoiceSeatController();
      addTearDown(model.dispose);
      await mount(
        tester,
        VoiceSeatDemo(repository: offline(), controller: model),
      );
      await tester.ensureVisible(find.byKey(const ValueKey('voice-join')));
      await tester.tap(find.byKey(const ValueKey('voice-join')));
      await tester.pump();
      expect(model.mine, 0);
      await tester.tap(find.byKey(const ValueKey('voice-mute')));
      await tester.pump();
      expect(model.seats[0].muted, isTrue);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump(const Duration(seconds: 1));
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('voice-leave')));
      await tester.pump();
      expect(model.mine, -1);
      await unmount(tester);
    },
  );

  testWidgets(
    'Gift queue merges active and pending IDs, rejects event replay and fills freed slot FIFO',
    (tester) async {
      final gifts = GiftComboController(duration: const Duration(seconds: 2));
      addTearDown(gifts.dispose);
      gifts.add(const GiftComboEvent('a', 'star'));
      gifts.add(const GiftComboEvent('b', 'heart'));
      gifts.add(const GiftComboEvent('c', 'rocket'));
      gifts.add(const GiftComboEvent('d', 'rocket', count: 3));
      gifts.add(const GiftComboEvent('e', 'star', count: 2));
      expect(gifts.slots.map((s) => s!.giftId), ['star', 'heart']);
      expect(gifts.slots[0]!.count, 3);
      expect(gifts.pending.single.count, 4);
      expect(gifts.add(const GiftComboEvent('e', 'star', count: 2)), isFalse);
      gifts.cancel('heart');
      expect(gifts.slots[1]!.giftId, 'rocket');
      expect(gifts.pending, isEmpty);
      expect(gifts.history.single.cancelled, isTrue);
      expect(gifts.timerCount, 2);
      await tester.pump(const Duration(milliseconds: 2050));
      expect(gifts.isEmpty, isTrue);
      expect(gifts.history.where((h) => !h.cancelled).length, 2);
      expect(gifts.timerCount, 0);
    },
  );

  testWidgets(
    'Gift combo renews expiry, cancellation cannot resurrect duplicate event, dispose cancels timers',
    (tester) async {
      var clock = DateTime(2026);
      final gifts = GiftComboController(
        duration: const Duration(seconds: 2),
        now: () => clock,
      );
      gifts.add(const GiftComboEvent('a', 'star'));
      await tester.pump(const Duration(seconds: 1));
      clock = clock.add(const Duration(seconds: 1));
      gifts.add(const GiftComboEvent('b', 'star'));
      await tester.pump(const Duration(milliseconds: 1100));
      clock = clock.add(const Duration(milliseconds: 1100));
      expect(gifts.slots[0]!.count, 2);
      gifts.cancel('star');
      expect(gifts.add(const GiftComboEvent('b', 'star')), isFalse);
      gifts.add(const GiftComboEvent('c', 'rocket'));
      gifts.dispose();
      expect(gifts.timerCount, 0);
      expect(gifts.add(const GiftComboEvent('d', 'heart')), isFalse);
      await tester.pump(const Duration(seconds: 4));
      expect(tester.takeException(), isNull);
    },
  );

  test('Gift remote snapshot rejects duplicate gift slots atomically', () {
    final gifts = GiftComboController();
    addTearDown(gifts.dispose);
    gifts.add(const GiftComboEvent('a', 'star'));
    expect(
      gifts.apply({
        'active': [
          {'giftId': 'star', 'count': 1, 'expiresAt': 0},
          {'giftId': 'star', 'count': 2, 'expiresAt': 0},
        ],
        'pending': [],
        'seen': [],
      }),
      isFalse,
    );
    expect(gifts.slots[0]!.giftId, 'star');
    expect(gifts.slots[1], isNull);
  });

  testWidgets(
    'Gift view has two slots and duplicate replay does not increment combo',
    (tester) async {
      final gifts = GiftComboController(duration: const Duration(seconds: 10));
      addTearDown(gifts.dispose);
      await mount(
        tester,
        GiftComboDemo(repository: offline(), controller: gifts),
      );
      await tester.tap(find.byKey(const ValueKey('gift-send')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('gift-replay')));
      await tester.pump();
      expect(gifts.slots[0]!.count, 1);
      expect(find.byKey(const ValueKey('gift-duplicate')), findsOneWidget);
      expect(find.byKey(const ValueKey('gift-slot-0')), findsOneWidget);
      expect(find.byKey(const ValueKey('gift-slot-1')), findsOneWidget);
      await unmount(tester);
    },
  );

  test('API protocol times out, accepts recovery, sends writes and rejects malformed JSON', () async {
    final requests = <http.Request>[];
    var phase = 0;
    final repo = InteractionRepository(
      timeout: const Duration(milliseconds: 10),
      client: MockClient((request) async {
        requests.add(request);
        if (phase == 0) {
          await Future<void>.delayed(const Duration(milliseconds: 30));
          return http.Response('{}', 200);
        }
        if (phase == 1) {
          return http.Response(
            jsonEncode({
              'value': ['remote'],
            }),
            200,
          );
        }
        if (phase == 2) return http.Response('{invalid', 200);
        return http.Response(request.body, 200);
      }),
    );
    addTearDown(repo.dispose);
    expect(await repo.read('test'), isNull);
    phase = 1;
    expect(await repo.read('test'), ['remote']);
    phase = 2;
    expect(await repo.read('test'), isNull);
    phase = 3;
    expect(await repo.write('test', ['written']), ['written']);
    expect(requests.last.method, 'PUT');
    expect(requests.last.url.path, '/api/curated-interactions/test');
    expect(jsonDecode(requests.last.body), {
      'value': ['written'],
    });
  });

  testWidgets(
    'Stale initial response cannot replace a later local chat write; reload recovers server truth',
    (tester) async {
      final initial = Completer<http.Response>();
      var reads = 0;
      final client = MockClient((request) async {
        if (request.method == 'PUT') return http.Response('{}', 503);
        if (++reads == 1) return initial.future;
        return http.Response(
          jsonEncode({
            'value': [
              {'id': 0, 'body': 'server recovered', 'mine': false},
            ],
          }),
          200,
        );
      });
      final repo = InteractionRepository(client: client);
      addTearDown(repo.dispose);
      await mount(tester, ChatReadingAnchorDemo(repository: repo));
      await tapDemoMenuAction(
        tester,
        find.byKey(const ValueKey('receive-message')),
      );
      await tester.pump();
      initial.complete(http.Response(jsonEncode({'value': []}), 200));
      await tester.pump();
      expect(find.byKey(const ValueKey('anchor-scroll')), findsOneWidget);
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pumpAndSettle();
      expect(find.textContaining('server recovered'), findsOneWidget);
      await unmount(tester);
    },
  );
  for (final name in ['anchor', 'relay', 'sheet', 'seats']) {
    testWidgets(
      '$name authoritative empty response has a real reload state and recovers',
      (tester) async {
        var requests = 0;
        final repo = InteractionRepository(
          client: MockClient((_) async {
            requests++;
            final empty = name == 'seats'
                ? {'seats': [], 'selected': 0, 'level': .5}
                : [];
            final full = switch (name) {
              'anchor' => [
                {'id': 0, 'body': 'restored', 'mine': false},
              ],
              'seats' => {
                'seats': [
                  {'name': null, 'muted': false},
                ],
                'selected': 0,
                'level': .5,
              },
              _ => ['restored'],
            };
            return http.Response(
              jsonEncode({'value': requests == 1 ? empty : full}),
              200,
            );
          }),
        );
        addTearDown(repo.dispose);
        await mount(tester, builders[name]!(repo));
        await tester.pumpAndSettle();
        expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
        final reload = find.widgetWithIcon(FilledButton, Icons.refresh);
        await tester.ensureVisible(reload);
        await tester.tap(reload);
        await tester.pumpAndSettle();
        expect(requests, 2);
        expect(find.byIcon(Icons.inbox_outlined), findsNothing);
        await unmount(tester);
      },
    );
  }
  testWidgets(
    'A delayed gift snapshot cannot resurrect a combo that expired while its write was in flight',
    (tester) async {
      final pending = Completer<http.Response>();
      String? snapshot;
      final repo = InteractionRepository(
        timeout: const Duration(seconds: 2),
        client: MockClient((request) async {
          if (request.method == 'GET') return http.Response('{}', 503);
          snapshot = request.body;
          return pending.future;
        }),
      );
      addTearDown(repo.dispose);
      final gifts = GiftComboController(
        duration: const Duration(milliseconds: 120),
      );
      addTearDown(gifts.dispose);
      await mount(tester, GiftComboDemo(controller: gifts, repository: repo));
      await tester.tap(find.byKey(const ValueKey('gift-send')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(gifts.isEmpty, isTrue);
      pending.complete(http.Response(snapshot!, 200));
      await tester.pump();
      expect(gifts.isEmpty, isTrue);
      expect(gifts.history.length, 1);
      await unmount(tester);
    },
  );
  testWidgets(
    'Removing a relay during an active drag releases recognizer ownership',
    (tester) async {
      await mount(tester, ScrollHandoffDemo(repository: offline()));
      final touch = await tester.startGesture(
        tester.getCenter(find.byKey(const ValueKey('relay-inner'))),
      );
      await touch.moveBy(const Offset(0, -70));
      await tester.pump();
      await tester.pumpWidget(const SizedBox.shrink());
      await touch.cancel();
      await tester.pump();
      expect(tester.takeException(), isNull);
    },
  );
}
