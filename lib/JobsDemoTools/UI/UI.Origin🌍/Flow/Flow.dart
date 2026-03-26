import 'package:flutter/material.dart';
import 'package:jobs_runners/jobs_runners.dart';

void main() => runApp(const JobsMaterialRunner(FlowApp(), title: 'Flow 示例'));

class FlowApp extends StatelessWidget {
  const FlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Flow(
        delegate: MyFlowDelegate(),
        children: List.generate(10, (i) {
          return Container(
            width: 60,
            height: 40,
            color: Colors.primaries[i % Colors.primaries.length],
            alignment: Alignment.center,
            margin: const EdgeInsets.all(2),
            child: Text('$i', style: const TextStyle(color: Colors.white)),
          );
        }),
      ),
    );
  }
}

class MyFlowDelegate extends FlowDelegate {
  @override
  void paintChildren(FlowPaintingContext context) {
    double x = 0.0, y = 0.0;
    const spacing = 8.0;
    final maxWidth = context.size.width;

    for (int i = 0; i < context.childCount; i++) {
      final size = context.getChildSize(i)!;
      if (x + size.width > maxWidth) {
        x = 0;
        y += size.height + spacing;
      }
      context.paintChild(i, transform: Matrix4.translationValues(x, y, 0));
      x += size.width + spacing;
    }
  }

  @override
  Size getSize(BoxConstraints constraints) => Size(constraints.maxWidth, 200);

  @override
  bool shouldRepaint(covariant FlowDelegate oldDelegate) => false;
}
