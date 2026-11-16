// 独立运行：flutter run -t "lib/demos/资源词典国际化/EasyLocalizationAppDemo.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart' hide tr;
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() => launchLegacyStandalone(legacyOriginalMain, title: '资源词典国际化');

void legacyOriginalMain() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  legacyCaptureApp(
    EasyLocalization(
      supportedLocales: jobsDemoLocales,
      path: 'inline',
      assetLoader: const LegacyInlineTranslations(),
      fallbackLocale: const Locale('en'),
      child: const EasyLocalizationAppDemo(),
    ),
  );
}

class EasyLocalizationAppDemo extends StatelessWidget {
  const EasyLocalizationAppDemo({super.key});
  @override
  Widget build(BuildContext context) {
    return LegacyAppBoundary(
      app: MaterialApp(
        home: Scaffold(
          appBar: JobsDemoAppBar(title: const LegacyText('EasyLocalization')),
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Builder(
                    builder: (localized) => LegacyText(
                      localized.tr('greeting'),
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(
                      jobsDemoLocales.length,
                      (index) => ChoiceChip(
                        label: LegacyText(jobsDemoLanguageNames[index]),
                        selected: context.locale == jobsDemoLocales[index],
                        onSelected: (_) {
                          context.setLocale(jobsDemoLocales[index]);
                          JobsDemoScope.maybeOf(context)
                              ?.setLocale(jobsDemoLocales[index]);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
      ),
    );
  }
}

class LegacyInlineTranslations extends AssetLoader {
  const LegacyInlineTranslations();
  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    final index = jobsDemoLocales.indexOf(locale);
    return {
      'greeting': const [
        '你好',
        '您好',
        'བཀྲ་ཤིས་བདེ་ལེགས།',
        'Hello',
        'こんにちは',
        'Bonjour',
        'Hola',
        'Hallo',
        'Привет',
        '안녕하세요',
      ][index < 0 ? 3 : index],
    };
  }
}

Widget buildLegacyDemo(BuildContext context) => LegacyLaunchPage(
  action: legacyOriginalMain,
  title: 'EasyLocalizationAppDemo',
);
