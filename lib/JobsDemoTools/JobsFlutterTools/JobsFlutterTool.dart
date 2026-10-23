import 'dart:ui' show FlutterView;
import 'package:flutter/material.dart';

/// 在已挂载页面注册，在 dispose 调用返回的取消函数；布局本身使用 MediaQuery/LayoutBuilder。
VoidCallback JobsScreenListener(BuildContext context) {
  final observer = _JobsScreenObserver(View.of(context));
  WidgetsBinding.instance.addObserver(observer);
  return () => WidgetsBinding.instance.removeObserver(observer);
}

class _JobsScreenObserver with WidgetsBindingObserver {
  _JobsScreenObserver(this.view);

  final FlutterView view;

  @override
  void didChangeMetrics() {
    final size = view.physicalSize / view.devicePixelRatio;
    debugPrint('屏幕变化了: ${size.width} x ${size.height}');
  }
}
