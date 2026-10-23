import 'package:flutter/material.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/JobsFlutterTools/JobsSafeArea/JobsSmartSafeArea.dart';

/// 不应该在 main() 中用 SafeArea
/// 每个页面视图结构中合理包裹 SafeArea，并根据情况启用 top、bottom
/// SafeArea 可嵌套，已消费的边由 MediaQuery 自动清零，不按祖先类型跳过其余边。
/// Scaffold 负责键盘避让，SafeArea 负责剩余系统 UI 安全区。
/// ⚠️ 不能代替键盘避让机制：SafeArea 只考虑系统 UI（如状态栏、刘海、底部 Home 指示器等），不负责键盘避让
/// ⚠️ 对 Dialog/Overlay 等不是在根节点渲染的内容无效
/// ⚠️ CupertinoPageScaffold 自带 SafeArea 行为，但自定义页面仍需要手动处理。
/// ⚠️ 与 AppBar 共用时应只作用于 body,否则会让 AppBar 有额外顶部边距，一般只包裹 Scaffold.body 即可。
/// 参考🤔：https://docs.flutter.dev/ui/adaptive-responsive/safearea-mediaquery
/// 参考🤔：https://docs.flutter.dev/ui/layout

class JobsSafeArea extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? bottomNavigationBar;
  final FloatingActionButton? floatingActionButton;
  final Color? backgroundColor;
  final bool resizeToAvoidBottomInset;

  const JobsSafeArea({
    super.key,
    this.appBar,
    required this.body,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.backgroundColor,
    this.resizeToAvoidBottomInset = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      appBar: appBar,
      body: JobsSmartSafeArea(child: body),
      bottomNavigationBar: bottomNavigationBar == null
          ? null
          : JobsSmartSafeArea(top: false, child: bottomNavigationBar!),
      floatingActionButton: floatingActionButton,
    );
  }
}
