import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';

/// 图标相对文字的位置
enum JobsIconPosition { left, right, top, bottom }

/// 图标尺寸/适配等
class JobsBtnImageSpec {
  final double width;
  final double height;
  final EdgeInsets padding;
  final BoxFit fit;
  const JobsBtnImageSpec({
    this.width = 18,
    this.height = 18,
    this.padding = EdgeInsets.zero,
    this.fit = BoxFit.contain,
  });
}

/// 图标来源（统一抽象：SVG / Asset / Network / IconData / 任意 Widget）
class JobsBtnImageSpecSource {
  final Widget Function(BuildContext, JobsBtnImageSpec) _builder;
  const JobsBtnImageSpecSource._(this._builder);

  // factory JobsBtnImageSpecSource.svgAsset(String asset, {Color? color}) =>
  //     JobsBtnImageSpecSource._((ctx, spec) => Padding(
  //           padding: spec.padding,
  //           child: SvgPicture.asset(
  //             asset,
  //             width: spec.width,
  //             height: spec.height,
  //             fit: spec.fit,
  //             colorFilter: color == null
  //                 ? null
  //                 : ColorFilter.mode(color, BlendMode.srcIn),
  //           ),
  //         ));

  factory JobsBtnImageSpecSource.asset(String asset, {Color? color}) =>
      JobsBtnImageSpecSource._((ctx, spec) => Padding(
            padding: spec.padding,
            child: Image.asset(
              asset,
              width: spec.width,
              height: spec.height,
              fit: spec.fit,
              color: color,
            ),
          ));

  factory JobsBtnImageSpecSource.network(String url, {Color? color}) =>
      JobsBtnImageSpecSource._((ctx, spec) => Padding(
            padding: spec.padding,
            child: Image.network(
              url,
              width: spec.width,
              height: spec.height,
              fit: spec.fit,
              color: color,
            ),
          ));

  factory JobsBtnImageSpecSource.icon(IconData data, {Color? color}) =>
      JobsBtnImageSpecSource._((ctx, spec) => Padding(
            padding: spec.padding,
            child:
                Icon(data, size: (spec.width + spec.height) / 2, color: color),
          ));

  factory JobsBtnImageSpecSource.widget(Widget w) =>
      JobsBtnImageSpecSource._((ctx, spec) => SizedBox(
            width: spec.width,
            height: spec.height,
            child: Padding(padding: spec.padding, child: FittedBox(child: w)),
          ));

  Widget build(BuildContext ctx, JobsBtnImageSpec spec) => _builder(ctx, spec);
}

/// 统一配置模型（像 iOS UIButton 的 contentEdge/imageEdge/titleEdge + layout）
class JobsBtnLabelConfig {
  final JobsBtnImageSpecSource icon;
  final JobsBtnImageSpec spec;
  final JobsIconPosition position;
  final double spacing; // 图文间距
  final EdgeInsets contentPadding; // 整体内边距
  final MainAxisAlignment mainAxisAlignment; // 主轴对齐
  final CrossAxisAlignment crossAxisAlignment; // 交叉轴对齐
  final double? minWidth;
  final double? minHeight;
  final bool expandText; // 文字可伸展（避免被图标挤没）

  const JobsBtnLabelConfig({
    required this.icon,
    this.spec = const JobsBtnImageSpec(),
    this.position = JobsIconPosition.left,
    this.spacing = 6,
    this.contentPadding =
        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    this.mainAxisAlignment = MainAxisAlignment.center,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.minWidth,
    this.minHeight,
    this.expandText = true,
  });
}

/// 可复用的“图+文”按钮（不强制 Ink/InkWell，你可以外面包 .onTap() 或 InkWell）
class JobsBtnLabel extends StatelessWidget {
  final Widget label; // 一般是 Text，也支持任意 Widget
  final JobsBtnLabelConfig cfg;

  const JobsBtnLabel({super.key, required this.label, required this.cfg});

  @override
  Widget build(BuildContext context) {
    final iconW = cfg.icon.build(context, cfg.spec);
    final gap = SizedBox(
      width: (cfg.position == JobsIconPosition.left ||
              cfg.position == JobsIconPosition.right)
          ? cfg.spacing
          : 0,
      height: (cfg.position == JobsIconPosition.top ||
              cfg.position == JobsIconPosition.bottom)
          ? cfg.spacing
          : 0,
    );

    final textW =
        cfg.expandText ? Flexible(fit: FlexFit.loose, child: label) : label;

    List<Widget> rowChildren(Widget a, Widget b) => [
          if (cfg.position == JobsIconPosition.left) a,
          if (cfg.position == JobsIconPosition.left) gap,
          if (cfg.position == JobsIconPosition.left) textW,
          if (cfg.position == JobsIconPosition.right) textW,
          if (cfg.position == JobsIconPosition.right) gap,
          if (cfg.position == JobsIconPosition.right) a,
        ];

    List<Widget> colChildren(Widget a, Widget b) => [
          if (cfg.position == JobsIconPosition.top) a,
          if (cfg.position == JobsIconPosition.top) gap,
          if (cfg.position == JobsIconPosition.top) textW,
          if (cfg.position == JobsIconPosition.bottom) textW,
          if (cfg.position == JobsIconPosition.bottom) gap,
          if (cfg.position == JobsIconPosition.bottom) a,
        ];

    final content = (cfg.position == JobsIconPosition.left ||
            cfg.position == JobsIconPosition.right)
        ? Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: cfg.mainAxisAlignment,
            crossAxisAlignment: cfg.crossAxisAlignment,
            children: rowChildren(iconW, textW),
          )
        : Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: cfg.mainAxisAlignment,
            crossAxisAlignment: cfg.crossAxisAlignment,
            children: colChildren(iconW, textW),
          );

    Widget w = Padding(padding: cfg.contentPadding, child: content);

    if (cfg.minWidth != null || cfg.minHeight != null) {
      w = ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: cfg.minWidth ?? 0,
          minHeight: cfg.minHeight ?? 0,
        ),
        child: w,
      );
    }
    return w;
  }
}
