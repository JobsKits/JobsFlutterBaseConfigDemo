// 独立运行：flutter run -t "lib/demos/GetX国际化词典/GetX_InternationalDemo.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart' hide tr;
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() => launchLegacyStandalone(legacyOriginalMain, title: 'GetX国际化词典');

void legacyOriginalMain() {
  legacyCaptureApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  void changeLanguage(Locale locale) {
    legacyChangeLocale(locale); // 更新应用语言
  }

  @override
  Widget build(BuildContext context) {
    return LegacyAppBoundary(
      app: GetMaterialApp(
        title: 'App多语言国际化Demo',
        translations: MyTranslations(), // 指定翻译文件
        locale: const Locale('en', 'US'), // 设置默认语言
        fallbackLocale: const Locale('en', 'US'), // 如果没有指定语言，使用的默认语言
        home: const HomeScreen(key: Key('home')),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    Localizations.localeOf(context); // 跟随局部 Locale 重建 Get 词条，保留控制器。
    return Scaffold(
      // key: key, // 将 key 赋值给 Scaffold 的 key 参数
      appBar: JobsDemoAppBar(
        title: const LegacyText('Internationalization Demo'),
      ),
      body: GetBuilder<Legacy40LanguageController>(
        init: Legacy40LanguageController(), // 初始化GetBuilder并传入控制器
        builder: (controller) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LegacyText(
                  'hello'.tr, // 使用GetX的.tr函数获取翻译后的字符串
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(height: 20),
                LegacyText(
                  'greet'.trArgs(['John']), // 使用GetX的.trArgs函数传递参数
                  style: const TextStyle(fontSize: 24),
                ),
                ElevatedButton(
                  onPressed: () {
                    // 点击按钮时切换语言
                    controller.changeLanguage();
                  },
                  child: const LegacyText('Switch Language'), // 切换语言
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class Legacy40LanguageController extends GetxController {
  void changeLanguage() {
    // 获取当前语言
    var currentLocale = Get.locale;
    // 如果当前语言是英语，则切换到西班牙语，否则切换回英语
    legacyChangeLocale(
      currentLocale!.languageCode == 'en'
          ? const Locale('es', 'ES')
          : const Locale('en', 'US'),
    );
  }
}

class MyTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    for (final locale in jobsDemoLocales)
      '${locale.languageCode}_${locale.scriptCode ?? locale.countryCode}': {
        'hello': legacyUiTextForLocale(locale, 'Hello, World!'),
        'greet': legacyUiTextForLocale(locale, 'Welcome, %s!'),
      },
  };
}

typedef LanguageController = Legacy40LanguageController;

Widget buildLegacyDemo(BuildContext context) => LegacyLaunchPage(
  action: legacyOriginalMain,
  title: 'GetX_InternationalDemo',
  onDispose: () {
    if (Get.isRegistered<LanguageController>())
      Get.delete<LanguageController>();
  },
);
