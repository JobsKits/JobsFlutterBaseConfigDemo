import 'package:flutter/material.dart';
import 'package:jobs_runners/jobs_runners.dart';

// 根据父小部件的大小动态构建布局：
// LayoutBuilder 被用作 Container 的子小部件。
// LayoutBuilder 的 builder 方法提供一个 BuildContext 和 BoxConstraints 对象。
// 根据 BoxConstraints 的 maxWidth 属性，决定显示不同的子小部件：
// 如果 maxWidth 大于 200，显示绿色背景的 Container，并显示文本 "Large Container"。
// 如果 maxWidth 小于或等于 200，显示红色背景的 Container，并显示文本 "Small Container"。
// 外层 Container 设置了宽度和高度为 300，用于测试目的。
// 通过这种方式，您可以根据父小部件的大小动态地构建不同的布局。
void main() => runApp(
    const JobsMaterialRunner(LayoutBuilderDemo(), title: 'LayoutBuilder Demo'));

class LayoutBuilderDemo extends StatelessWidget {
  const LayoutBuilderDemo({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 300,
        height: 300,
        color: Colors.grey[300],
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 200) {
              return Container(
                color: Colors.green,
                child: const Center(
                  child: Text(
                    'Large Container',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              );
            } else {
              return Container(
                color: Colors.red,
                child: const Center(
                  child: Text(
                    'Small Container',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
