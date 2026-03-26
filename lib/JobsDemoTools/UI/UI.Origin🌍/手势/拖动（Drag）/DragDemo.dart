import 'package:flutter/material.dart';
import 'package:jobs_runners/jobs_runners.dart'; // 公共测试器路径

void main() =>
    runApp(const JobsMaterialRunner(DragDemo(), title: 'Drag Gesture Demo'));

class DragDemo extends StatelessWidget {
  const DragDemo({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onHorizontalDragUpdate: (details) {
          debugPrint('Horizontal drag: ${details.delta.dx}');
        },
        onVerticalDragUpdate: (details) {
          debugPrint('Vertical drag: ${details.delta.dy}');
        },
        onPanUpdate: (details) {
          debugPrint('Pan: ${details.delta}');
        },
        child: Container(
          color: Colors.green,
          width: 100,
          height: 100,
          child: const Center(
              child: Text('Drag Me', style: TextStyle(color: Colors.white))),
        ),
      ),
    );
  }
}
