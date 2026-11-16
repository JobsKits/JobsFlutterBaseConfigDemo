// 独立运行：flutter run -t "lib/demos/日期货币格式化/intl_format_Demo.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jobs_runners/jobs_runners.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() => launchLegacyStandalone(legacyOriginalMain, title: '日期货币格式化');

// 公共测试器路径

void legacyOriginalMain() => legacyCaptureApp(
  const JobsMaterialRunner(MyHomePage(), title: 'Intl Demo'),
);

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});
  @override
  Widget build(BuildContext context) {
    // 当前日期时间
    DateTime now = DateTime.now();
    // 格式化日期
    String formattedDate = DateFormat.yMMMMd().format(now);
    // 格式化货币
    double price = 1234.56;
    String formattedPrice = NumberFormat.currency(
      locale: 'en_US',
      symbol: '\$',
    ).format(price);
    return Scaffold(
      appBar: JobsDemoAppBar(title: const LegacyText('Intl Demo')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const LegacyText('Formatted Date:', style: TextStyle(fontSize: 20)),
            LegacyText(formattedDate, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            const LegacyText(
              'Formatted Price:',
              style: TextStyle(fontSize: 20),
            ),
            LegacyText(formattedPrice, style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}

Widget buildLegacyDemo(BuildContext context) =>
    LegacyLaunchPage(action: legacyOriginalMain, title: 'intl_format_Demo');
