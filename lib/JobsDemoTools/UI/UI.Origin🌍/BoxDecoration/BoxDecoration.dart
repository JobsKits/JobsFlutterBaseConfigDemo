import 'package:flutter/material.dart';
import 'package:jobs_runners/jobs_runners.dart'; // 公共测试器路径

// 展示了如何为 Container 小部件添加背景颜色、边框、阴影和圆角等效果：
// Container 使用了 BoxDecoration 来设置其外观。
// color 属性设置了背景颜色为蓝色。
// border 属性添加了黑色边框，宽度为 3。
// borderRadius 属性将边框的圆角半径设置为 12。
// boxShadow 属性添加了一个阴影效果。
// gradient 属性设置了从蓝色到紫色的线性渐变背景。

void main() => runApp(
    const JobsMaterialRunner(BoxDecorationDemo(), title: 'BoxDecoration Demo'));

class BoxDecorationDemo extends StatelessWidget {
  const BoxDecorationDemo({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.blue, // 背景颜色
          border: Border.all(
            color: Colors.black,
            width: 3,
          ), // 边框
          borderRadius: BorderRadius.circular(12), // 圆角
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3), // 阴影偏移量
            ),
          ],
          gradient: const LinearGradient(
            colors: [Colors.blue, Colors.purple],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ), // 渐变背景
        ),
        child: const Center(
          child: Text(
            'BoxDecoration',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
    );
  }
}
