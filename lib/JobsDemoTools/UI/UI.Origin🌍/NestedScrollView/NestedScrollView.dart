import 'package:flutter/material.dart';
import 'package:jobs_runners/jobs_runners.dart';

// void main() => runApp(const JobsMaterialRunner(NestedScrollViewDemoPage(),
//     title: 'NestedScrollView Demo'));

void main() => runApp(const JobsMaterialRunner(SimpleNestedScrollDemo(),
    title: 'NestedScrollView Demo'));

class NestedScrollViewDemoPage extends StatelessWidget {
  const NestedScrollViewDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: NestedScrollView(
        floatHeaderSlivers: true,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              title: const Text('NestedScrollView Demo'),
              pinned: true,
              floating: true,
              expandedHeight: 200,
              forceElevated: innerBoxIsScrolled,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  color: Colors.blue.shade200,
                  alignment: Alignment.center,
                  child: const Text(
                    'Header',
                    style: TextStyle(
                      fontSize: 28,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              bottom: const TabBar(
                tabs: [
                  Tab(text: 'News'),
                  Tab(text: 'Sports'),
                  Tab(text: 'Tech'),
                ],
              ),
            ),
          ];
        },
        body: const TabBarView(
          children: [
            _TabList(title: 'News'),
            _TabList(title: 'Sports'),
            _TabList(title: 'Tech'),
          ],
        ),
      ),
    );
  }
}

class _TabList extends StatelessWidget {
  final String title;

  const _TabList({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      // 这里故意不传 controller
      // 让 NestedScrollView 提供的 PrimaryScrollController 接管
      itemCount: 30,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text('$title Item $index'),
        );
      },
    );
  }
}

class SimpleNestedScrollDemo extends StatelessWidget {
  const SimpleNestedScrollDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              title: const Text('Simple NestedScrollView'),
              pinned: true,
              expandedHeight: 180,
              forceElevated: innerBoxIsScrolled,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  color: Colors.orange.shade200,
                  alignment: Alignment.center,
                  child: const Text(
                    'Expandable Header',
                    style: TextStyle(fontSize: 24, color: Colors.white),
                  ),
                ),
              ),
            ),
          ];
        },
        body: ListView.builder(
          itemCount: 40,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text('Item $index'),
            );
          },
        ),
      ),
    );
  }
}
