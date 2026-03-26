import 'package:flutter/material.dart';
import 'package:jobs_runners/jobs_runners.dart'; // 公共测试器路径
import 'JobsAlertDialog.dart'; // 引入自定义弹窗文件

void main() => runApp(const JobsMaterialRunner(HomeScreen(), title: 'XXX'));

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('对话框演示'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                JobsAlertDialog.show(
                  context,
                  autoDismiss: true, // 自动消失
                  autoDismissDuration: 2, // 自动消失持续时间（2秒）
                  title: '自动消失对话框', // 标题
                  subtitle: '这个对话框将在2秒后消失。', // 副标题
                  titleSubtitleSpacing: 10.0, // 标题和副标题之间的间距
                  titleTextStyle: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.yellow,
                  ), // 标题文本样式
                  subtitleTextStyle: const TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                  ), // 副标题文本样式
                  barrierDismissible: true, // 点击阴影部分是否可以关闭对话框
                  titleTextAlign: TextAlign.center, // 标题对齐方式
                  subtitleTextAlign: TextAlign.center, // 副标题对齐方式
                  backgroundColor: Colors.green.withOpacity(0.8), // 自定义背景颜色
                  contentPadding: const EdgeInsets.all(30), // 自定义内边距
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ), // 自定义形状
                );
              },
              child: const Text('显示自动消失对话框'),
            ),
            ElevatedButton(
              onPressed: () {
                JobsAlertDialog.show(
                  context,
                  autoDismiss: false, // 手动消失
                  title: '手动消失对话框', // 标题
                  subtitle: '你需要手动关闭这个对话框。', // 副标题
                  titleSubtitleSpacing: 10.0, // 标题和副标题之间的间距
                  titleTextStyle: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.yellow,
                  ), // 标题文本样式
                  subtitleTextStyle: const TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                  ), // 副标题文本样式
                  barrierDismissible: false, // 点击阴影部分是否可以关闭对话框
                  titleTextAlign: TextAlign.left, // 标题对齐方式
                  subtitleTextAlign: TextAlign.left, // 副标题对齐方式
                  actions: [
                    const Text('关闭'), // 自定义按钮
                  ],
                  actionTextStyles: [
                    const TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold),
                  ], // 自定义按钮文本样式
                  actionCallbacks: [
                    () {
                      Navigator.of(context).pop();
                    },
                  ], // 自定义按钮点击事件
                );
              },
              child: const Text('显示手动消失对话框'),
            ),
            ElevatedButton(
              onPressed: () {
                JobsAlertDialog.show(
                  context,
                  autoDismiss: false, // 手动消失
                  title: '自定义按钮对话框', // 标题
                  subtitle: '这个对话框有自定义按钮。', // 副标题
                  titleSubtitleSpacing: 10.0, // 标题和副标题之间的间距
                  titleTextStyle: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.yellow,
                  ), // 标题文本样式
                  subtitleTextStyle: const TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                  ), // 副标题文本样式
                  barrierDismissible: true, // 点击阴影部分是否可以关闭对话框
                  titleTextAlign: TextAlign.center, // 标题对齐方式
                  subtitleTextAlign: TextAlign.center, // 副标题对齐方式
                  actions: [
                    const Text('取消'),
                    const Text('确定'),
                    const Text('自定义'),
                  ], // 自定义按钮数组
                  actionTextStyles: [
                    const TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold),
                    const TextStyle(
                        color: Colors.green, fontWeight: FontWeight.bold),
                    const TextStyle(
                        color: Colors.blue, fontWeight: FontWeight.bold),
                  ], // 自定义按钮文本样式数组
                  actionCallbacks: [
                    () {
                      Navigator.of(context).pop();
                    },
                    () {
                      Navigator.of(context).pop();
                    },
                    () {
                      // 自定义按钮的点击事件
                    },
                  ], // 自定义按钮点击事件数组
                );
              },
              child: const Text('显示自定义按钮对话框'),
            ),
            ElevatedButton(
              onPressed: () {
                JobsAlertDialog.show(
                  context,
                  autoDismiss: false, // 手动消失
                  titleRichText: const TextSpan(
                    children: [
                      TextSpan(
                        text: '富文本标题 ',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.yellow,
                        ),
                      ),
                      TextSpan(
                        text: '示例',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ), // 富文本标题
                  subtitleRichText: const TextSpan(
                    children: [
                      TextSpan(
                        text: '这是一个 ',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white70,
                        ),
                      ),
                      TextSpan(
                        text: '富文本副标题',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ), // 富文本副标题
                  titleSubtitleSpacing: 10.0, // 标题和副标题之间的间距
                  barrierDismissible: true, // 点击阴影部分是否可以关闭对话框
                  titleTextAlign: TextAlign.center, // 标题对齐方式
                  subtitleTextAlign: TextAlign.center, // 副标题对齐方式
                  actions: [
                    const Text('关闭'),
                  ], // 自定义按钮
                  actionTextStyles: [
                    const TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold),
                  ], // 自定义按钮文本样式
                  actionCallbacks: [
                    () {
                      Navigator.of(context).pop();
                    },
                  ], // 自定义按钮点击事件
                );
              },
              child: const Text('显示富文本对话框'),
            ),
          ],
        ),
      ),
    );
  }
}
