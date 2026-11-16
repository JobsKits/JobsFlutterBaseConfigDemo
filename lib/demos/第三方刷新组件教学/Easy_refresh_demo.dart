// 独立运行：flutter run -t "lib/demos/第三方刷新组件教学/Easy_refresh_demo.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:jobs_runners/jobs_runners.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() => launchLegacyStandalone(legacyOriginalMain, title: '第三方刷新组件教学');

// 公共测试器路径

void legacyOriginalMain() => legacyCaptureApp(
  const JobsMaterialRunner(MyHomePage(), title: 'EasyRefresh Demo'),
);

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _itemCount = 20;
  bool _hasMore = true;
  final EasyRefreshController _controller = EasyRefreshController(
    // _AssertionError ('package:easy_refresh/src/controller/controller.dart': Failed assertion: line 206 pos 12: 'controlFinishLoad || force': Please set controlFinishLoad to true, then use. If you want to modify the result, you can set force to true.)
    // _AssertionError ('package:easy_refresh/src/controller/controller.dart': Failed assertion: line 196 pos 12: 'controlFinishRefresh || force': Please set controlFinishRefresh to true, then use. If you want to modify the result, you can set force to true.)
    controlFinishLoad:
        true, // 控制是否完成刷新，默认false，设置为true后，刷新完成后，不会再次刷新，除非设置force为true
    controlFinishRefresh:
        true, // 控制是否完成加载，默认false，设置为true后，加载完成后，不会再次加载，除非设置force为true
  );

  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _itemCount = 20;
      _hasMore = true;
    });
    _controller.finishRefresh();
    _controller.resetFooter();
  }

  Future<void> _onLoad() async {
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _itemCount += 10;
      if (_itemCount >= 50) {
        _hasMore = false;
      }
    });
    if (_hasMore) {
      _controller.finishLoad(IndicatorResult.success);
    } else {
      _controller.finishLoad(IndicatorResult.noMore);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: JobsDemoAppBar(title: const LegacyText('EasyRefresh Demo')),
      body: EasyRefresh(
        controller: _controller,
        onRefresh: _onRefresh,
        onLoad: _onLoad,
        header: const MaterialHeader(),
        footer: const MaterialFooter(),
        child: ListView.builder(
          itemCount: _itemCount,
          itemBuilder: (context, index) {
            return ListTile(title: LegacyText('Item $index'));
          },
        ),
      ),
    );
  }
}

Widget buildLegacyDemo(BuildContext context) =>
    LegacyLaunchPage(action: legacyOriginalMain, title: 'Easy_refresh_demo');
