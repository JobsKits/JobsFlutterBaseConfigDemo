import 'package:flutter/material.dart';
import 'package:jobs_runners/jobs_runners.dart'; // 公共测试器路径

// main -> MyApp -> MyApp().build -> RotaryView().StatefulWidget.createState() -> _RotaryViewState.State.WidgetsBindingObserver
// _RotaryViewState -> (Widget build(BuildContext context) + initState() + dispose() + didChangeAppLifecycleState())
// StatelessWidget: 没有状态，不能在生命周期中发生变化。

void main() =>
    runApp(const JobsMaterialRunner(RotaryView(), title: 'Rotary View'));

class RotaryView extends StatefulWidget {
  const RotaryView({super.key});

  @override
  _RotaryViewState createState() => _RotaryViewState();
}

class _RotaryViewState extends State<RotaryView> with WidgetsBindingObserver {
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isLoading,
      builder: (context, loading, child) {
        return Center(
          child: loading
              ? const CircularProgressIndicator()
              : const RotaryViewContent(),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    isLoading.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.inactive:
        // 应用程序处于非活动状态
        debugPrint('应用程序处于非活动状态');
        break;
      case AppLifecycleState.paused:
        // 应用程序处于后台
        debugPrint('应用程序处于后台');
        break;
      case AppLifecycleState.resumed:
        // 应用程序处于前台并可交互
        debugPrint('应用程序处于前台并可交互');
        break;
      case AppLifecycleState.detached:
        // 应用程序没有关联的 Flutter 引擎
        debugPrint('应用程序没有关联的 Flutter 引擎');
        break;

      /// Flutter 3.22（Dart 3.3） 之后新增。仅在 iOS 和 Android 上生效
      case AppLifecycleState.hidden:
        // AppLifecycleState.hidden 是 Flutter 中的一个枚举值，它表示应用程序的状态在 iOS 平台上被隐藏时的状态。
        // 具体来说，AppLifecycleState.hidden 是在 iOS 上当用户按下主屏幕按钮或切换到另一个应用程序时，Flutter 应用程序进入后台并且不再可见的状态。
        // 在 Android 平台上没有完全对应的状态。
        // 在 Android 上，当应用程序进入后台时，通常会接收到 AppLifecycleState.paused 状态。
        debugPrint('Handle this case');
    }
    super.didChangeAppLifecycleState(state);
  }
}

class RotaryViewContent extends StatelessWidget {
  const RotaryViewContent({super.key});
  @override
  Widget build(BuildContext context) {
    return const Text('Rotary View Content');
  }
}
