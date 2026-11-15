import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';
import 'package:jobs_runners/jobs_runners.dart'; // 公共测试器路径
import 'package:jobs_flutter_base_config/JobsDemoTools/UI/UI.Origin🌍/Widget的相互调用/A_Widget.dart';

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
      appBar: AppBar(title: const LegacyText('Other Widget')),
      body: Center(
        child: const A_Widget()
            .buildTextWidget(), // 调用 BettingCasinoMyBetListView 中的方法
      ),
    );
  }
}

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() => launchLegacyStandalone(legacyOriginalMain, title: '旧例·组件互调之父组件');
