// 独立运行：flutter run -t "lib/demos/控制台打印教学/Print.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:jobs_flutter_base_config/JobsDemoTools/JobsFlutterTools/调试/JobsCommonUtil.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/Data/Data.Origin🌍/打印/TimeAgo.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() => launchLegacyStandalone(legacyOriginalMain, title: '控制台打印教学');

void legacyOriginalMain() {
  WidgetsFlutterBinding.ensureInitialized(); // 确保 Flutter 绑定初始化
  legacyCaptureApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return LegacyAppBoundary(
      app: MaterialApp(
        home: Scaffold(
          appBar: JobsDemoAppBar(
            title: const LegacyText('Data Loading Example'),
          ),
          body: FutureBuilder(
            future: _loadData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return const Center(child: LegacyText('Data loaded'));
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        ),
      ),
    );
  }
}

Future<void> _loadData() async {
  try {
    JobsPrint("AAA");
    String jsonString = await rootBundle.loadString('assets/Jsons/data.json');
    JobsPrint(jsonString);

    TimeAgo timeAgo = TimeAgo(123456789098765);
    JobsPrint(timeAgo);
    JobsPrint(timeAgo.yearsAgo);
    JobsPrint(timeAgo.monthsAgo);
    JobsPrint(timeAgo.daysAgo);
    JobsPrint(timeAgo.hoursAgo);
    JobsPrint(timeAgo.minutesAgo);
    JobsPrint(timeAgo.secondsAgo);

    var fruits = ['Apple', 'Banana', 'Orange'];
    JobsPrint(fruits);
  } catch (e) {
    JobsPrint('Error loading local JSON: $e');
  }
}

Widget buildLegacyDemo(BuildContext context) =>
    LegacyLaunchPage(action: legacyOriginalMain, title: 'Print');
