import 'dart:async';
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';
import 'package:jobs_platform_lab/jobs_platform_lab.dart';

class HomeFloatingController extends ChangeNotifier {
  void showDebugEntry() => notifyListeners();
}

/// 首页独占控件；离开首页时停止刷新、动画和独立的摇动监听。
class HomeFloatingControls extends StatefulWidget {
  const HomeFloatingControls({
    super.key,
    required this.child,
    required this.active,
    required this.showClock,
    required this.onClockVisibilityChanged,
    this.controller,
    this.onPress,
    this.onOpenDebug,
    this.onOpenClock,
  });

  final Widget child;
  final bool active;
  final bool showClock;
  final ValueChanged<bool> onClockVisibilityChanged;
  final HomeFloatingController? controller;
  final VoidCallback? onPress;
  final VoidCallback? onOpenDebug;
  final VoidCallback? onOpenClock;

  @override
  State<HomeFloatingControls> createState() => _HomeFloatingControlsState();
}

class _HomeFloatingControlsState extends State<HomeFloatingControls>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late final spin = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  );
  late final fuse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );
  final elapsed = Stopwatch();
  AudioPlayer? audio;
  Timer? ticker;
  StreamSubscription<Map<String, dynamic>>? shake;
  Future<void> shakeCommands = Future<void>.value();
  bool foreground = true;
  bool spinning = true;
  bool debugVisible = false;
  bool holding = false;
  ModalRoute<dynamic>? route;
  Animation<double>? routeAnimation;
  bool get enabled =>
      widget.active &&
      foreground &&
      (route?.isCurrent ?? true) &&
      (routeAnimation?.status ?? AnimationStatus.completed) ==
          AnimationStatus.completed;

  String text(String key) => tr(context, key);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.controller?.addListener(showDebug);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final next = ModalRoute.of(context);
    if (route != next) {
      routeAnimation?.removeStatusListener(routeChanged);
      route = next;
      routeAnimation = next?.animation;
      routeAnimation?.addStatusListener(routeChanged);
    }
    syncActivity();
  }

  void routeChanged(AnimationStatus status) {
    if (!mounted) return;
    syncActivity();
    setState(() {});
  }

  @override
  void didUpdateWidget(HomeFloatingControls oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(showDebug);
      widget.controller?.addListener(showDebug);
    }
    syncActivity();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    foreground = state == AppLifecycleState.resumed;
    syncActivity();
    if (mounted) setState(() {});
  }

  void syncActivity() {
    if (enabled) {
      if (widget.showClock || spinning) {
        ticker ??= Timer.periodic(const Duration(seconds: 1), (_) {
          if (mounted) setState(() {});
        });
      } else {
        ticker?.cancel();
        ticker = null;
      }
      if (spinning) {
        elapsed.start();
        if (!MediaQuery.disableAnimationsOf(context) && !spin.isAnimating) {
          spin.repeat();
        }
      }
      if (MediaQuery.disableAnimationsOf(context)) spin.stop();
      if (JobsPlatformLab.hasNativeBridge && shake == null) {
        shake = JobsPlatformLab.events('shake').listen((_) {
          if (mounted && enabled) showDebug();
        }, onError: (Object _) {});
        queueShake('shake.start');
      }
    } else {
      ticker?.cancel();
      ticker = null;
      elapsed.stop();
      spin.stop();
      stopHolding();
      if (shake != null) {
        unawaited(shake?.cancel());
        shake = null;
        queueShake('shake.stop');
      }
    }
  }

  void queueShake(String method) {
    // 按监听顺序串行，避免快速切页留下迟到的 start。
    shakeCommands = shakeCommands.then((_) async {
      try {
        await JobsPlatformLab.invoke<void>(method);
      } on MissingPluginException {
        // 无传感器平台仍可从设置恢复入口。
      } on PlatformException {
        // 模拟器没有加速度计；保留手动恢复入口。
      }
    });
  }

  void showDebug() {
    if (mounted) setState(() => debugVisible = true);
  }

  void toast(String key) {
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(content: Text(text(key)), duration: const Duration(seconds: 1)),
    );
  }

  void toggleSpin() {
    setState(() => spinning = !spinning);
    if (!spinning) {
      spin.stop();
      elapsed.stop();
    }
    syncActivity();
    unawaited(HapticFeedback.lightImpact());
    toast(spinning ? '继续旋转与计时' : '已暂停旋转与计时');
  }

  Future<void> press() async {
    widget.onPress?.call();
    unawaited(HapticFeedback.lightImpact());
    try {
      audio ??= AudioPlayer();
      await audio!.play(AssetSource('Sounds/spin.mp3'));
    } on Exception {
      // 音频设备不可用时仍保留列表跳转和触觉反馈。
    }
  }

  void stopHolding() {
    holding = false;
    fuse.stop();
    fuse.value = 0;
  }

  void openDebug() {
    if (widget.onOpenDebug case final callback?) {
      callback();
      return;
    }
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        builder: (context) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(title: Text(text('调试工具'))),
              ListTile(
                title: Text(text('悬浮时间')),
                trailing: Switch(
                  value: widget.showClock,
                  onChanged: (value) {
                    widget.onClockVisibilityChanged(value);
                    Navigator.pop(context);
                  },
                ),
              ),
              ListTile(title: Text(text('长按隐藏，摇动手机恢复'))),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    routeAnimation?.removeStatusListener(routeChanged);
    widget.controller?.removeListener(showDebug);
    ticker?.cancel();
    elapsed.stop();
    unawaited(shake?.cancel());
    if (shake != null) queueShake('shake.stop');
    unawaited(audio?.dispose());
    spin.dispose();
    fuse.dispose();
    super.dispose();
  }

  ({Size size, EdgeInsets padding}) clockLayout(Rect area, TextStyle style) {
    if (area.isEmpty) {
      return (size: Size.zero, padding: EdgeInsets.zero);
    }
    final padding = EdgeInsets.symmetric(
      horizontal: math.min(16, area.width / 4),
      vertical: math.min(10, area.height / 4),
    );
    final painter = TextPainter(
      // 预留完整时分秒，避免每秒数字变化牵动控件边界。
      text: TextSpan(text: '${text('当前时间')}\n88:88:88', style: style),
      textAlign: TextAlign.center,
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      locale: Localizations.maybeLocaleOf(context),
      textHeightBehavior: DefaultTextStyle.of(context).textHeightBehavior,
    )..layout();
    final width = math.min(
      area.width,
      (painter.width + padding.horizontal + 2).ceilToDouble(),
    );
    painter.layout(maxWidth: math.max(0, width - padding.horizontal));
    final height = math.min(
      area.height,
      math.max(48.0, (painter.height + padding.vertical).ceilToDouble()),
    );
    painter.dispose();
    return (size: Size(width, height), padding: padding);
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final clock = [
      now.hour,
      now.minute,
      now.second,
    ].map((part) => part.toString().padLeft(2, '0')).join(':');
    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        Positioned.fill(
          child: Offstage(
            offstage: !enabled,
            child: LayoutBuilder(
              builder: (context, bounds) {
                final insets = MediaQuery.paddingOf(context);
                final area = Rect.fromLTRB(
                  8,
                  insets.top + 8,
                  math.max(8, bounds.maxWidth - 8),
                  math.max(
                    insets.top + 8,
                    bounds.maxHeight - insets.bottom - 8,
                  ),
                );
                final clockArea = Rect.fromLTRB(
                  insets.left + 8,
                  area.top,
                  math.max(insets.left + 8, bounds.maxWidth - insets.right - 8),
                  area.bottom,
                );
                final clockStyle = Theme.of(context).textTheme.bodyMedium!
                    .copyWith(
                      inherit: false,
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    );
                final clockGeometry = clockLayout(clockArea, clockStyle);
                return Stack(
                  children: [
                    _Dockable(
                      key: const ValueKey('floating-clock-position'),
                      area: clockArea,
                      size: clockGeometry.size,
                      initial: Offset(clockArea.left + 7, clockArea.top + 64),
                      keepDockedOnResize: true,
                      longPressToDrag: true,
                      onTap: widget.onOpenClock,
                      visible: widget.showClock,
                      child: Semantics(
                        label: text('悬浮时间'),
                        button: true,
                        onTap: widget.onOpenClock,
                        child: Material(
                          key: const ValueKey('floating-clock'),
                          color: const Color(0xff1565c0),
                          borderRadius: BorderRadius.circular(10),
                          child: SingleChildScrollView(
                            primary: false,
                            physics: const ClampingScrollPhysics(),
                            padding: clockGeometry.padding,
                            child: Text(
                              '${text('当前时间')}\n$clock',
                              key: const ValueKey('floating-clock-text'),
                              textAlign: TextAlign.center,
                              textHeightBehavior: DefaultTextStyle.of(context)
                                  .textHeightBehavior,
                              style: clockStyle,
                            ),
                          ),
                        ),
                      ),
                    ),
                    _Dockable(
                      key: const ValueKey('floating-press-position'),
                      area: area,
                      size: const Size(50, 50),
                      initial: Offset(15, area.bottom - 86),
                      child: _FloatingAction(
                        label: text('按'),
                        onTap: () => unawaited(press()),
                        onHold: () {
                          holding = true;
                          fuse.forward(from: 0);
                        },
                        onRelease: stopHolding,
                        child: AnimatedBuilder(
                          animation: fuse,
                          builder: (context, _) => Transform.scale(
                            scale: holding ? 1.18 : 1,
                            child: Material(
                              key: const ValueKey('floating-press'),
                              shape: const CircleBorder(),
                              color: const Color(0xff7b1fa2),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Center(
                                    child: Text(
                                      text('按'),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  if (holding)
                                    Padding(
                                      padding: const EdgeInsets.all(2),
                                      child: CircularProgressIndicator(
                                        value: fuse.value,
                                        color: Colors.white,
                                        backgroundColor: Colors.white24,
                                        strokeWidth: 4,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    _Dockable(
                      key: const ValueKey('floating-spin-position'),
                      area: area,
                      size: const Size(50, 50),
                      initial: Offset(area.right - 58, area.bottom - 86),
                      child: _FloatingAction(
                        label: text(spinning ? '暂停旋转与计时' : '继续旋转与计时'),
                        onTap: toggleSpin,
                        onHold: () => toast('长按了悬浮按钮'),
                        child: RotationTransition(
                          turns: spin,
                          child: Material(
                            key: const ValueKey('floating-spin'),
                            shape: const CircleBorder(),
                            color: const Color(0xffa84600),
                            child: Center(
                              child: Text(
                                '${elapsed.elapsed.inSeconds}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    _Dockable(
                      key: const ValueKey('floating-debug-position'),
                      area: area,
                      size: const Size(50, 50),
                      initial: Offset(area.right - 58, area.center.dy),
                      visible: debugVisible,
                      child: _FloatingAction(
                        label: text('调试工具'),
                        onTap: openDebug,
                        onHold: () {
                          setState(() => debugVisible = false);
                          toast('长按隐藏，摇动手机恢复');
                        },
                        child: Material(
                          key: const ValueKey('floating-debug'),
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          shape: const CircleBorder(),
                          child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: Image.asset(
                              'assets/Images/JobsDebugPanelButton.png',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _FloatingAction extends StatelessWidget {
  const _FloatingAction({
    required this.label,
    required this.child,
    required this.onTap,
    required this.onHold,
    this.onRelease,
  });
  final String label;
  final Widget child;
  final VoidCallback onTap;
  final VoidCallback onHold;
  final VoidCallback? onRelease;

  @override
  Widget build(BuildContext context) => Semantics(
    label: label,
    button: true,
    onTap: onTap,
    onLongPress: onHold,
    child: Tooltip(
      message: label,
      triggerMode: TooltipTriggerMode.manual,
      child: RawGestureDetector(
        gestures: {
          TapGestureRecognizer:
              GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
                TapGestureRecognizer.new,
                (recognizer) => recognizer.onTap = onTap,
              ),
          LongPressGestureRecognizer:
              GestureRecognizerFactoryWithHandlers<LongPressGestureRecognizer>(
                () => LongPressGestureRecognizer(
                  duration: const Duration(milliseconds: 800),
                ),
                (recognizer) {
                  recognizer.onLongPressStart = (_) => onHold();
                  recognizer.onLongPressEnd = (_) => onRelease?.call();
                  recognizer.onLongPressCancel = onRelease;
                },
              ),
        },
        child: child,
      ),
    ),
  );
}

class _Dockable extends StatefulWidget {
  const _Dockable({
    super.key,
    required this.area,
    required this.size,
    required this.initial,
    required this.child,
    this.visible = true,
    this.keepDockedOnResize = false,
    this.longPressToDrag = false,
    this.onTap,
  });
  final Rect area;
  final Size size;
  final Offset initial;
  final Widget child;
  final bool visible;
  final bool keepDockedOnResize;
  final bool longPressToDrag;
  final VoidCallback? onTap;

  @override
  State<_Dockable> createState() => _DockableState();
}

class _DockableState extends State<_Dockable> {
  Offset? position;
  bool? dockedToRight;
  bool? dockedToBottom;
  Offset? holdOrigin;

  @override
  void didUpdateWidget(_Dockable oldWidget) {
    super.didUpdateWidget(oldWidget);
    final previous = position;
    if (!widget.keepDockedOnResize || previous == null) return;
    var next = previous;
    final oldRight = math.max(
      oldWidget.area.left,
      oldWidget.area.right - oldWidget.size.width,
    );
    final oldBottom = math.max(
      oldWidget.area.top,
      oldWidget.area.bottom - oldWidget.size.height,
    );
    final rightDock =
        dockedToRight ??
        ((previous.dx - oldWidget.area.left).abs() < .01
            ? false
            : (previous.dx - oldRight).abs() < .01
            ? true
            : null);
    final bottomDock =
        dockedToBottom ??
        ((previous.dy - oldWidget.area.top).abs() < .01
            ? false
            : (previous.dy - oldBottom).abs() < .01
            ? true
            : null);
    if (rightDock == true) {
      next = Offset(widget.area.right - widget.size.width, next.dy);
    } else if (rightDock == false) {
      next = Offset(widget.area.left, next.dy);
    }
    if (bottomDock == true) {
      next = Offset(next.dx, widget.area.bottom - widget.size.height);
    } else if (bottomDock == false) {
      next = Offset(next.dx, widget.area.top);
    }
    position = confine(next);
  }

  Offset confine(Offset point) => Offset(
    point.dx.clamp(
      widget.area.left,
      math.max(widget.area.left, widget.area.right - widget.size.width),
    ),
    point.dy.clamp(
      widget.area.top,
      math.max(widget.area.top, widget.area.bottom - widget.size.height),
    ),
  );

  void dock() {
    final point = confine(position ?? widget.initial);
    final right = math.max(
      widget.area.left,
      widget.area.right - widget.size.width,
    );
    final bottom = math.max(
      widget.area.top,
      widget.area.bottom - widget.size.height,
    );
    final edges = [
      Offset(widget.area.left, point.dy),
      Offset(right, point.dy),
      Offset(point.dx, widget.area.top),
      Offset(point.dx, bottom),
    ]..sort((a, b) => (a - point).distance.compareTo((b - point).distance));
    setState(() {
      position = edges.first;
      dockedToRight = (position!.dx - right).abs() < .01
          ? true
          : (position!.dx - widget.area.left).abs() < .01
          ? false
          : null;
      dockedToBottom = (position!.dy - bottom).abs() < .01
          ? true
          : (position!.dy - widget.area.top).abs() < .01
          ? false
          : null;
    });
    unawaited(HapticFeedback.lightImpact());
  }

  @override
  Widget build(BuildContext context) {
    final point = confine(position ?? widget.initial);
    return Positioned(
      left: point.dx,
      top: point.dy,
      width: widget.size.width,
      height: widget.size.height,
      child: Visibility(
        visible: widget.visible,
        maintainState: true,
        child: GestureDetector(
          onTap: widget.onTap,
          onLongPressStart: widget.longPressToDrag
              ? (_) {
                  holdOrigin = position ?? widget.initial;
                  dockedToRight = null;
                  dockedToBottom = null;
                  unawaited(HapticFeedback.lightImpact());
                }
              : null,
          onLongPressMoveUpdate: widget.longPressToDrag
              ? (details) {
                  setState(() {
                    position = confine(holdOrigin! + details.offsetFromOrigin);
                  });
                }
              : null,
          onLongPressEnd: widget.longPressToDrag
              ? (_) {
                  holdOrigin = null;
                  dock();
                }
              : null,
          onLongPressCancel: widget.longPressToDrag
              ? () {
                  if (holdOrigin != null) {
                    holdOrigin = null;
                    dock();
                  }
                }
              : null,
          onPanUpdate: widget.longPressToDrag
              ? null
              : (details) => setState(() {
                  dockedToRight = null;
                  dockedToBottom = null;
                  position = confine(
                    (position ?? widget.initial) + details.delta,
                  );
                }),
          onPanEnd: widget.longPressToDrag ? null : (_) => dock(),
          onPanCancel: widget.longPressToDrag ? null : dock,
          child: widget.child,
        ),
      ),
    );
  }
}
