import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void legacyOriginalMain() {
  legacyCaptureApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('zh', '');

  void _switchLanguage(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LegacyAppBoundary(
      app: MaterialApp(
        localizationsDelegates: const [
          // 提供 Material 设计组件的本地化资源。包括诸如按钮、对话框、日期选择器等在内的各种组件的本地化字符串。
          GlobalMaterialLocalizations.delegate,
          // 提供基本的小部件（widget）的本地化支持。这些小部件包括 TextField 的提示文本等。
          GlobalWidgetsLocalizations.delegate,
          // 提供 Cupertino（iOS 风格）组件的本地化支持。包括 iOS 风格的日期选择器、对话框等的本地化字符串。
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('zh', ''), // Chinese, no country code
          Locale('en', ''), // English, no country code
          Locale('ja', ''), // Japanese, no country code
        ],
        locale: _locale,
        home: Scaffold(
          appBar: AppBar(
            title: const LegacyText('Intl Demo'),
            actions: [
              PopupMenuButton<Locale>(
                onSelected: _switchLanguage,
                itemBuilder: (BuildContext context) => <PopupMenuEntry<Locale>>[
                  const PopupMenuItem<Locale>(
                    value: Locale('zh', ''),
                    child: LegacyText('中文'),
                  ),
                  const PopupMenuItem<Locale>(
                    value: Locale('en', ''),
                    child: LegacyText('English'),
                  ),
                  const PopupMenuItem<Locale>(
                    value: Locale('ja', ''),
                    child: LegacyText('日本語'),
                  ),
                ],
                icon: const Icon(Icons.language),
              ),
            ],
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                LegacyText(
                  _locale.languageCode == 'zh'
                      ? '你好'
                      : _locale.languageCode == 'ja'
                      ? 'こんにちは'
                      : 'Hello',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() => launchLegacyStandalone(legacyOriginalMain, title: '旧例·国际化示例一');
