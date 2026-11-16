// 独立运行：flutter run -t "lib/demos/四向页面转场/四向页面转场.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

import '../../demo_hub/ui_parity_strings.dart';

void main() => runApp(
  const JobsDemoApp(home: DirectionalNavigationDemo(), title: '四向页面转场'),
);

class DirectionalNavigationDemo extends StatefulWidget {
  const DirectionalNavigationDemo({super.key});
  @override
  State<DirectionalNavigationDemo> createState() => _DirectionalState();
}

class _DirectionalState extends State<DirectionalNavigationDemo> {
  int direction = 0;
  bool pushing = false, star = false;
  Future<void> push() async {
    if (pushing) return;
    setState(() => pushing = true);
    final vector = [
      const Offset(0, -1),
      const Offset(1, 0),
      const Offset(0, 1),
      const Offset(-1, 0),
    ][direction];
    await Navigator.push(
      context,
      PageRouteBuilder<void>(
        pageBuilder: (context, _, __) => _DirectionDetail(direction: direction),
        transitionDuration: const Duration(milliseconds: 360),
        reverseTransitionDuration: const Duration(milliseconds: 360),
        transitionsBuilder: (context, animation, secondary, child) =>
            SlideTransition(
              position: Tween<Offset>(begin: vector, end: Offset.zero).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOutCubic,
                ),
              ),
              child: child,
            ),
      ),
    );
    if (mounted) setState(() => pushing = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: JobsDemoAppBar(
      actions: [
        IconButton(
          key: const ValueKey('navigation-toolbar-star'),
          tooltip: uiTr(context, '工具栏'),
          onPressed: () => setState(() => star = !star),
          icon: Icon(star ? Icons.star : Icons.star_outline),
        ),
      ],
      title: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: 'Jobs ',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(text: uiTr(context, '四向页面转场')),
          ],
        ),
      ),
    ),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('${uiTr(context, '工具栏')}: ${uiTr(context, star ? '已点亮' : '未点亮')}'),
        for (final sample in ['普通Push', '工具栏', '内联标题'])
          ListTile(
            title: Text(uiTr(context, sample)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push<void>(
              context,
              MaterialPageRoute(
                builder: (context) => Scaffold(
                  appBar: JobsDemoAppBar(title: Text(uiTr(context, sample))),
                  body: Center(
                    child: Text(
                      uiTr(context, sample),
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                ),
              ),
            ),
          ),
        const Divider(),
        for (var i = 0; i < 4; i++)
          RadioListTile<int>(
            title: Text(uiTr(context, ['上', '右', '下', '左'][i])),
            value: i,
            groupValue: direction,
            onChanged: (v) => setState(() => direction = v!),
          ),
        FilledButton(
          onPressed: pushing ? null : push,
          child: Text(uiTr(context, '开始')),
        ),
      ],
    ),
  );
}

class _DirectionDetail extends StatelessWidget {
  const _DirectionDetail({required this.direction});
  final int direction;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: JobsDemoAppBar(
      title: Text(uiTr(context, ['上', '右', '下', '左'][direction])),
    ),
    body: Center(
      child: FilledButton.icon(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back),
        label: Text(uiTr(context, '上一页')),
      ),
    ),
  );
}
