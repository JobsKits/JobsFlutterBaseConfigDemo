import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';
import 'package:jobs_flutter_base_config/demo_hub/interaction_support.dart';
import 'package:jobs_flutter_base_config/demos/可拖面板吸顶列表/可拖面板吸顶列表.dart';
import 'package:jobs_flutter_base_config/demos/同轴滚动接力/同轴滚动接力.dart';
import 'package:jobs_flutter_base_config/demos/礼物双槽连击/礼物双槽连击.dart';
import 'package:jobs_flutter_base_config/demos/聊天阅读锚点/聊天阅读锚点.dart';
import 'package:jobs_flutter_base_config/demos/麦位互动与声浪/麦位互动与声浪.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Opt-in artifacts. Explicit system fonts replace Ahem; no font enters the app.
void main() {
  testWidgets(
    'Capture five curated interactions with actual Chinese typography',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final output = Directory(
        const String.fromEnvironment(
          'INTERACTION_CAPTURE_DIR',
          defaultValue: '项目相关报告/截图/互动蒸馏',
        ),
      );
      await tester.runAsync(() async {
        final bytes = await File(
          const String.fromEnvironment(
            'INTERACTION_CAPTURE_FONT',
            defaultValue: '/System/Library/Fonts/STHeiti Medium.ttc',
          ),
        ).readAsBytes();
        final font = FontLoader('JobsInteractionCapture')
          ..addFont(Future.value(ByteData.sublistView(bytes)));
        await font.load();
        final latin = FontLoader('Roboto')
          ..addFont(
            Future.value(
              ByteData.sublistView(
                await File('/System/Library/Fonts/Supplemental/Arial.ttf')
                    .readAsBytes(),
              ),
            ),
          );
        await latin.load();
        final icons = FontLoader('MaterialIcons')
          ..addFont(
            Future.value(
              ByteData.sublistView(
                await File(
                  '.fvm/flutter_sdk/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
                ).readAsBytes(),
              ),
            ),
          );
        await icons.load();
        await output.create(recursive: true);
      });
      final repo = InteractionRepository(
        client: MockClient((_) async => http.Response('{}', 503)),
      );
      addTearDown(repo.dispose);
      for (final dark in [false, true]) {
        for (final name in [
          '聊天阅读锚点',
          '同轴滚动接力',
          '可拖面板吸顶列表',
          '麦位互动与声浪',
          '礼物双槽连击',
        ]) {
          final key = GlobalKey();
          final relay = ScrollHandoffController();
          final seat = VoiceSeatController();
          final gift = GiftComboController(
            duration: const Duration(seconds: 20),
          );
          final settings = JobsDemoSettings(
            locale: const Locale('zh'),
            themeMode: dark ? ThemeMode.dark : ThemeMode.light,
          );
          if (name == '麦位互动与声浪') seat.join();
          if (name == '礼物双槽连击') {
            gift.add(const GiftComboEvent('capture-1', 'star', count: 5));
            gift.add(const GiftComboEvent('capture-2', 'heart', count: 3));
            gift.add(const GiftComboEvent('capture-3', 'rocket', count: 2));
          }
          final page = switch (name) {
            '聊天阅读锚点' => ChatReadingAnchorDemo(repository: repo),
            '同轴滚动接力' => ScrollHandoffDemo(repository: repo, controller: relay),
            '可拖面板吸顶列表' => DraggablePinnedSheetDemo(repository: repo),
            '麦位互动与声浪' => VoiceSeatDemo(repository: repo, controller: seat),
            _ => GiftComboDemo(repository: repo, controller: gift),
          };
          await tester.pumpWidget(
            JobsDemoApp(
              settings: settings,
              showSettings: false,
              home: Builder(
                builder: (context) {
                  final theme = Theme.of(context);
                  return Theme(
                    data: theme.copyWith(
                      textTheme: theme.textTheme.apply(
                        fontFamily: 'JobsInteractionCapture',
                      ),
                      primaryTextTheme: theme.primaryTextTheme.apply(
                        fontFamily: 'JobsInteractionCapture',
                      ),
                    ),
                    child: RepaintBoundary(key: key, child: page),
                  );
                },
              ),
            ),
          );
          for (var i = 0; i < 12; i++) {
            await tester.pump(const Duration(milliseconds: 50));
          }
          if (name == '聊天阅读锚点') {
            final scroll = tester
                .widget<CustomScrollView>(
                  find.byKey(const ValueKey('anchor-scroll')),
                )
                .controller!;
            scroll.jumpTo(170);
            await tester.pump();
            await tester.tap(find.byKey(const ValueKey('prepend-history')));
            await tester.tap(find.byKey(const ValueKey('receive-message')));
          } else if (name == '同轴滚动接力') {
            relay.begin(inside: true);
            relay.move(relay.inner.position.maxScrollExtent + 60);
          } else if (name == '可拖面板吸顶列表') {
            await tester.tap(find.byKey(const ValueKey('sheet-expand')));
            await tester.pumpAndSettle();
            final controller = tester
                .widget<CustomScrollView>(
                  find.byKey(const ValueKey('sheet-list')),
                )
                .controller!;
            controller.jumpTo(130);
          }
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 100));
          expect(tester.takeException(), isNull, reason: name);
          final boundary =
              key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
          await tester.runAsync(() async {
            final image = await boundary.toImage(pixelRatio: 2);
            final data = await image.toByteData(format: ui.ImageByteFormat.png);
            await File('${output.path}/$name-${dark ? '深色' : '浅色'}.png')
                .writeAsBytes(data!.buffer.asUint8List());
            image.dispose();
          });
          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pump();
          relay.dispose();
          seat.dispose();
          gift.dispose();
          settings.dispose();
        }
      }
    },
    skip: !const bool.fromEnvironment('CAPTURE_INTERACTIONS'),
  );
}
