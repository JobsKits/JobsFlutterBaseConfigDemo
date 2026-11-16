// 独立运行：flutter run -t "lib/demos/侧滑菜单/侧滑菜单.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

void main() => runApp(const JobsDemoApp(home: SideMenuDemo()));

class SideMenuDemo extends StatefulWidget {
  const SideMenuDemo({super.key});
  @override
  State<SideMenuDemo> createState() => _SideMenuDemoState();
}

class _SideMenuDemoState extends State<SideMenuDemo> {
  final _controller = JobsSideMenuController();
  bool _fullWidth = false;
  double _widthFactor = .78;
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => JobsSideMenu(
    controller: _controller,
    fullWidth: _fullWidth,
    widthFactor: _widthFactor,
    menu: ListView(
      children: [
        ListTile(
          title: Text(
            tr(context, '侧滑菜单'),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        for (final key in ['全部功能', '收藏', '最近使用', '设置'])
          ListTile(
            title: Text(tr(context, key)),
            trailing: const Icon(Icons.chevron_right),
            onTap: _controller.close,
          ),
      ],
    ),
    child: Scaffold(
      appBar: JobsDemoAppBar(
        title: Text(tr(context, '侧滑菜单')),
        actions: [
          IconButton(
            tooltip: tr(context, '打开菜单'),
            onPressed: _controller.open,
            icon: const Icon(Icons.menu),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            tr(context, '菜单支持边缘拖动和返回关闭'),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 24),
          SwitchListTile(
            title: Text(tr(context, '全开')),
            value: _fullWidth,
            onChanged: (value) => setState(() => _fullWidth = value),
          ),
          ListTile(
            title: Text(tr(context, '菜单宽度')),
            trailing: Text('${(_widthFactor * 100).round()}%'),
          ),
          Slider(
            value: _widthFactor,
            min: .4,
            max: .95,
            onChanged: _fullWidth
                ? null
                : (value) => setState(() => _widthFactor = value),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _controller.open,
            child: Text(tr(context, '打开菜单')),
          ),
        ],
      ),
    ),
  );
}
