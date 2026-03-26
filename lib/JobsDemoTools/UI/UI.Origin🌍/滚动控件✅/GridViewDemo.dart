import 'package:flutter/material.dart';
import 'package:jobs_runners/jobs_runners.dart'; // 公共测试器路径

// GridView使用演示
// 真机运行如果出现空白页面的解决方案：
// 方案1、在工程根目录下执行 flutter run --release 或者
// 方案2、通过 flutter devices 拿到设备id，然后 flutter run -d 设备ID
void main() =>
    runApp(const JobsMaterialRunner(GridViewDemo(), title: 'GridView Demo'));

class GridViewDemo extends StatelessWidget {
  const GridViewDemo({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GridView Demo'),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        children: List.generate(
          20,
          (index) => GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailPage(itemIndex: index),
                ),
              );
            },
            child: Container(
              color: Colors.teal[100 * (index % 9)],
              child: Center(
                child: Text('Item $index'),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DetailPage extends StatelessWidget {
  final int itemIndex;
  const DetailPage({super.key, required this.itemIndex});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Page - Item $itemIndex'),
      ),
      body: Center(
        child: Text('Detail Page - Item $itemIndex'),
      ),
    );
  }
}
