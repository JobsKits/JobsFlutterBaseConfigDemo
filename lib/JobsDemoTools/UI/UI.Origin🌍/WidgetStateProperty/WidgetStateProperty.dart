import 'package:flutter/material.dart';
import 'package:jobs_runners/jobs_runners.dart';

// WidgetStateProperty 是一个用于根据 widget 的不同状态返回相应值的接口。
// 在 Flutter 中，它可以用于处理 widget 的各种交互状态，如 hover、focus、pressed 等。
// 以下是一个简单的示例，展示如何使用 WidgetStateProperty 来动态改变按钮的背景色。

// 在这个示例中，WidgetStateProperty.resolveWith 方法根据按钮的不同状态返回相应的颜色：

// 如果按钮处于 pressed 状态，背景色为绿色。
// 如果按钮处于 hovered 状态，背景色为蓝色。
// 如果按钮处于 focused 状态，背景色为橙色。
// 否则，背景色为红色。
// WidgetStateProperty 的设计类似于 MaterialStateProperty，用于处理 Material 组件的不同状态​ (Flutter Dev)​​ (Flutter Dev)​。

// 通过这个示例，你可以看到如何使用 WidgetStateProperty 来管理和响应 widget 的不同状态。

// 在 Flutter 中，WidgetState 是一个用于描述 widget 交互状态的枚举。
// WidgetState 枚举
// WidgetState 枚举定义了一些常见的 widget 交互状态​ (Flutter Dev)​：

// hovered：当用户将鼠标光标悬停在 widget 上时的状态。
// focused：当用户通过键盘导航到 widget 上时的状态。
// pressed：当用户正在按下 widget 时的状态。
// dragged：当 widget 被拖动时的状态。
// selected：当项目被选中时的状态（例如单选按钮或复选框）。
// scrolledUnder：当 widget 的内容滚动到其他内容下面时的状态。
// disabled：当 widget 被禁用时的状态。
// error：当 widget 进入某种错误状态时的状态。
void main() => runApp(
    const JobsMaterialRunner(MyApp(), title: 'WidgetStateProperty Demo'));

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: MyStatefulButton(),
    );
  }
}

class MyStatefulButton extends StatefulWidget {
  const MyStatefulButton({super.key});
  @override
  _MyStatefulButtonState createState() => _MyStatefulButtonState();
}

class _MyStatefulButtonState extends State<MyStatefulButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {},
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith<Color>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.pressed)) {
              return Colors.green;
            } else if (states.contains(WidgetState.hovered)) {
              return Colors.blue;
            } else if (states.contains(WidgetState.focused)) {
              return Colors.orange;
            } else {
              return Colors.red;
            }
          },
        ),
      ),
      child: const Text('Press Me'),
    );
  }
}
