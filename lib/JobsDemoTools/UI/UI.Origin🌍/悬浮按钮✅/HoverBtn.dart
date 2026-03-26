import 'package:flutter/material.dart';
import 'package:jobs_runners/jobs_runners.dart'; // 公共测试器路径

// 1、画一个圆形按钮，初始位置在右下角（具体位置也可以手动设置）
// 2、可以拖动，但有两种模式，可以在代码里面通过bool值进行改变
//     2.1、拖动到任意位置，放手以后这个圆形按钮回到原来的初始位置，中间是有回弹的一个动画的
//     2.2、拖动到任意位置，放手以后，这个按钮就在此刻的位置，不会改变
// 3、点击这个按钮会360度的旋转，再次点击会暂停旋转，再次点击会接着旋转
// 4、长按这个按钮，会出现一个菜单，类似于UITableView，这个菜单会显示在这个页面更加宽阔的区域
// 5、按钮上面有图，图就是一个环形的箭头，以表明显示旋转的方向
void main() => runApp(const JobsMaterialRunner(DraggableButton(),
    title: 'Draggable Button Example'));

class DraggableButton extends StatefulWidget {
  const DraggableButton({super.key});
  @override
  _DraggableButtonState createState() => _DraggableButtonState();
}

class _DraggableButtonState extends State<DraggableButton>
    with SingleTickerProviderStateMixin {
  /// ValueNotifier 就是把一个普通的值变成“可被监听的状态对象”，当你 .value = ... 时，所有监听者都会被通知。
  final ValueNotifier<int> counter = ValueNotifier<int>(0);

  Offset _position = const Offset(300, 600); // 初始位置在右下角
  bool returnToOrigin = true; // 控制是否返回原点
  bool isRotating = false;
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    counter.addListener(() {
      print('counter 变了: ${counter.value}');
    });
    _rotationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    if (!isRotating) {
      _rotationController.stop();
    } else {
      _rotationController.repeat();
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  void _toggleRotation() {
    setState(() {
      if (isRotating) {
        _rotationController.stop();
      } else {
        _rotationController.repeat();
      }
      isRotating = !isRotating;
    });
  }

  void _onDragEnd(DraggableDetails details) {
    /// 将当前 Widget 的 BuildContext 对应的渲染对象（RenderObject）强制转换为 RenderBox，以便获取位置信息和尺寸。
    /// context 不是全局的，必须等UI渲染稳定以后才能拿，一般在点击事件里面拿
    final RenderBox renderBox = context.findRenderObject() as RenderBox;

    /// 把全局坐标（屏幕上的位置）转换成本地坐标（某个 Widget 内部的位置）。
    final Offset localOffset = renderBox.globalToLocal(details.offset);

    /// 每次调用 setState()，都会触发当前 Widget 的 build() 方法重新执行。
    setState(() {
      if (returnToOrigin) {
        _position = const Offset(300, 600); // 回到初始位置
      } else {
        _position = localOffset; // 停留在拖拽的结束位置
      }
    });
  }

  void _showMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView(
          children: List.generate(
            10,
            (index) => ListTile(
              title: Text('Menu Item $index'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    /**
     * Stack 是 Flutter 中的一个布局组件
     * 允许你把多个子 Widget 叠加在一起显示（类似于图层），并通过 Positioned 控制每个子组件的位置。
     * 默认子组件从 左上角开始叠加
     * 后面的 Widget 会覆盖前面的 Widget（顺序很重要）
     * 可以用 Positioned 精确定位子组件
     * 默认 Stack 的大小由第一个子 Widget 决定（也可以设置 fit）

      Stack(
        children: [
            Container(width: 200, height: 200, color: Colors.red),
            Container(width: 100, height: 100, color: Colors.green),
         ],
      )
      /// ❤️
      Stack(
        children: [
          Container(width: 300, height: 300, color: Colors.grey),
          Positioned(
            top: 50,
            left: 50,
            child: Container(width: 100, height: 100, color: Colors.blue),
          ),
        ],
      )
     */
    return Stack(
      children: [
        Positioned(
          left: _position.dx,
          top: _position.dy,
          child: GestureDetector(
            onLongPress: _showMenu,
            child: Draggable(
              feedback: _buildButton(),
              childWhenDragging: Container(),
              onDragEnd: _onDragEnd,
              child: _buildButton(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildButton() {
    return GestureDetector(
      onTap: _toggleRotation,
      child: RotationTransition(
        /// turns 是一个 动画值（Animation<double>），表示组件要旋转的角度，它不是直接的角度值，而是一个 “圈数”（turn）。
        /// turns = 1.0 表示旋转一整圈（360°）
        /// turns = 0.5 表示旋转半圈（180°）
        /// turns = 2.0 表示旋转两圈（720°）
        turns: _rotationController,

        /// 因为_rotationController是运行时的变量，所以RotationTransition前面不能加const
        child: Container(
          width: 60,
          height: 60,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blue,
          ),
          child: const Center(
            child: Icon(
              Icons.refresh,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
