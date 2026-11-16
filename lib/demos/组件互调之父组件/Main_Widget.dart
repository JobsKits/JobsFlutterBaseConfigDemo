// 独立运行：flutter run -t "lib/demos/组件互调之父组件/Main_Widget.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';
import 'package:jobs_runners/jobs_runners.dart'; // 公共测试器路径
import 'package:jobs_flutter_base_config/JobsDemoTools/UI/UI.Origin🌍/Widget的相互调用/A_Widget.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() => launchLegacyStandalone(legacyOriginalMain, title: '组件互调之父组件');

void legacyOriginalMain() =>
    legacyCaptureApp(const JobsMaterialRunner(MyApp(), title: 'Flutter Demo'));

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const OtherWidget();
  }
}

class OtherWidget extends StatelessWidget {
  const OtherWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: JobsDemoAppBar(title: const LegacyText('Other Widget')),
      body: Center(
        child: const A_Widget()
            .buildTextWidget(), // 调用 BettingCasinoMyBetListView 中的方法
      ),
    );
  }
}

Widget buildLegacyDemo(BuildContext context) =>
    LegacyLaunchPage(action: legacyOriginalMain, title: 'Main_Widget');
