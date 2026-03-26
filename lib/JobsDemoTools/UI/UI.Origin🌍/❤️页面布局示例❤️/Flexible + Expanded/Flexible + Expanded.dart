import 'package:flutter/material.dart';
import 'package:jobs_runners/jobs_runners.dart'; // 公共测试器路径

// Expanded 不能直接嵌套在 Flexible 中使用
// Expanded 本身是一个 Flexible
// 所以直接使用 Flexible 和 Expanded 的组合是多余的
void main() =>
    runApp(const JobsMaterialRunner(FlexibleDemo(), title: 'Flexible Demo'));

class FlexibleDemo extends StatelessWidget {
  const FlexibleDemo({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blueAccent),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(Icons.info, size: 24, color: Colors.blueAccent),
          SizedBox(width: 8),
          Flexible(
            child: Text(
              '这是一个长文本，如果超过屏幕宽度，它应该换行显示。文本应该正确换行并完全可见。',
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
