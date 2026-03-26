import 'package:flutter/material.dart';
import 'package:jobs_runners/jobs_runners.dart'; // 公共测试器路径

// 这个示例展示了如何使用 Stack 小部件在同一屏幕上重叠显示多个小部件
// Positioned 小部件用于将按钮定位到 Stack 的右下角。通过指定 bottom 和 right 属性，可以精确控制按钮的位置。
void main() => runApp(const JobsMaterialRunner(MyApp(), title: 'Stack Demo'));

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Center(
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            // 背景图像
            Container(
              width: 300,
              height: 300,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                      'https://flutter.dev/images/catalog-widget-placeholder.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // 居中的文本
            const Text(
              'Hello, Flutter!',
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            // 右下角的按钮
            Positioned(
              bottom: 10,
              right: 10,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('Button'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
