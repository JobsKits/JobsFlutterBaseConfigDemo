// 独立运行：flutter run -t "lib/demos/主题切换示例二/Theme2.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() => launchLegacyStandalone(legacyOriginalMain, title: '主题切换示例二');

/// 动态切换主题（例如从亮模式切换到暗模式）
void legacyOriginalMain() {
  legacyCaptureApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return LegacyAppBoundary(
      app: MaterialApp(
        title: 'Flutter Theme Demo',
        theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
        home: HomeScreen(
          isDarkMode: _isDarkMode,
          onThemeToggle: () {
            setState(() {
              _isDarkMode = !_isDarkMode;
            });
          },
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  const HomeScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: JobsDemoAppBar(title: const LegacyText('Home Screen')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            LegacyText(
              'Hello, World!',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onThemeToggle,
              child: const LegacyText('Toggle Theme'),
            ),
            const SizedBox(height: 20),
            LegacyText(
              'Current Theme: ${isDarkMode ? "Dark" : "Light"}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}

Widget buildLegacyDemo(BuildContext context) =>
    LegacyLaunchPage(action: legacyOriginalMain, title: 'Theme2');
