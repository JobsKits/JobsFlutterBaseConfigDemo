import 'package:flutter/material.dart';
import 'demo_strings.dart';

class JobsSideMenuController extends ChangeNotifier {
  bool _isOpen = false;
  bool get isOpen => _isOpen;
  void open() {
    _isOpen = true;
    notifyListeners();
  }

  void close() {
    _isOpen = false;
    notifyListeners();
  }

  void toggle() => isOpen ? close() : open();
}

/// 从左边缘拖动打开，遮罩、返回键和向左拖动关闭；不抢夺正文横向手势。
class JobsSideMenu extends StatefulWidget {
  const JobsSideMenu({
    super.key,
    required this.controller,
    required this.menu,
    required this.child,
    this.fullWidth = false,
    this.widthFactor = .78,
    this.enabled = true,
  });
  final JobsSideMenuController controller;
  final Widget menu;
  final Widget child;
  final bool fullWidth;
  final double widthFactor;
  final bool enabled;
  @override
  State<JobsSideMenu> createState() => _JobsSideMenuState();
}

class _JobsSideMenuState extends State<JobsSideMenu>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animation = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
  );
  double _width = 1;
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_sync);
    if (widget.controller.isOpen && widget.enabled) _animation.value = 1;
  }

  @override
  void didUpdateWidget(JobsSideMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_sync);
      widget.controller.addListener(_sync);
    }
    _sync();
  }

  void _sync() {
    if (widget.controller.isOpen && widget.enabled) {
      _animation.forward();
    } else {
      _animation.reverse();
    }
  }

  void _drag(DragUpdateDetails details) {
    _animation.value += details.delta.dx / _width;
  }

  void _cancel() {
    if (_animation.value > .5) {
      widget.controller.open();
    } else {
      widget.controller.close();
    }
  }

  void _end(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (velocity > 250 || velocity >= -250 && _animation.value > .5) {
      widget.controller.open();
    } else {
      widget.controller.close();
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_sync);
    _animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      _width = widget.fullWidth
          ? constraints.maxWidth
          : constraints.maxWidth * widget.widthFactor.clamp(.35, .95);
      return AnimatedBuilder(
        animation: _animation,
        builder: (context, _) {
          final progress = Curves.easeOutCubic.transform(_animation.value);
          final visible = _animation.value > 0;
          return PopScope(
            canPop: !visible,
            onPopInvokedWithResult: (didPop, _) {
              if (!didPop) widget.controller.close();
            },
            child: Stack(
              children: [
                ExcludeFocus(
                  excluding: visible,
                  child: ExcludeSemantics(
                    excluding: visible,
                    child: widget.child,
                  ),
                ),
                if (widget.enabled)
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    width: 24,
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onHorizontalDragUpdate: _drag,
                      onHorizontalDragEnd: _end,
                      onHorizontalDragCancel: _cancel,
                    ),
                  ),
                Positioned.fill(
                  child: IgnorePointer(
                    ignoring: !visible,
                    child: GestureDetector(
                      onTap: widget.controller.close,
                      onHorizontalDragUpdate: _drag,
                      onHorizontalDragEnd: _end,
                      onHorizontalDragCancel: _cancel,
                      child: ColoredBox(
                        color: Colors.black.withValues(alpha: .38 * progress),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: -_width * (1 - progress),
                  top: 0,
                  bottom: 0,
                  width: _width,
                  child: IgnorePointer(
                    ignoring: !visible,
                    child: ExcludeSemantics(
                      excluding: !visible,
                      child: GestureDetector(
                        onHorizontalDragUpdate: _drag,
                        onHorizontalDragEnd: _end,
                        onHorizontalDragCancel: _cancel,
                        child: Material(
                          elevation: 12,
                          child: SafeArea(
                            child: Column(
                              children: [
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: IconButton(
                                    tooltip: tr(context, '关闭菜单'),
                                    onPressed: widget.controller.close,
                                    icon: const Icon(Icons.close),
                                  ),
                                ),
                                Expanded(child: widget.menu),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
