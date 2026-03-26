import 'package:flutter/material.dart';
import 'package:jobs_runners/jobs_runners.dart'; // 公共测试器路径

// FlexibleWrapDemo: 展示 Row 包含一个图标和一个会换行的文本的示例小部件。
// Row: 主容器，包含一个 Icon 和一个 Flexible 小部件。
// Flexible: 允许子小部件（Wrap）在 Row 中扩展和收缩，从而实现文本换行。
// Wrap: 确保文本在超过可用宽度时换行。
// Text: 文本小部件，在必要时换行。
// 这种设置确保了当文本超过屏幕宽度时，文本会自动换行，同时仍然是 Row 布局的一部分。
void main() => runApp(const JobsMaterialRunner(FlexibleWrapDemo(),
    title: 'Flexible + Wrap Demo'));

class FlexibleWrapDemo extends StatelessWidget {
  const FlexibleWrapDemo({super.key});
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
            child: Wrap(
              children: [
                Text(
                  '这是一个长文本，如果超过屏幕宽度，它应该换行显示。文本应该正确换行并完全可见。',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
