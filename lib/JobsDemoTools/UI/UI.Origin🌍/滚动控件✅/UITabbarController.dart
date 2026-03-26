import 'package:flutter/material.dart';
import 'package:jobs_runners/jobs_runners.dart'; // 公共测试器路径

// 高仿iOC.UITabbarController
// 真机运行如果出现空白页面的解决方案：
// 方案1、在工程根目录下执行 flutter run --release 或者
// 方案2、通过 flutter devices 拿到设备id，然后 flutter run -d 设备ID

void main() => runApp(
    const JobsMaterialRunner(MyHomePage(), title: 'Flutter TabBar Demo'));

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter TabBar Demo'),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          HomeTab(),
          SearchTab(),
          ProfileTab(),
        ],
      ),
      bottomNavigationBar: Material(
        color: Colors.blue,
        child: TabBar(
          controller: _tabController,
          tabs: const [
            // Tab本身默认就是上下结构：上图下文
            Tab(icon: Icon(Icons.home), text: 'Home'),
            Tab(icon: Icon(Icons.search), text: 'Search'),
            Tab(icon: Icon(Icons.person), text: 'Profile'),
          ],
        ),
      ),
    );
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Home Tab Content'),
    );
  }
}

class SearchTab extends StatelessWidget {
  const SearchTab({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Search Tab Content'),
    );
  }
}

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Profile Tab Content'),
    );
  }
}
