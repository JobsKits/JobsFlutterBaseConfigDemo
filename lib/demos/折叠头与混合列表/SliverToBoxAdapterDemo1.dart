// 独立运行：flutter run -t "lib/demos/折叠头与混合列表/SliverToBoxAdapterDemo1.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';
import 'package:jobs_runners/jobs_runners.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() => launchLegacyStandalone(legacyOriginalMain, title: '折叠头与混合列表');

// 公共测试器路径

// 不自动滚动
void legacyOriginalMain() =>
    legacyCaptureApp(const JobsMaterialRunner(SmoothScrollDemo()));

class SmoothScrollDemo extends StatelessWidget {
  const SmoothScrollDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: JobsDemoAppBar(title: const LegacyText('Smooth Scroll Demo')),
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            pinned: true,
            expandedHeight: 150.0,
            flexibleSpace: FlexibleSpaceBar(title: LegacyText('Smooth Scroll')),
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
              color: Colors.blue,
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

Widget buildLegacyDemo(BuildContext context) => const SmoothScrollDemo();
