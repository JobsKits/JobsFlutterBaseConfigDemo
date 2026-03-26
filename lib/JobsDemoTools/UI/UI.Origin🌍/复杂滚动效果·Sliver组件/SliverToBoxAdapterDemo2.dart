import 'package:flutter/material.dart';
import 'package:jobs_runners/jobs_runners.dart'; // 公共测试器路径

// 自动滚动+丝滑滚动
void main() => runApp(const JobsMaterialRunner(SmoothAutoScrollDemo()));

class SmoothAutoScrollDemo extends StatefulWidget {
  const SmoothAutoScrollDemo({super.key});

  @override
  _SmoothAutoScrollDemoState createState() => _SmoothAutoScrollDemoState();
}

class _SmoothAutoScrollDemoState extends State<SmoothAutoScrollDemo> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Flutter 框架中用于桥接 Flutter 框架与底层引擎的一个类，它管理应用的生命周期、调度框架的重绘和事件处理等
    // 事件循环和调度：WidgetsBinding 处理来自底层操作系统的事件（例如触摸事件、键盘事件）并将其传递给框架中的相应部分。
    // 它还负责调度帧（frame），确保 Flutter 应用以高帧率运行。
    // 应用生命周期管理：通过 WidgetsBinding，你可以监听应用的生命周期事件，如进入前台、进入后台等。这对于处理应用状态保存和恢复非常有用。
    // 渲染树更新：WidgetsBinding 确保在需要时重绘应用的 UI。它监听框架的变化，当需要重新渲染时，会调度帧以更新显示。
    // 平台消息处理：WidgetsBinding 处理来自底层平台的消息，例如 MethodChannel 的调用。它确保这些消息能够被正确地处理和响应。
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoScroll();
    });
  }

  void _autoScroll() {
    _scrollController
        .animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(seconds: 10),
      curve: Curves.linear,
      // Curves 是 Flutter 中用于定义动画曲线的类。
      // 它包含了许多预定义的静态常量，表示不同的插值函数，用于控制动画的速度和节奏。
      // 下面是 Curves 类中一些常见的曲线选项：

      // linear:线性插值，动画以恒定的速度进行。
      // ease:动画开始和结束时较慢，中间速度较快。通常用于提供平滑的过渡。
      // easeIn:动画开始时较慢，然后逐渐加速。适用于进入动画。
      // easeOut:动画开始时较快，然后逐渐减速。适用于退出动画。
      // easeInOut:动画开始和结束时较慢，中间速度较快。适用于进入和退出的平滑过渡。
      // fastOutSlowIn:动画开始时较快，然后逐渐减速。常用于 Material Design 的标准曲线。
      // bounceIn:动画开始时有一个弹跳效果，然后加速进入目标位置。
      // bounceOut:动画开始时较快，然后在结束时有一个弹跳效果。
      // bounceInOut:结合了 bounceIn 和 bounceOut 的效果，动画开始和结束时都有弹跳效果。
      // elasticIn:动画开始时有一个弹性效果，逐渐加速进入目标位置。
      // elasticOut:动画开始时较快，然后在结束时有一个弹性效果。
      // elasticInOut:结合了 elasticIn 和 elasticOut 的效果，动画开始和结束时都有弹性效果。
      // decelerate:动画开始时较快，然后逐渐减速。适用于自然的减速效果。
      // fastLinearToSlowEaseIn:画开始时是线性速度，然后逐渐减速进入目标位置。
      // slowMiddle:动画开始和结束时较快，中间部分较慢。
    )
        .then((_) {
      _scrollController.jumpTo(0);
      _autoScroll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smooth Auto Scroll Demo'),
      ),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          const SliverAppBar(
            pinned: true,
            expandedHeight: 150.0,
            flexibleSpace: FlexibleSpaceBar(
              title: Text('Smooth Auto Scroll'),
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
          // SliverToBoxAdapter(
          //   child: Container(
          //     height: 200.0,
          //     color: Colors.blue,
          //     child: const Center(
          //       child: Text(
          //         'SliverToBoxAdapter Content',
          //         style: TextStyle(color: Colors.white, fontSize: 20),
          //       ),
          //     ),
          //   ),
          // ),
          // SliverList(
          //   delegate: SliverChildBuilderDelegate(
          //     (BuildContext context, int index) {
          //       return ListTile(
          //         title: Text('Item #${index + 20}'),
          //       );
          //     },
          //     childCount: 20,
          //   ),
          // ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
