import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';

void legacyOriginalMain() {
  legacyCaptureApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return LegacyAppBoundary(
      app: MaterialApp(
        home: DefaultTabController(
          length: 2, // 定义选项卡的数量
          child: Scaffold(
            appBar: AppBar(
              title: const LegacyText('UnderlineTabIndicator Demo'),
              bottom: TabBar(
                tabs: [
                  Tab(text: legacyControlLabel(context, 'Tab 1')),
                  Tab(text: legacyControlLabel(context, 'Tab 2')),
                ],
                indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(width: 4.0, color: Colors.white),
                  insets: EdgeInsets.symmetric(horizontal: 16.0),
                ),
              ),
            ),
            body: const TabBarView(
              children: [
                Center(child: LegacyText('Content of Tab 1')),
                Center(child: LegacyText('Content of Tab 2')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() => launchLegacyStandalone(legacyOriginalMain, title: '旧例·分页下划线指示器');
