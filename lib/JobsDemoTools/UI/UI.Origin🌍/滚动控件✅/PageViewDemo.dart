import 'package:flutter/material.dart';
import 'package:jobs_runners/jobs_runners.dart'; // 公共测试器路径

// 水平滚动的时候，一格一格的滚动，滚动距离为设备宽度，高度随内容变化；有弹簧效果
// 垂直滚动的时候，一格一格的滚动，滚动距离为设备高度，宽度随内容变化；有弹簧效果

// 真机运行如果出现空白页面的解决方案：
// 方案1、在工程根目录下执行 flutter run --release 或者
// 方案2、通过 flutter devices 拿到设备id，然后 flutter run -d 设备ID
void main() =>
    runApp(const JobsMaterialRunner(PageViewDemo(), title: 'PageView Demo'));

class PageViewDemo extends StatelessWidget {
  const PageViewDemo({super.key});
  @override
  Widget build(BuildContext context) {
    const isVertical = true; // 设置为 true 以垂直滚动
    // const isVertical = false; // 设置为 false 以水平滚动
    return PageView(
      scrollDirection: isVertical ? Axis.vertical : Axis.horizontal,
      pageSnapping: true,
      children: List.generate(
        3,
        (index) => Container(
          width:
              isVertical ? double.infinity : MediaQuery.of(context).size.width,
          height:
              isVertical ? MediaQuery.of(context).size.height : double.infinity,
          color: index % 2 == 0 ? Colors.red : Colors.blue,
          child: Center(
            child: Text('Page ${index + 1}'),
          ),
        ),
      ),
    );
  }
}
