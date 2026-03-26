import 'package:flutter/material.dart';
import 'package:jobs_runners/jobs_runners.dart'; // 公共测试器路径

void main() => runApp(const JobsMaterialRunner(StopAutoScrollDemo()));

class StopAutoScrollDemo extends StatefulWidget {
  const StopAutoScrollDemo({super.key});

  @override
  _StopAutoScrollDemoState createState() => _StopAutoScrollDemoState();
}

class _StopAutoScrollDemoState extends State<StopAutoScrollDemo> {
  final ScrollController _scrollController = ScrollController();
  int _currentIndex = 0;
  bool _scrolling = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoScroll();
    });
  }

  void _autoScroll() async {
    while (_scrolling) {
      if (_scrollController.hasClients) {
        const itemHeight = 56.0; // Assuming each item has a height of 56.0
        await _scrollController.animateTo(
          _currentIndex * itemHeight,
          duration: const Duration(milliseconds: 500),
          curve: Curves.linear,
        );
        await Future.delayed(const Duration(seconds: 1));
        _currentIndex++;
        if (_currentIndex >= 40) {
          // Assuming there are 40 items in total
          _currentIndex = 0;
          _scrollController.jumpTo(0);
        }
      }
    }
  }

  @override
  void dispose() {
    _scrolling = false;
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stop Auto Scroll Demo'),
      ),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          const SliverAppBar(
            pinned: true,
            expandedHeight: 150.0,
            flexibleSpace: FlexibleSpaceBar(
              title: Text('Stop Auto Scroll'),
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
              color: Colors.red,
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
