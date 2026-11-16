import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

// // =============== 示例用法 1：点击/双击/长按 =================
// Center(
//   child: Text(
//     '点我试试（Tap / DoubleTap / LongPress）',
//     style: const TextStyle(color: Colors.white),
//   )
//       .padding(const EdgeInsets.symmetric(
//           horizontal: 16, vertical: 12))
//       .backgroundColor(Colors.blueAccent)
//       .radius(12)
//       // 语法糖：点击
//       .onTap(() => _setLog('👆 onTap'))
//       // 语法糖：双击
//       .onDoubleTap(() => _setLog('👆👆 onDoubleTap'))
//       // 语法糖：长按
//       .onLongPress(() => _setLog('✋ onLongPress'))
// ),

// =============== 示例用法 2：自由拖拽（Pan 系列） =================
// Positioned(
//   left: _pos.dx,
//   top: _pos.dy,
//   child: Container(
//     width: 120,
//     height: 120,
//     alignment: Alignment.center,
//     decoration: BoxDecoration(
//       color: Colors.redAccent,
//       borderRadius: BorderRadius.circular(16),
//     ),
//     child: const Text(
//       '拖我（Pan）',
//       style: TextStyle(color: Colors.white),
//     ),
//   ).onPan(
//     start: (d) => _setLog('🧲 panStart: ${d.globalPosition}'),
//     update: (d) {
//       setState(() => _pos += d.delta);
//       _setLog('📦 panUpdate: Δ=${d.delta}');
//     },
//     end: (d) => _setLog('🏁 panEnd: v=${d.velocity.pixelsPerSecond}'),
//   ),
// ),

// =============== 示例用法 3：缩放+平移（仅 Scale 系列） =================
// 注意：使用 onScale* 后，你的扩展会自动禁用 Pan 系列，避免冲突。
// Positioned.fill(
//   child: Transform.translate(
//     offset: _canvasOffset,
//     child: Transform.scale(
//       scale: _scale,
//       alignment: Alignment.center,
//       child: Container(
//         width: 160,
//         height: 160,
//         alignment: Alignment.center,
//         decoration: BoxDecoration(
//           color: Colors.teal,
//           borderRadius: BorderRadius.circular(20),
//         ),
//         child: const Text(
//           '捏合缩放 / 两指拖动画布\n(Scale 系列)',
//           textAlign: TextAlign.center,
//           style: TextStyle(color: Colors.white),
//         ),
//       )
//           // 语法糖：Scale（含平移：用 focalPointDelta 实现）
//           .onScale(
//         start: (details) {
//           _scaleStart = _scale;
//           _setLog('🔍 scaleStart: f=${details.focalPoint}');
//         },
//         update: (details) {
//           // 缩放
//           final newScale =
//               (_scaleStart * details.scale).clamp(0.5, 3.0);
//           // 平移（两指拖动时 focalPointDelta 生效；单指也会有）
//           final delta = details.focalPointDelta;

//           setState(() {
//             _scale = newScale;
//             _canvasOffset += delta;
//           });

//           _setLog(
//               '🔎 scaleUpdate: scale=${newScale.toStringAsFixed(2)} '
//               'Δ=${delta.dx.toStringAsFixed(1)},${delta.dy.toStringAsFixed(1)}');
//         },
//         end: (details) => _setLog('✅ scaleEnd'),
//       ),
//     ),
//   ),
// ),

// ====== （可选）示例用法 4：二级/三级点击（桌面/鼠标有用，移动端通常无效） ======
// Positioned(
//   right: 16,
//   bottom: 16,
//   child: Container(
//     padding:
//         const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//     decoration: BoxDecoration(
//       color: Colors.black87,
//       borderRadius: BorderRadius.circular(8),
//     ),
//     child: const Text(
//       'Secondary / Tertiary Tap\n(鼠标右键/中键)',
//       style: TextStyle(color: Colors.white),
//       textAlign: TextAlign.center,
//     ),
//   ).gestures(
//     // 右键（secondary）、中键（tertiary）在桌面/网页更有意义
//     onSecondaryTapDown: (_) => _setLog('🖱 onSecondaryTapDown'),
//     onSecondaryTap: () => _setLog('🖱 onSecondaryTap'),
//     onTertiaryTapDown: (_) => _setLog('🖱 onTertiaryTapDown'),
//     onTertiaryTapCancel: () => _setLog('🖱 onTertiaryTapCancel'),
//   ),
// ),

/// 🍬语法糖：手势聚合
extension JobsWidgetExtension on Widget {
  Widget gestures({
    Key? key,
    HitTestBehavior? behavior,
    bool excludeFromSemantics = false,
    DragStartBehavior dragStartBehavior = DragStartBehavior.start,

    // ==== Tap ====
    GestureTapDownCallback? onTapDown,
    GestureTapUpCallback? onTapUp,
    GestureTapCallback? onTap,
    GestureTapCancelCallback? onTapCancel,

    // ==== Secondary Tap ====
    GestureTapDownCallback? onSecondaryTapDown,
    GestureTapUpCallback? onSecondaryTapUp,
    GestureTapCallback? onSecondaryTap,
    GestureTapCancelCallback? onSecondaryTapCancel,

    // ==== Tertiary Tap ====
    GestureTapDownCallback? onTertiaryTapDown,
    GestureTapUpCallback? onTertiaryTapUp,
    GestureTapCancelCallback? onTertiaryTapCancel,

    // ==== Double Tap ====
    GestureTapDownCallback? onDoubleTapDown,
    GestureTapCallback? onDoubleTap,
    GestureTapCancelCallback? onDoubleTapCancel,

    // ==== Long Press ====
    GestureLongPressDownCallback? onLongPressDown,
    GestureLongPressCallback? onLongPress,
    GestureLongPressStartCallback? onLongPressStart,
    GestureLongPressMoveUpdateCallback? onLongPressMoveUpdate,
    GestureLongPressUpCallback? onLongPressUp,
    GestureLongPressEndCallback? onLongPressEnd,

    // ==== Pan（自由拖拽）====
    GestureDragStartCallback? onPanStart,
    GestureDragUpdateCallback? onPanUpdate,
    GestureDragEndCallback? onPanEnd,
    GestureDragCancelCallback? onPanCancel,

    // ==== 水平拖拽 ====
    GestureDragStartCallback? onHorizontalDragStart,
    GestureDragUpdateCallback? onHorizontalDragUpdate,
    GestureDragEndCallback? onHorizontalDragEnd,
    GestureDragCancelCallback? onHorizontalDragCancel,

    // ==== 垂直拖拽 ====
    GestureDragStartCallback? onVerticalDragStart,
    GestureDragUpdateCallback? onVerticalDragUpdate,
    GestureDragEndCallback? onVerticalDragEnd,
    GestureDragCancelCallback? onVerticalDragCancel,

    // ==== 缩放（Pan 的超集）====
    GestureScaleStartCallback? onScaleStart,
    GestureScaleUpdateCallback? onScaleUpdate,
    GestureScaleEndCallback? onScaleEnd,
  }) {
    // ==== 🚨 冲突检测：Scale 与 Pan 系列不能同时使用 ====
    final hasScale =
        onScaleStart != null || onScaleUpdate != null || onScaleEnd != null;
    final hasAnyPan =
        onPanStart != null ||
        onPanUpdate != null ||
        onPanEnd != null ||
        onPanCancel != null ||
        onHorizontalDragStart != null ||
        onHorizontalDragUpdate != null ||
        onHorizontalDragEnd != null ||
        onHorizontalDragCancel != null ||
        onVerticalDragStart != null ||
        onVerticalDragUpdate != null ||
        onVerticalDragEnd != null ||
        onVerticalDragCancel != null;

    assert(
      !(hasScale && hasAnyPan),
      '❌ GestureDetector 冲突：Scale 已包含 Pan 功能，不可同时声明。'
      '👉 如果需要拖拽 + 缩放，请仅使用 Scale 系列回调（focalPointDelta 处理平移，scale 处理缩放）。',
    );

    // ==== Release 环境自动屏蔽冲突 ====
    final enablePan = !hasScale;

    return GestureDetector(
      key: key,
      behavior: behavior ?? HitTestBehavior.opaque,
      excludeFromSemantics: excludeFromSemantics,
      dragStartBehavior: dragStartBehavior,

      // Tap
      onTapDown: onTapDown,
      onTapUp: onTapUp,
      onTap: onTap,
      onTapCancel: onTapCancel,

      // Secondary
      onSecondaryTapDown: onSecondaryTapDown,
      onSecondaryTapUp: onSecondaryTapUp,
      onSecondaryTap: onSecondaryTap,
      onSecondaryTapCancel: onSecondaryTapCancel,

      // Tertiary
      onTertiaryTapDown: onTertiaryTapDown,
      onTertiaryTapUp: onTertiaryTapUp,
      onTertiaryTapCancel: onTertiaryTapCancel,

      // Double Tap
      onDoubleTapDown: onDoubleTapDown,
      onDoubleTap: onDoubleTap,
      onDoubleTapCancel: onDoubleTapCancel,

      // Long Press
      onLongPressDown: onLongPressDown,
      onLongPress: onLongPress,
      onLongPressStart: onLongPressStart,
      onLongPressMoveUpdate: onLongPressMoveUpdate,
      onLongPressUp: onLongPressUp,
      onLongPressEnd: onLongPressEnd,

      // Pan / Drag（仅当未使用 Scale 时才生效）
      onPanStart: enablePan ? onPanStart : null,
      onPanUpdate: enablePan ? onPanUpdate : null,
      onPanEnd: enablePan ? onPanEnd : null,
      onPanCancel: enablePan ? onPanCancel : null,

      onHorizontalDragStart: enablePan ? onHorizontalDragStart : null,
      onHorizontalDragUpdate: enablePan ? onHorizontalDragUpdate : null,
      onHorizontalDragEnd: enablePan ? onHorizontalDragEnd : null,
      onHorizontalDragCancel: enablePan ? onHorizontalDragCancel : null,

      onVerticalDragStart: enablePan ? onVerticalDragStart : null,
      onVerticalDragUpdate: enablePan ? onVerticalDragUpdate : null,
      onVerticalDragEnd: enablePan ? onVerticalDragEnd : null,
      onVerticalDragCancel: enablePan ? onVerticalDragCancel : null,

      // Scale
      onScaleStart: onScaleStart,
      onScaleUpdate: onScaleUpdate,
      onScaleEnd: onScaleEnd,

      child: this,
    );
  }

  // ==================== 🎯 常用手势语法糖 ====================
  Widget onTap(
    GestureTapCallback? fn, {
    HitTestBehavior behavior = HitTestBehavior.opaque,
  }) => gestures(onTap: fn, behavior: behavior);

  Widget onDoubleTap(
    GestureTapCallback? fn, {
    HitTestBehavior behavior = HitTestBehavior.opaque,
  }) => gestures(onDoubleTap: fn, behavior: behavior);

  Widget onLongPress(
    GestureLongPressCallback? fn, {
    HitTestBehavior behavior = HitTestBehavior.opaque,
  }) => gestures(onLongPress: fn, behavior: behavior);

  Widget onPan({
    GestureDragStartCallback? start,
    GestureDragUpdateCallback? update,
    GestureDragEndCallback? end,
    GestureDragCancelCallback? cancel,
    HitTestBehavior behavior = HitTestBehavior.opaque,
  }) => gestures(
    onPanStart: start,
    onPanUpdate: update,
    onPanEnd: end,
    onPanCancel: cancel,
    behavior: behavior,
  );

  Widget onHorizontalDrag({
    GestureDragStartCallback? start,
    GestureDragUpdateCallback? update,
    GestureDragEndCallback? end,
    GestureDragCancelCallback? cancel,
    HitTestBehavior behavior = HitTestBehavior.opaque,
  }) => gestures(
    onHorizontalDragStart: start,
    onHorizontalDragUpdate: update,
    onHorizontalDragEnd: end,
    onHorizontalDragCancel: cancel,
    behavior: behavior,
  );

  Widget onVerticalDrag({
    GestureDragStartCallback? start,
    GestureDragUpdateCallback? update,
    GestureDragEndCallback? end,
    GestureDragCancelCallback? cancel,
    HitTestBehavior behavior = HitTestBehavior.opaque,
  }) => gestures(
    onVerticalDragStart: start,
    onVerticalDragUpdate: update,
    onVerticalDragEnd: end,
    onVerticalDragCancel: cancel,
    behavior: behavior,
  );

  Widget onScale({
    GestureScaleStartCallback? start,
    GestureScaleUpdateCallback? update,
    GestureScaleEndCallback? end,
    HitTestBehavior behavior = HitTestBehavior.opaque,
  }) => gestures(
    onScaleStart: start,
    onScaleUpdate: update,
    onScaleEnd: end,
    behavior: behavior,
  );
}
