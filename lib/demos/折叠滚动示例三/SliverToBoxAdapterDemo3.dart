// 独立运行：flutter run -t "lib/demos/折叠滚动示例三/SliverToBoxAdapterDemo3.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';
import 'package:jobs_runners/jobs_runners.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() => launchLegacyStandalone(legacyOriginalMain, title: '折叠滚动示例三');

// 公共测试器路径

void legacyOriginalMain() =>
    legacyCaptureApp(const JobsMaterialRunner(StopAutoScrollDemo()));

class StopAutoScrollDemo extends StatefulWidget {
  const StopAutoScrollDemo({super.key});

  @override
  State<StopAutoScrollDemo> createState() => _StopAutoScrollDemoState();
}

class _StopAutoScrollDemoState extends State<StopAutoScrollDemo> {
  final ScrollController _scrollController = ScrollController();
  int _currentIndex = 0;
  bool _scrolling = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoScroll();
    });
  }

  void _autoScroll() async {
    while (_scrolling) {
      if (_scrollController.hasClients) {
        const itemHeight = 56.0; // Assuming each item has a height of 56.0
        await _scrollController.animateTo(
          _currentIndex * itemHeight,
          duration: const Duration(milliseconds: 500),
          curve: Curves.linear,
        );
        await Future.delayed(const Duration(seconds: 1));
        _currentIndex++;
        if (_currentIndex >= 40) {
          // Assuming there are 40 items in total
          _currentIndex = 0;
          _scrollController.jumpTo(0);
        }
      }
    }
  }

  @override
  void dispose() {
    _scrolling = false;
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: JobsDemoAppBar(title: const LegacyText('Stop Auto Scroll Demo')),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          const SliverAppBar(
            pinned: true,
            expandedHeight: 150.0,
            flexibleSpace: FlexibleSpaceBar(
              title: LegacyText('Stop Auto Scroll'),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate((
              BuildContext context,
              int index,
            ) {
              return ListTile(title: LegacyText('Item #$index'));
            }, childCount: 20),
          ),
          SliverToBoxAdapter(
            child: Container(
              height: 200.0,
              color: Colors.red,
              child: const Center(
                child: LegacyText(
                  'SliverToBoxAdapter Content',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate((
              BuildContext context,
              int index,
            ) {
              return ListTile(title: LegacyText('Item #${index + 20}'));
            }, childCount: 20),
          ),
        ],
      ),
    );
  }
}

Widget buildLegacyDemo(BuildContext context) => LegacyLaunchPage(
  action: legacyOriginalMain,
  title: 'SliverToBoxAdapterDemo3',
);
