// 独立运行：flutter run -t "lib/demos/页面构建过程/MainBuildPage.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/UI/UI.Origin🌍/页面的构建/Pages/Sys/CupertinoAppDemo.dart'
    show CupertinoAppDemo;
import 'package:jobs_flutter_base_config/JobsDemoTools/UI/UI.Origin🌍/页面的构建/Pages/3rd/DevicePreviewAppDemo.dart'
    show DevicePreviewAppDemo;
import 'package:jobs_flutter_base_config/JobsDemoTools/UI/UI.Origin🌍/页面的构建/Pages/3rd/EasyLocalizationAppDemo.dart'
    show EasyLocalizationAppDemo;
import 'package:jobs_flutter_base_config/JobsDemoTools/UI/UI.Origin🌍/页面的构建/Pages/3rd/GetMaterialAppDemo.dart'
    show GetMaterialAppDemo;
import 'package:jobs_flutter_base_config/JobsDemoTools/UI/UI.Origin🌍/页面的构建/Pages/Sys/MaterialAppDemo.dart'
    show MaterialAppDemo;
import 'package:jobs_flutter_base_config/JobsDemoTools/UI/UI.Origin🌍/页面的构建/Pages/3rd/PhoenixAppDemo.dart'
    show PhoenixAppDemo;
import 'package:jobs_flutter_base_config/JobsDemoTools/UI/UI.Origin🌍/页面的构建/Pages/3rd/WidgetsAppDemo.dart'
    show WidgetsAppDemo;

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() => launchLegacyStandalone(legacyOriginalMain, title: '页面构建过程');

void legacyOriginalMain() => legacyCaptureApp(const RootApp());

class RootApp extends StatelessWidget {
  const RootApp({super.key});

  @override
  Widget build(BuildContext context) {
    return LegacyAppBoundary(
      app: const MaterialApp(
        debugShowCheckedModeBanner: false,

        /// 是否显示右上角的红色 DEBUG 标识（横幅）
        home: Scaffold(body: HomePage()),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SectionTitle('🧱 主结构（App 级别容器）'),
          ListTile(
            title: const LegacyText('MaterialApp 示例'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MaterialAppDemo()),
            ),
          ),
          ListTile(
            title: const LegacyText('GetMaterialApp 示例'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const GetMaterialAppDemo()),
            ),
          ),
          ListTile(
            title: const LegacyText('CupertinoApp 示例'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CupertinoAppDemo()),
            ),
          ),
          ListTile(
            title: const LegacyText('WidgetsApp 示例'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const WidgetsAppDemo()),
            ),
          ),
          ListTile(
            title: const LegacyText('EasyLocalization 示例'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const EasyLocalizationAppDemo(),
              ),
            ),
          ),
          ListTile(
            title: const LegacyText('Phoenix 示例'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PhoenixAppDemo()),
            ),
          ),
          ListTile(
            title: const LegacyText('DevicePreview 示例'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DevicePreviewAppDemo()),
            ),
          ),
        ],
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String text;
  const SectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: LegacyText(
        text,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}

Widget buildLegacyDemo(BuildContext context) =>
    LegacyLaunchPage(action: legacyOriginalMain, title: 'MainBuildPage');
