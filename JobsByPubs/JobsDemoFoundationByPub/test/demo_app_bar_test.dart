import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets(
    'one direct action switches effective theme and advertises next action',
    (tester) async {
      final settings = JobsDemoSettings();
      await settings.init();
      await tester.pumpWidget(
        JobsDemoApp(
          settings: settings,
          showSettings: false,
          home: Scaffold(
            appBar: JobsDemoAppBar(title: const Text('Demo')),
            body: Builder(
              builder: (context) => Text(Theme.of(context).brightness.name),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byTooltip('切换到黑夜'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('demo-theme-action')));
      await tester.pumpAndSettle();
      expect(find.text('dark'), findsOneWidget);
      expect(settings.themeMode, ThemeMode.dark);
      expect(find.byTooltip('切换到白天'), findsOneWidget);
      final restored = JobsDemoSettings();
      await restored.init();
      expect(restored.themeMode, ThemeMode.dark);
      await tester.tap(find.byKey(const ValueKey('demo-theme-action')));
      await tester.pumpAndSettle();
      expect(find.text('light'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      settings.dispose();
      restored.dispose();
    },
  );

  testWidgets(
    'existing icon text and popup actions share one menu and keep callbacks',
    (tester) async {
      final settings = JobsDemoSettings();
      var value = 0;
      await tester.pumpWidget(
        JobsDemoApp(
          settings: settings,
          showSettings: false,
          home: Scaffold(
            appBar: JobsDemoAppBar(
              title: const Text('Demo'),
              actions: [
                IconButton(
                  tooltip: 'Clear',
                  onPressed: () => value++,
                  icon: const Icon(Icons.clear),
                ),
                TextButton(
                  onPressed: () => value += 10,
                  child: const Text('Save'),
                ),
                IconButton(
                  tooltip: 'Disabled',
                  onPressed: null,
                  icon: const Icon(Icons.lock),
                ),
                PopupMenuButton<int>(
                  onSelected: (number) => value += number,
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 100, child: Text('English')),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('demo-actions-menu')), findsOneWidget);
      expect(find.byKey(const ValueKey('demo-theme-action')), findsNothing);
      Future<void> open() async {
        await tester.tap(find.byKey(const ValueKey('demo-actions-menu')));
        await tester.pumpAndSettle();
      }

      await open();
      await tester.tap(find.text('Clear'));
      await tester.pumpAndSettle();
      expect(value, 1);
      await open();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(value, 11);
      await open();
      final disabled = tester.widget<PopupMenuItem<VoidCallback>>(
        find.ancestor(
          of: find.text('Disabled'),
          matching: find.byType(PopupMenuItem<VoidCallback>),
        ),
      );
      expect(disabled.enabled, isFalse);
      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();
      expect(value, 111);
      await open();
      await tester.tap(find.byKey(const ValueKey('demo-theme-menu-item')));
      await tester.pumpAndSettle();
      expect(settings.themeMode, ThemeMode.dark);
      await tester.pumpWidget(const SizedBox());
      settings.dispose();
    },
  );

  testWidgets(
    'captured app host delegates inner actions and nested routes without duplicate entry',
    (tester) async {
      final settings = JobsDemoSettings();
      var selected = false;
      await tester.pumpWidget(
        JobsDemoApp(
          settings: settings,
          showSettings: false,
          home: JobsDemoActionHost(
            child: Scaffold(
              appBar: JobsDemoAppBar(
                title: const Text('Host'),
                actionHost: true,
              ),
              body: Navigator(
                onGenerateRoute: (_) => MaterialPageRoute<void>(
                  builder: (context) => Scaffold(
                    appBar: JobsDemoAppBar(
                      title: const Text('Inner'),
                      actions: [
                        IconButton(
                          tooltip: 'Inner action',
                          onPressed: () => selected = true,
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),
                    body: TextButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => Scaffold(
                            appBar: JobsDemoAppBar(title: const Text('Next')),
                            body: const Text('Next page'),
                          ),
                        ),
                      ),
                      child: const Text('Push'),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('demo-actions-menu')), findsOneWidget);
      expect(find.byKey(const ValueKey('demo-theme-action')), findsNothing);
      await tester.tap(find.byKey(const ValueKey('demo-actions-menu')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Inner action'));
      await tester.pumpAndSettle();
      expect(selected, isTrue);
      await tester.tap(find.text('Push'));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('demo-theme-action')), findsOneWidget);
      expect(find.byKey(const ValueKey('demo-actions-menu')), findsNothing);
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('demo-actions-menu')), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      settings.dispose();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Cupertino navigation shares the same working theme entry', (
    tester,
  ) async {
    final settings = JobsDemoSettings();
    await tester.pumpWidget(
      JobsDemoApp(
        settings: settings,
        showSettings: false,
        home: const CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            middle: Text('Demo'),
            trailing: JobsDemoActions(),
          ),
          child: Center(child: Text('Body')),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('demo-theme-action')));
    await tester.pumpAndSettle();
    expect(settings.themeMode, ThemeMode.dark);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    settings.dispose();
  });

  testWidgets(
    'same-route inner actions remain registered while their popup overlays the page',
    (tester) async {
      var saved = 0;
      final settings = JobsDemoSettings();
      await tester.pumpWidget(
        JobsDemoApp(
          settings: settings,
          showSettings: false,
          home: JobsDemoActionHost(
            child: Scaffold(
              appBar: JobsDemoAppBar(
                title: const Text('Host'),
                actionHost: true,
              ),
              body: Scaffold(
                appBar: JobsDemoAppBar(
                  title: const Text('Inner'),
                  actions: [
                    TextButton(
                      onPressed: () => saved++,
                      child: const Text('Save inner'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('demo-actions-menu')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save inner'));
      await tester.pumpAndSettle();
      expect(saved, 1);
      expect(find.byKey(const ValueKey('demo-actions-menu')), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      settings.dispose();
    },
  );

  testWidgets(
    'all ten locales remain usable in narrow large text and both themes',
    (tester) async {
      tester.view.physicalSize = const Size(320, 740);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final settings = JobsDemoSettings();
      await tester.pumpWidget(
        JobsDemoApp(
          settings: settings,
          showSettings: false,
          home: Builder(
            builder: (context) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: const TextScaler.linear(1.8)),
              child: Scaffold(
                appBar: JobsDemoAppBar(
                  title: const Text('Demo'),
                  actions: [
                    IconButton(
                      tooltip: 'Business',
                      onPressed: () {},
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      for (final locale in jobsDemoLocales) {
        settings.setLocale(locale);
        for (final mode in [ThemeMode.light, ThemeMode.dark]) {
          settings.setThemeMode(mode);
          await tester.pumpAndSettle();
          await tester.tap(find.byKey(const ValueKey('demo-actions-menu')));
          await tester.pumpAndSettle();
          expect(
            find.byKey(const ValueKey('demo-theme-menu-item')),
            findsOneWidget,
          );
          expect(tester.takeException(), isNull);
          await tester.tap(find.byKey(const ValueKey('demo-theme-menu-item')));
          await tester.pumpAndSettle();
        }
      }
      await tester.pumpWidget(const SizedBox());
      settings.dispose();
    },
  );
}
