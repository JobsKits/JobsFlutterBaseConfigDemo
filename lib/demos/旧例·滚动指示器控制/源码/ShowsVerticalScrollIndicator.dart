import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';
import 'package:jobs_runners/jobs_runners.dart';

void legacyOriginalMain() => legacyCaptureApp(
  const JobsMaterialRunner(
    ScrollViewWithScrollbar(),
    title: 'Scroll View with Scrollbar',
  ),
);

class ScrollViewWithScrollbar extends StatefulWidget {
  const ScrollViewWithScrollbar({super.key});
  @override
  State<ScrollViewWithScrollbar> createState() =>
      _ScrollViewWithScrollbarState();
}

class _ScrollViewWithScrollbarState extends State<ScrollViewWithScrollbar> {
  final ScrollController _scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    return RawScrollbar(
      thumbColor: Colors.redAccent,
      controller: _scrollController,
      thumbVisibility: true, // 始终显示滚动条
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: List.generate(
            50,
            (index) => ListTile(title: LegacyText('Item $index')),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() => launchLegacyStandalone(legacyOriginalMain, title: '旧例·滚动指示器控制');
