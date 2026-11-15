import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';
import 'package:jobs_runners/jobs_runners.dart'; // 公共测试器路径

// 高仿 iOC.OC.JXCategoryView
// 真机运行如果出现空白页面的解决方案：
// 方案1、在工程根目录下执行 flutter run --release 或者
// 方案2、通过 flutter devices 拿到设备id，然后 flutter run -d 设备ID

void legacyOriginalMain() => legacyCaptureApp(
  const JobsMaterialRunner(MyHomePage(), title: 'Flutter TabBar Demo'),
);

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  final List<Tab> myTabs = <Tab>[
    Tab(text: legacyControlLabelFallback('明教')),
    Tab(text: legacyControlLabelFallback('霸刀')),
    Tab(text: legacyControlLabelFallback('天策')),
    Tab(text: legacyControlLabelFallback('纯阳')),
    Tab(text: legacyControlLabelFallback('少林')),
    Tab(text: legacyControlLabelFallback('藏剑')),
    Tab(text: legacyControlLabelFallback('七秀')),
    Tab(text: legacyControlLabelFallback('五毒')),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: myTabs.length,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: const LegacyText('Flutter TabBar Demo'),
          bottom: TabBar(
            tabs: myTabs,
            isScrollable: true,
            indicatorColor: Colors.red,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabAlignment: TabAlignment.start, // 左对齐:使得Tabbar的左侧和设备左侧对齐
            // labelPadding: EdgeInsets.zero, // 移除标签的默认填充。如果不指定 labelPadding 属性，TabBar 中每个标签之间的空隙是由系统自动分配的默认填充值决定的
            indicatorSize: TabBarIndicatorSize.tab, // 指示器大小为整个 tab
            // 使用 decoration 来设置 TabBar 背景颜色
            indicator: const BoxDecoration(
              color: Colors.blueAccent,
              border: Border(bottom: BorderSide(color: Colors.red, width: 2.0)),
            ),
          ),
        ),
        body: TabBarView(
          children: myTabs.map((Tab tab) {
            return Center(child: LegacyText(tab.text ?? 'No Text'));
          }).toList(),
        ),
      ),
    );
  }
}

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() => launchLegacyStandalone(legacyOriginalMain, title: '分类分页标签');
