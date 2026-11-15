import 'package:flutter/material.dart';

/// ✅ 封装：生命周期监听通用基类
abstract class BaseLifecycleStatefulWidget extends StatefulWidget {
  const BaseLifecycleStatefulWidget({super.key});
}

abstract class BaseLifecycleStatefulWidgetState<
  T extends BaseLifecycleStatefulWidget
>
    extends State<T>
    with WidgetsBindingObserver {
  AppLifecycleState? _lastState;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// ✅ 原始生命周期变化回调
  @protected
  void onAppLifecycleChanged(AppLifecycleState state) {}

  /// ✅ 子类可 override：进入前台
  @protected
  void onAppResumed() {}

  /// ✅ 子类可 override：进入后台
  @protected
  void onAppPaused() {}

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 分发状态给子类
    onAppLifecycleChanged(state);

    // 处理常用事件分发
    if (_lastState != state) {
      switch (state) {
        case AppLifecycleState.resumed:
          onAppResumed();
          break;
        case AppLifecycleState.paused:
          onAppPaused();
          break;
        default:
          break;
      }
    }

    _lastState = state;
  }
}
