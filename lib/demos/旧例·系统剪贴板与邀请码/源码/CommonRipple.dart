import 'package:flutter/material.dart';

/// 通用点击组件：
/// - ripple=true 走 Material+InkWell（有水波纹）
/// - ripple=false 走 GestureDetector（零视觉反馈）
/// - 支持 behavior（点击区域扩展）与 onPanUpdate（拖动手势）
/// - 可自定义圆角与水波纹/高亮颜色（不传则走 Theme）
class CommonRipple extends StatelessWidget {
  final Widget child; // 显示内容
  final GestureTapCallback? onTap; // 点击
  final GestureTapCallback? onDoubleTap; // 双击
  final GestureLongPressCallback? onLongPress; // 长按
  final GestureDragUpdateCallback? onPanUpdate; // 拖动
  final HitTestBehavior behavior; // 命中策略（默认 Opaque 扩大可点区域）
  final BorderRadius borderRadius; // 圆角
  final bool ripple; // 是否显示水波纹
  final Color? splashColor; // 水波纹颜色（ripple=true 时生效）
  final Color? highlightColor; // 高亮颜色（ripple=true 时生效）

  const CommonRipple({
    super.key,
    required this.child,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.onPanUpdate,
    this.behavior = HitTestBehavior.opaque,
    this.borderRadius = BorderRadius.zero,
    this.ripple = true,
    this.splashColor, // 不传走 Theme；传 Colors.transparent 可“隐形水波纹”
    this.highlightColor, // 同上
  });

  @override
  Widget build(BuildContext context) {
    if (!ripple) {
      // 纯手势，无任何视觉反馈
      return GestureDetector(
        behavior: behavior,
        onTap: onTap,
        onDoubleTap: onDoubleTap,
        onLongPress: onLongPress,
        onPanUpdate: onPanUpdate,
        child: child,
      );
    }

    // 有水波纹：InkWell 负责点击反馈；外层 GestureDetector 只负责拖动（不抢 tap）
    final ink = Material(
      color: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
      child: InkWell(
        onTap: onTap,
        onDoubleTap: onDoubleTap,
        onLongPress: onLongPress,
        borderRadius: borderRadius,
        splashColor: splashColor,
        highlightColor: highlightColor,
        child: child,
      ),
    );

    // 仅当需要拖动时才包一层，避免不必要的手势竞争
    if (onPanUpdate == null && behavior == HitTestBehavior.opaque) {
      return ink;
    }
    return GestureDetector(
      behavior: behavior,
      // 这里只放拖动相关，避免与 InkWell 抢 tap/longPress
      onPanUpdate: onPanUpdate,
      child: ink,
    );
  }
}

/**
  用法示例
  // 1) 有水波纹（主题色），并限制在圆角内
  CommonRipple(
    borderRadius: BorderRadius.circular(16),
    onTap: () => print('tap'),
    child: Container(height: 48, alignment: Alignment.center, child: Text('Go')),
  );

  // 2) 有水波纹，但“隐形反馈”（不想看到涟漪/高亮）
  CommonRipple(
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    onTap: () {},
    child: const Icon(Icons.play_arrow),
  );

  // 3) 无水波纹，行为为 Opaque 扩大可点区域，同时支持拖动
  CommonRipple(
    ripple: false,
    behavior: HitTestBehavior.opaque,
    onPanUpdate: (d) => print('dx=${d.delta.dx}, dy=${d.delta.dy}'),
    child: const SizedBox(width: 200, height: 40, child: Text('Drag me')),
  );
 */
