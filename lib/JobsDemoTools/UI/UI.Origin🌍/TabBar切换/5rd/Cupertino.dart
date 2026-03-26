import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:jobs_runners/jobs_runners.dart';
void main() => runApp(
      JobsCupertinoRunner(
        MyCupertinoTabPage(),
        title: 'Cupertino Tab 示例'.tr,
      ),
    );

class MyCupertinoTabPage extends StatefulWidget {
  const MyCupertinoTabPage({super.key});

  @override
  State<MyCupertinoTabPage> createState() => _MyCupertinoTabPageState();
}

class _MyCupertinoTabPageState extends State<MyCupertinoTabPage> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    Center(child: Text('首页'.tr)),
    Center(child: Text('搜索'.tr)),
    Center(child: Text('我的'.tr)),
  ];

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.home), label: '首页'.tr),
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.search), label: '搜索'.tr),
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.person), label: '我的'.tr),
        ],
      ),
      tabBuilder: (context, index) {
        return CupertinoTabView(
          builder: (_) => _tabs[index],
        );
      },
    );
  }
}
