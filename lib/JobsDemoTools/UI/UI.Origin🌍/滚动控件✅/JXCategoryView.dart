import 'package:flutter/material.dart';
import 'package:jobs_runners/jobs_runners.dart'; // 公共测试器路径
// 高仿 iOC.OC.JXCategoryView
// 真机运行如果出现空白页面的解决方案：
// 方案1、在工程根目录下执行 flutter run --release 或者
// 方案2、通过 flutter devices 拿到设备id，然后 flutter run -d 设备ID

void main() => runApp(
    const JobsMaterialRunner(MyHomePage(), title: 'Flutter TabBar Demo'));

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  final List<Tab> myTabs = <Tab>[
    const Tab(text: '明教'),
    const Tab(text: '霸刀'),
    const Tab(text: '天策'),
    const Tab(text: '纯阳'),
    const Tab(text: '少林'),
    const Tab(text: '藏剑'),
    const Tab(text: '七秀'),
    const Tab(text: '五毒'),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: myTabs.length,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: const Text('Flutter TabBar Demo'),
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
              border: Border(
                bottom: BorderSide(
                  color: Colors.red,
                  width: 2.0,
                ),
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: myTabs.map((Tab tab) {
            return Center(
              child: Text(tab.text ?? 'No Text'),
            );
          }).toList(),
        ),
      ),
    );
  }
}
