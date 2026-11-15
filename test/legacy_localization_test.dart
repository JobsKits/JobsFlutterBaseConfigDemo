import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';
import 'package:jobs_flutter_base_config/demo_hub/legacy_catalog.dart';
import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';

void main() {
  test('旧界面十语词库含完整列，动态状态保留实参并翻译嵌套状态', () {
    for (final row in legacyTranslations.values) {
      expect(row.length, 10);
      expect(row.every((value) => value.isNotEmpty), isTrue);
    }
    expect(
      legacyUiTextForLocale(const Locale('en'), '状态：GET 请求成功'),
      'Status: GET request succeeded',
    );
    expect(legacyUiTextForLocale(const Locale('fr'), 'Page 7'), 'Page 7');
    expect(
      legacyUiTextForLocale(const Locale('en'), '邀请码:ABC123已成功复制到剪切板'),
      'Invite code ABC123 copied',
    );
  });
  testWidgets('真实旧表单的控件、输入提示和校验跟随十语与三主题', (tester) async {
    final entry = legacyDemos.singleWhere((e) => e.id == 'legacy-global-key');
    final settings = JobsDemoSettings();
    await tester.pumpWidget(
      JobsDemoApp(
        settings: settings,
        showSettings: false,
        home: Builder(builder: entry.builder),
      ),
    );
    for (final locale in jobsDemoLocales) {
      settings.setLocale(locale);
      await tester.pumpAndSettle();
      expect(
        find.text(legacyUiTextForLocale(locale, 'Change Text')),
        findsOneWidget,
      );
      expect(
        find.text(legacyUiTextForLocale(locale, 'Enter Text')),
        findsWidgets,
      );
      await tester.tap(find.text(legacyUiTextForLocale(locale, 'Validate')));
      await tester.pumpAndSettle();
      expect(
        tester
            .state<FormFieldState<String>>(find.byType(TextFormField))
            .errorText,
        legacyUiTextForLocale(locale, 'Please enter some text'),
      );
      await tester.tap(find.text(legacyUiTextForLocale(locale, 'Reset')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
    for (final mode in ThemeMode.values) {
      settings.setThemeMode(mode);
      await tester.pumpAndSettle();
      final context = tester.element(find.byType(TextFormField));
      expect(
        Theme.of(context).brightness,
        mode == ThemeMode.dark ? Brightness.dark : Brightness.light,
      );
    }
    await tester.pumpWidget(const SizedBox());
    settings.dispose();
  });
  testWidgets('旧GetX词典真正注册，十语及原切换按钮驱动预览状态', (tester) async {
    final entry = legacyDemos.singleWhere((e) => e.id == 'legacy-complete-40');
    final settings = JobsDemoSettings();
    await tester.pumpWidget(
      JobsDemoApp(
        settings: settings,
        showSettings: false,
        home: Builder(builder: entry.builder),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    for (final locale in jobsDemoLocales) {
      settings.setLocale(locale);
      await tester.pumpAndSettle();
      expect(
        find.text(legacyUiTextForLocale(locale, 'Hello, World!')),
        findsOneWidget,
      );
      expect(
        find.text(
          legacyUiTextForLocale(
            locale,
            'Welcome, %s!',
          ).replaceFirst('%s', 'John'),
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    }
    await tester.tap(
      find.text(legacyUiTextForLocale(settings.locale, 'Switch Language')),
    );
    await tester.pumpAndSettle();
    expect(settings.locale.languageCode, 'en');
    await tester.pumpWidget(const SizedBox());
    settings.dispose();
  });
}
