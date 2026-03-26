import 'package:flutter/material.dart';
import 'package:jobs_runners/jobs_runners.dart'; // 公共测试器路径

// 不自动滚动
void main() => runApp(const JobsMaterialRunner(SmoothScrollDemo()));

class SmoothScrollDemo extends StatelessWidget {
  const SmoothScrollDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smooth Scroll Demo'),
      ),
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            pinned: true,
            expandedHeight: 150.0,
            flexibleSpace: FlexibleSpaceBar(
              title: Text('Smooth Scroll'),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return ListTile(
                  title: Text('Item #$index'),
                );
              },
              childCount: 20,
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              height: 200.0,
              color: Colors.blue,
              child: const Center(
                child: Text(
                  'SliverToBoxAdapter Content',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return ListTile(
                  title: Text('Item #${index + 20}'),
                );
              },
              childCount: 20,
            ),
          ),
        ],
      ),
    );
  }
}
