// 独立运行：flutter run -t "lib/demos/翻页浏览/翻页浏览.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

void main() => runApp(const JobsDemoApp(home: PageBrowsingDemo()));

class PageBrowsingDemo extends StatefulWidget {
  const PageBrowsingDemo({super.key});
  @override
  State<PageBrowsingDemo> createState() => _PageBrowsingDemoState();
}

class _PageBrowsingDemoState extends State<PageBrowsingDemo> {
  final _controller = PageController(viewportFraction: .86);
  int _index = 0;
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _go(int page) => _controller.animateToPage(
    page,
    duration: const Duration(milliseconds: 280),
    curve: Curves.easeOutCubic,
  );
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: JobsDemoAppBar(title: Text(tr(context, '翻页浏览'))),
    body: Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _controller,
            itemCount: 5,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 24),
              child: Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Center(
                  child: Text(
                    '${i + 1}',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Text(
          '${_index + 1} / 5',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        Padding(
          padding: const EdgeInsets.all(24),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 16,
            runSpacing: 8,
            children: [
              OutlinedButton(
                onPressed: _index > 0 ? () => _go(_index - 1) : null,
                child: Text(tr(context, '上一页')),
              ),
              FilledButton(
                onPressed: _index < 4 ? () => _go(_index + 1) : null,
                child: Text(tr(context, '下一页')),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
