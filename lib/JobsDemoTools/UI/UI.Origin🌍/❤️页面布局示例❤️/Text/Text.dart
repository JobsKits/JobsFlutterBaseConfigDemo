import 'package:flutter/material.dart';
import 'package:jobs_runners/jobs_runners.dart'; // 公共测试器路径

// 在 Flutter 中，Text 控件可以通过 softWrap 和 overflow 属性来控制文字超出边界时的行为。
// 如果你想要文字超出边界时换行显示，可以设置 softWrap 为 true。
// 此外，可以通过 maxLines 属性来限制显示的最大行数。

// softWrap: true 确保文本在边界处自动换行。
// maxLines: 3 限制文本显示的最大行数，如果文本超出了这个行数，则会被截断。
// overflow: TextOverflow.ellipsis 确保当文本被截断时，显示省略号。
void main() => runApp(const JobsMaterialRunner(MyApp(), title: 'Text 控件换行示例'));

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          '这是一个很长的文本，如果不设置换行，它将超出边界。通过设置 softWrap 和 maxLines 属性，可以控制文本的显示行为。',
          softWrap: true,
          maxLines: 3, // 可选，限制最大行数
          overflow: TextOverflow.ellipsis, // 当超出最大行数时显示省略号
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
