import 'package:flutter/material.dart';
import 'package:jobs_runners/jobs_runners.dart'; // 公共测试器路径

// Flexible 示例: 使用 Flexible 来让 Text 小部件在 Row 中自动换行。
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
