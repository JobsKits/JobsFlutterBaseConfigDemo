import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/Utils/Extensions/AnyExtensions/onNum.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/Utils/JobsBtnImageSpec.dart';

/// 基础 Widget 扩展（轻量包装）
extension JobsWidgetExtensions on Widget {
  Widget builder(Widget Function(BuildContext ctx, Widget child) build,
      {Key? key}) {
    final child = this;
    return Builder(key: key, builder: (ctx) => build(ctx, child));
  }

  Widget container({
    Key? key,
    AlignmentGeometry? alignment,
    EdgeInsetsGeometry? padding,
    Color? color,
    Decoration? decoration,
    Decoration? foregroundDecoration,
    double? width,
    double? height,
    BoxConstraints? constraints,
    EdgeInsetsGeometry? margin,
    Matrix4? transform,
    AlignmentGeometry? transformAlignment,
    Clip clipBehavior = Clip.none,
  }) =>
      Container(
        key: key,
        alignment: alignment,
        padding: padding,
        color: color,
        decoration: decoration,
        foregroundDecoration: foregroundDecoration,
        width: width,
        height: height,
        constraints: constraints,
        margin: margin,
        transform: transform,
        transformAlignment: transformAlignment,
        clipBehavior: clipBehavior,
        child: this,
      );

  Widget expanded({Key? key, int flex = 1}) =>
      Expanded(key: key, flex: flex, child: this);

  Widget center({Key? key, double? widthFactor, double? heightFactor}) =>
      Center(
          key: key,
          widthFactor: widthFactor,
          heightFactor: heightFactor,
          child: this);

  Widget align(AlignmentGeometry alignment,
          {Key? key, double? widthFactor, double? heightFactor}) =>
      Align(
          key: key,
          alignment: alignment,
          widthFactor: widthFactor,
          heightFactor: heightFactor,
          child: this);

  Widget padding(EdgeInsetsGeometry padding, {Key? key}) =>
      Padding(key: key, padding: padding, child: this);

  Widget clipRRect(double? borderRadius,
          {Key? key,
          CustomClipper<RRect>? clipper,
          Clip clipBehavior = Clip.antiAlias}) =>
      ClipRRect(
          key: key,
          borderRadius: (borderRadius ?? 0).br,
          clipper: clipper,
          clipBehavior: clipBehavior,
          child: this);

  Widget size({double? width, double? height, Key? key}) =>
      SizedBox(key: key, width: width, height: height, child: this);

  Widget infinity() =>
      SizedBox(width: double.infinity, height: double.infinity, child: this);

  Widget tooltip(
    String? message, {
    Key? key,
    InlineSpan? richMessage,
    double? height,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double? verticalOffset,
    bool? preferBelow,
    bool? excludeFromSemantics,
    Decoration? decoration,
    TextStyle? textStyle,
    TextAlign? textAlign,
    Duration? waitDuration,
    Duration? showDuration,
    Duration? exitDuration,
    bool enableTapToDismiss = true,
    TooltipTriggerMode? triggerMode,
    bool? enableFeedback,
    TooltipTriggeredCallback? onTriggered,
  }) =>
      Tooltip(
        key: key,
        message: message ?? '暂无数据'.tr,
        richMessage: richMessage,
        constraints: height == null ? null : BoxConstraints(minHeight: height),
        padding: padding,
        margin: margin,
        verticalOffset: verticalOffset,
        preferBelow: preferBelow,
        excludeFromSemantics: excludeFromSemantics,
        decoration: decoration,
        textStyle: textStyle,
        textAlign: textAlign,
        waitDuration: waitDuration,
        showDuration: showDuration,
        exitDuration: exitDuration,
        enableTapToDismiss: enableTapToDismiss,
        triggerMode: triggerMode,
        enableFeedback: enableFeedback,
        onTriggered: onTriggered,
        child: this,
      );

  Widget opacity(double opacity,
          {Key? key, bool alwaysIncludeSemantics = false}) =>
      Opacity(
          key: key,
          opacity: opacity,
          alwaysIncludeSemantics: alwaysIncludeSemantics,
          child: this);

  Widget hero(
    Object tag, {
    Key? key,
    CreateRectTween? createRectTween,
    HeroFlightShuttleBuilder? flightShuttleBuilder,
    HeroPlaceholderBuilder? placeholderBuilder,
    bool? transitionOnUserGestures,
  }) =>
      Hero(
        key: key,
        tag: tag,
        createRectTween: createRectTween,
        flightShuttleBuilder: flightShuttleBuilder,
        placeholderBuilder: placeholderBuilder,
        transitionOnUserGestures: (transitionOnUserGestures ?? false),
        child: this,
      );

  Widget clipOval(
          {Key? key,
          CustomClipper<Rect>? clipper,
          Clip clipBehavior = Clip.antiAlias}) =>
      ClipOval(
          key: key, clipper: clipper, clipBehavior: clipBehavior, child: this);

  Widget safeArea({
    Key? key,
    bool left = true,
    bool top = true,
    bool right = true,
    bool bottom = true,
    EdgeInsets minimum = EdgeInsets.zero,
    bool maintainBottomViewPadding = false,
  }) =>
      SafeArea(
        key: key,
        left: left,
        top: top,
        right: right,
        bottom: bottom,
        minimum: minimum,
        maintainBottomViewPadding: maintainBottomViewPadding,
        child: this,
      );

  Widget scrollable({
    Key? key,
    Axis scrollDirection = Axis.vertical,
    bool reverse = false,
    EdgeInsetsGeometry? padding,
    bool? primary,
    ScrollPhysics? physics,
    ScrollController? controller,
    DragStartBehavior dragStartBehavior = DragStartBehavior.start,
    Clip clipBehavior = Clip.hardEdge,
    HitTestBehavior hitTestBehavior = HitTestBehavior.opaque,
    String? restorationId,
    ScrollViewKeyboardDismissBehavior keyboardDismissBehavior =
        ScrollViewKeyboardDismissBehavior.manual,
  }) =>
      SingleChildScrollView(
        key: key,
        scrollDirection: scrollDirection,
        reverse: reverse,
        padding: padding,
        primary: primary,
        physics: physics,
        controller: controller,
        dragStartBehavior: dragStartBehavior,
        clipBehavior: clipBehavior,
        restorationId: restorationId,
        keyboardDismissBehavior: keyboardDismissBehavior,
        child: this,
      );

  /// 等到 Future 完成后再把 DecorationImage 合进来；未完成时返回原始 child
  Widget bgImageFutureBy(Future<DecorationImage> future) {
    final child = this;
    return FutureBuilder<DecorationImage>(
      future: future,
      builder: (ctx, snap) {
        if (snap.hasData) {
          return child.bgImageBy(snap.data!);
        }
        return child; // 加载中就先正常显示，不阻塞
      },
    );
  }
}

extension ClipRRectExtensions on Widget {
  Widget clipRRectRadius([double r = 8.0]) => clipRRect(r);
}

extension AlignExtensions on Widget {
  Widget alignLeft({Key? key}) =>
      Align(key: key, alignment: Alignment.centerLeft, child: this);
  Widget alignRight({Key? key}) =>
      Align(key: key, alignment: Alignment.centerRight, child: this);
  Widget alignTop({Key? key}) =>
      Align(key: key, alignment: Alignment.topCenter, child: this);
  Widget alignBottom({Key? key}) =>
      Align(key: key, alignment: Alignment.bottomCenter, child: this);
}

extension JobsBtnConfig on Widget {
  Widget imageBy(JobsBtnLabelConfig cfg) => JobsBtnLabel(label: this, cfg: cfg);
}

/// 样式累积入口（链式 API）
extension JobsStyleX on Widget {
  JobsStyled get style =>
      this is JobsStyled ? (this as JobsStyled) : JobsStyled(child: this);

  JobsStyled paddingBy(EdgeInsetsGeometry v) => style.paddingBy(v);
  JobsStyled marginBy(EdgeInsetsGeometry v) => style.marginBy(v);

  JobsStyled sizeBy({double? width, double? height}) =>
      style.sizeBy(width: width, height: height);

  JobsStyled bgCorBy(Color c) => style.bgCorBy(c);
  JobsStyled bgCorByInt(int c) => style.bgCorBy(Color(c));

  JobsStyled bgImageBy(DecorationImage img) => style.bgImageBy(img);
  JobsStyled gradientBy(Gradient g) => style.gradientBy(g);

  JobsStyled radiusBy(double r) => style.radiusBy(r);
  JobsStyled radiusOnlyBy(
          {double? topLeft,
          double? topRight,
          double? bottomLeft,
          double? bottomRight}) =>
      style.radiusOnlyBy(
          topLeft: topLeft,
          topRight: topRight,
          bottomLeft: bottomLeft,
          bottomRight: bottomRight);

  JobsStyled borderBy(
          {Color color = const Color(0x1F000000),
          double width = 1,
          BorderStyle borderStyle = BorderStyle.solid}) =>
      style.borderBy(color: color, width: width, borderStyle: borderStyle);

  JobsStyled borderOnlyBy({
    Color? leftColor,
    double? leftWidth,
    BorderStyle? leftStyle,
    Color? topColor,
    double? topWidth,
    BorderStyle? topStyle,
    Color? rightColor,
    double? rightWidth,
    BorderStyle? rightStyle,
    Color? bottomColor,
    double? bottomWidth,
    BorderStyle? bottomStyle,
  }) =>
      style.borderOnlyBy(
        leftColor: leftColor,
        leftWidth: leftWidth,
        leftStyle: leftStyle,
        topColor: topColor,
        topWidth: topWidth,
        topStyle: topStyle,
        rightColor: rightColor,
        rightWidth: rightWidth,
        rightStyle: rightStyle,
        bottomColor: bottomColor,
        bottomWidth: bottomWidth,
        bottomStyle: bottomStyle,
      );

  JobsStyled shadowBy({List<BoxShadow>? shadows}) =>
      style.shadowBy(shadows: shadows);
  JobsStyled clipBy([bool v = true]) => style.clipBy(v);
}

/// 可累积样式包装实现
/// 将配置项以属性的方式暴露给调用者，调用者可以链式调用，最终生成一个 Widget
class JobsStyled extends StatelessWidget {
  final Widget child;

  final EdgeInsetsGeometry? _padding;
  final EdgeInsetsGeometry? _margin;
  final BoxDecoration? _decoration;
  final bool _clipContent;
  final double? _width;
  final double? _height;

  const JobsStyled({
    super.key,
    required this.child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    BoxDecoration? decoration,
    bool clipContent = false,
    double? width,
    double? height,
  })  : _padding = padding,
        _margin = margin,
        _decoration = decoration,
        _clipContent = clipContent,
        _width = width,
        _height = height;

  // 合并装饰
  BoxDecoration _mergeDecoration(BoxDecoration? a, BoxDecoration? b) {
    if (a == null) return b ?? const BoxDecoration();
    if (b == null) return a;
    return BoxDecoration(
      color: b.color ?? a.color,
      gradient: b.gradient ?? a.gradient,
      image: b.image ?? a.image,
      border: b.border ?? a.border,
      borderRadius: b.borderRadius ?? a.borderRadius,
      boxShadow: [...(a.boxShadow ?? const []), ...(b.boxShadow ?? const [])],
      shape: b.shape != BoxShape.rectangle ? b.shape : a.shape,
      backgroundBlendMode: b.backgroundBlendMode ?? a.backgroundBlendMode,
    );
  }

  // —— 下面所有链式方法都透传 _width/_height，保证顺序无关 —— //
  JobsStyled sizeBy({double? width, double? height}) => JobsStyled(
        padding: _padding,
        margin: _margin,
        decoration: _decoration,
        clipContent: _clipContent,
        width: width ?? _width,
        height: height ?? _height,
        child: child,
      );

  JobsStyled paddingBy(EdgeInsetsGeometry v) => JobsStyled(
        padding: v,
        margin: _margin,
        decoration: _decoration,
        clipContent: _clipContent,
        width: _width,
        height: _height,
        child: child,
      );

  JobsStyled marginBy(EdgeInsetsGeometry v) => JobsStyled(
        padding: _padding,
        margin: v,
        decoration: _decoration,
        clipContent: _clipContent,
        width: _width,
        height: _height,
        child: child,
      );

  JobsStyled bgImageBy(DecorationImage img) => JobsStyled(
        padding: _padding,
        margin: _margin,
        decoration: _mergeDecoration(_decoration, BoxDecoration(image: img)),
        clipContent: _clipContent,
        width: _width,
        height: _height,
        child: child,
      );

  JobsStyled bgCorBy(Color c) => JobsStyled(
        padding: _padding,
        margin: _margin,
        decoration: _mergeDecoration(_decoration, BoxDecoration(color: c)),
        clipContent: _clipContent,
        width: _width,
        height: _height,
        child: child,
      );

  JobsStyled radiusBy(double r) => JobsStyled(
        padding: _padding,
        margin: _margin,
        decoration: _mergeDecoration(
            _decoration, BoxDecoration(borderRadius: BorderRadius.circular(r))),
        clipContent: true,
        width: _width,
        height: _height,
        child: child,
      );

  JobsStyled radiusOnlyBy(
      {double? topLeft,
      double? topRight,
      double? bottomLeft,
      double? bottomRight}) {
    final br = BorderRadius.only(
      topLeft: (topLeft ?? 0).radius,
      topRight: (topRight ?? 0).radius,
      bottomLeft: (bottomLeft ?? 0).radius,
      bottomRight: (bottomRight ?? 0).radius,
    );
    return JobsStyled(
      padding: _padding,
      margin: _margin,
      decoration:
          _mergeDecoration(_decoration, BoxDecoration(borderRadius: br)),
      clipContent: true,
      width: _width,
      height: _height,
      child: child,
    );
  }

  JobsStyled borderBy(
          {Color color = const Color(0x1F000000),
          double width = 1,
          BorderStyle borderStyle = BorderStyle.solid}) =>
      JobsStyled(
        padding: _padding,
        margin: _margin,
        decoration: _mergeDecoration(
            _decoration,
            BoxDecoration(
                border: Border.all(
                    color: color, width: width, style: borderStyle))),
        clipContent: _clipContent,
        width: _width,
        height: _height,
        child: child,
      );

  JobsStyled borderOnlyBy({
    Color? leftColor,
    double? leftWidth,
    BorderStyle? leftStyle,
    Color? topColor,
    double? topWidth,
    BorderStyle? topStyle,
    Color? rightColor,
    double? rightWidth,
    BorderStyle? rightStyle,
    Color? bottomColor,
    double? bottomWidth,
    BorderStyle? bottomStyle,
  }) {
    BorderSide? mk(Color? c, double? w, BorderStyle? s) =>
        (c == null && w == null && s == null)
            ? null
            : BorderSide(
                color: c ?? const Color(0x1F000000),
                width: w ?? 1,
                style: s ?? BorderStyle.solid);

    final only = Border(
      left: mk(leftColor, leftWidth, leftStyle) ?? BorderSide.none,
      top: mk(topColor, topWidth, topStyle) ?? BorderSide.none,
      right: mk(rightColor, rightWidth, rightStyle) ?? BorderSide.none,
      bottom: mk(bottomColor, bottomWidth, bottomStyle) ?? BorderSide.none,
    );

    final mergedBorder = () {
      final exist = (_decoration?.border as Border?);
      if (exist == null) return only;
      BorderSide pick(BorderSide a, BorderSide b) =>
          (b.style != BorderStyle.none || b.width != 0) ? b : a;
      return Border(
        left: pick(exist.left, only.left),
        top: pick(exist.top, only.top),
        right: pick(exist.right, only.right),
        bottom: pick(exist.bottom, only.bottom),
      );
    }();

    return JobsStyled(
      padding: _padding,
      margin: _margin,
      decoration:
          _mergeDecoration(_decoration, BoxDecoration(border: mergedBorder)),
      clipContent: _clipContent,
      width: _width,
      height: _height,
      child: child,
    );
  }

  JobsStyled gradientBy(Gradient g) => JobsStyled(
        padding: _padding,
        margin: _margin,
        decoration: _mergeDecoration(_decoration, BoxDecoration(gradient: g)),
        clipContent: _clipContent,
        width: _width,
        height: _height,
        child: child,
      );

  JobsStyled shadowBy({List<BoxShadow>? shadows}) => JobsStyled(
        padding: _padding,
        margin: _margin,
        decoration: _mergeDecoration(
            _decoration,
            BoxDecoration(
                boxShadow: shadows ??
                    [const BoxShadow(blurRadius: 10, offset: Offset(0, 4))])),
        clipContent: _clipContent,
        width: _width,
        height: _height,
        child: child,
      );

  JobsStyled clipBy([bool v = true]) => JobsStyled(
        padding: _padding,
        margin: _margin,
        decoration: _decoration,
        clipContent: v,
        width: _width,
        height: _height,
        child: child,
      );

  @override
  Widget build(BuildContext context) {
    Widget w = child;

    if (_padding != null) {
      w = Padding(padding: _padding, child: w);
    }

    final dec = _decoration;

    // 先把背景/边框等画出来（放在“里层”）
    if (dec != null) {
      w = DecoratedBox(decoration: dec, child: w);
    }

    // 再决定是否裁剪（放在“外层”），这样背景也会被裁剪
    final br = dec?.borderRadius?.resolve(Directionality.of(context));
    final needClip =
        _clipContent || (dec?.shape == BoxShape.circle) || (br != null);

    if (needClip) {
      if (dec?.shape == BoxShape.circle) {
        w = ClipOval(child: w);
      } else if (br != null) {
        w = ClipRRect(borderRadius: br, child: w);
      }
    }

    if (_margin != null) {
      w = Padding(padding: _margin, child: w);
    }

    if (_width != null || _height != null) {
      w = SizedBox(width: _width, height: _height, child: w);
    }

    return w;
  }
}
