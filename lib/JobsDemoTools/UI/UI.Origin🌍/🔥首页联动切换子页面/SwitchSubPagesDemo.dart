import 'package:flutter/material.dart';
import 'package:jobs_runners/jobs_runners.dart';

void main() => runApp(const JobsMaterialRunner(MainPage(), title: '安全加载图片'));

class MainPage extends StatefulWidget {
  const MainPage({super.key});
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
  final List<String> topTabs = ['活动', '任务', 'VIP', '利息宝', '返水'];

  late TabController _mainTabController;

  @override
  void initState() {
    _mainTabController = TabController(length: topTabs.length, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: topTabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: TabBar(
            controller: _mainTabController,
            isScrollable: true,
            indicatorColor: Colors.orange,
            labelColor: Colors.redAccent,
            unselectedLabelColor: Colors.grey,
            tabs: topTabs.map((e) => Tab(text: e)).toList(),
          ),
          backgroundColor: Colors.white,
        ),
        body: TabBarView(
          controller: _mainTabController,
          children: topTabs.map((e) => SubPage(title: e)).toList(),
        ),
      ),
    );
  }
}

class SubPage extends StatefulWidget {
  final String title;
  const SubPage({super.key, required this.title});

  @override
  State<SubPage> createState() => _SubPageState();
}

class _SubPageState extends State<SubPage> {
  int selectedIndex = 0;

  // 不同 Tab（活动/任务/VIP...）对应不同菜单内容
  late List<String> menuList;

  @override
  void initState() {
    super.initState();
    final int suffix = _tabIndexSuffix(widget.title);
    menuList = ['日常', '新人', '电子', '体育', '棋牌', '真人', '捕鱼', '钱包教程']
        .map((e) => '$e.$suffix')
        .toList();
  }

  // 为每个 Tab 页标记一个唯一编号后缀
  int _tabIndexSuffix(String title) {
    switch (title) {
      case '活动':
        return 1;
      case '任务':
        return 2;
      case 'VIP':
        return 3;
      case '利息宝':
        return 4;
      case '返水':
        return 5;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 左侧菜单
        Container(
          width: 80,
          color: Colors.grey[100],
          child: ListView.builder(
            itemCount: menuList.length,
            itemBuilder: (context, index) {
              final bool selected = index == selectedIndex;
              return GestureDetector(
                onTap: () => setState(() => selectedIndex = index),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: selected ? Colors.orange[100] : Colors.transparent,
                    border: Border(
                      left: BorderSide(
                        color: selected ? Colors.cyan : Colors.transparent,
                        width: 4,
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.star,
                          color: selected ? Colors.orange : Colors.grey),
                      const SizedBox(height: 4),
                      Text(menuList[index],
                          style: TextStyle(
                              fontSize: 12,
                              color:
                                  selected ? Colors.orange : Colors.black54)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // 右侧内容
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: 5,
            itemBuilder: (_, index) => _ActivityCard(
              title:
                  '${widget.title} - ${menuList[selectedIndex]} 活动 ${index + 1}',
              subtitle: '神秘彩金等你来拿',
              icon: Icons.mail,
              color: Colors.purple.shade100,
            ),
          ),
        ),
      ],
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _ActivityCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient:
              LinearGradient(colors: [color.withValues(alpha: 0.6), color]),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 48, color: Colors.deepOrange),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style:
                          const TextStyle(fontSize: 14, color: Colors.black54)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
