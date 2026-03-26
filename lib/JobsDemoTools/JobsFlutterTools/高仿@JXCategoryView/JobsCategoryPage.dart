import 'package:extended_tabs/extended_tabs.dart';
import 'package:flutter/material.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/JobsFlutterTools/高仿@JXCategoryView/ActivityShareSubView@回归包赔.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/JobsFlutterTools/高仿@JXCategoryView/ActivityShareSubView@彩金免费领.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/JobsFlutterTools/高仿@JXCategoryView/ActivityShareSubView@超值存送礼.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/JobsFlutterTools/高仿@JXCategoryView/ActivityShareSubView@队长福利.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/Utils/Extensions/WidgetExtensions/onWidgets.dart';
import 'package:jobs_runners/jobs_runners.dart';
/// 高仿@JXCategoryView
void main() {
  final items = <ActivityBaseBean>[
    ActivityBaseBean(
      title: '彩金免费领',
      child: const CategoryListPage_1(title: '彩金免费领', index: 0).center(),
      show: true,
    ),
    ActivityBaseBean(
      title: '超值存送礼',
      child: const CategoryListPage_2(title: '超值存送礼', index: 1).center(),
      show: true,
    ),
    ActivityBaseBean(
      title: '回归包赔',
      child: const CategoryListPage_3(title: '回归包赔', index: 2).center(),
      show: true,
    ),
    ActivityBaseBean(
      title: '队长福利',
      child: const CategoryListPage_4(title: '队长福利', index: 3).center(),
      show: true,
    ),
  ].where((e) => e.show).toList();

  runApp(
    JobsMaterialRunner(
      // 传入外部数据
      JobsCategoryPage(
        items: items,
      ),
      title: 'JXCategoryView 风格 Demo',
    ),
  );
}

class JobsCategoryPage extends StatefulWidget {
  const JobsCategoryPage({
    super.key,
    required this.items,
    this.initialIndex = 0,
    this.selectedColor = const Color.fromARGB(255, 32, 33, 46),
    this.unselectedColor = const Color(0xFF666666),
  }) : assert(items.length > 0, 'items 不能为空');

  /// 外部注入的页签数据（只传要展示的）
  final List<ActivityBaseBean> items;

  /// 默认选中的 index
  final int initialIndex;

  final Color selectedColor;
  final Color unselectedColor;

  @override
  State<JobsCategoryPage> createState() => _JobsCategoryPageState();
}

class _JobsCategoryPageState extends State<JobsCategoryPage>
    with SingleTickerProviderStateMixin {
  late final TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(
      length: widget.items.length,
      vsync: this,
      initialIndex: (widget.initialIndex >= 0 &&
              widget.initialIndex < widget.items.length)
          ? widget.initialIndex
          : 0,
    );
  }

  @override
  void didUpdateWidget(covariant JobsCategoryPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 当外部 items 数量变化时，重建 TabController
    if (oldWidget.items.length != widget.items.length) {
      final newIndex = _controller.index.clamp(0, widget.items.length - 1);
      _controller.dispose();
      // 重新创建 controller，尽量保持原来的 index
      // ignore: invalid_use_of_protected_member
      _controller = TabController(
        length: widget.items.length,
        vsync: this,
        initialIndex: newIndex,
      );
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final titles = widget.items.map((e) => e.title).toList();

    final topBar = Container(
      height: 48,
      alignment: Alignment.centerLeft,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0x11000000))),
      ),
      child: _AdaptiveTabBar(
        controller: _controller,
        tabsText: titles,
        tabChildBuilder: (i) => _ZoomTab(
          controller: _controller,
          index: i,
          text: titles[i],
          selectedColor: widget.selectedColor,
          unselectedColor: widget.unselectedColor,
          maxScaleDelta: 0.12,
          minFontWeight: FontWeight.w500,
          maxFontWeight: FontWeight.w800,
          duration: const Duration(milliseconds: 160),
        ),
      ),
    );

    final body = ExtendedTabBarView(
      controller: _controller,
      children: [
        for (final it in widget.items) it.child,
      ],
    );

    return Column(
      children: [
        topBar,
        const SizedBox(height: 8),
        Expanded(child: body),
      ],
    );
  }
}

/// 自定义 Tab：根据与当前页的距离做「放大 + 加粗 + 颜色渐变」
class _ZoomTab extends StatelessWidget {
  final TabController controller;
  final int index;
  final String text;
  final Color selectedColor;
  final Color unselectedColor;
  final double maxScaleDelta; // 选中时在 1.0 基础上放大的比例
  final FontWeight minFontWeight;
  final FontWeight maxFontWeight;
  final Duration duration;

  const _ZoomTab({
    required this.controller,
    required this.index,
    required this.text,
    required this.selectedColor,
    required this.unselectedColor,
    this.maxScaleDelta = 0.12,
    this.minFontWeight = FontWeight.w500,
    this.maxFontWeight = FontWeight.w800,
    this.duration = const Duration(milliseconds: 160),
  });

  @override
  Widget build(BuildContext context) {
    final Listenable listenable = controller.animation ?? controller;

    return AnimatedBuilder(
      animation: listenable, // 监听 TabController 的动画/索引变化
      builder: (_, __) {
        double selectedness = 0.0;
        final animation = controller.animation;
        if (animation != null) {
          selectedness =
              (1.0 - (animation.value - index).abs()).clamp(0.0, 1.0);
        } else {
          selectedness = controller.index == index ? 1.0 : 0.0;
        }

        final scale =
            1.0 + maxScaleDelta * Curves.easeOut.transform(selectedness);

        // 字重插值
        final wMin = _fontWeightToNumeric(minFontWeight);
        final wMax = _fontWeightToNumeric(maxFontWeight);
        final wVal = (wMin + (wMax - wMin) * selectedness).round();
        final weight = _numericToFontWeight(wVal);

        // 颜色插值
        final color = Color.lerp(unselectedColor, selectedColor, selectedness)!;

        return AnimatedScale(
          duration: duration,
          scale: scale,
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            // 直接用 Text.style 控制，避免被 TabBar 的 DefaultTextStyle 盖掉
            style: TextStyle(
              fontSize: 14,
              fontWeight: weight,
              color: color,
            ),
          ),
        );
      },
    );
  }

  // FontWeight ↔ 数值映射（便于插值）
  int _fontWeightToNumeric(FontWeight w) {
    switch (w) {
      case FontWeight.w100:
        return 100;
      case FontWeight.w200:
        return 200;
      case FontWeight.w300:
        return 300;
      case FontWeight.w400:
        return 400;
      case FontWeight.w500:
        return 500;
      case FontWeight.w600:
        return 600;
      case FontWeight.w700:
        return 700;
      case FontWeight.w800:
        return 800;
      case FontWeight.w900:
        return 900;
      default:
        return 400;
    }
  }

  FontWeight _numericToFontWeight(int v) {
    if (v <= 100) return FontWeight.w100;
    if (v <= 200) return FontWeight.w200;
    if (v <= 300) return FontWeight.w300;
    if (v <= 400) return FontWeight.w400;
    if (v <= 500) return FontWeight.w500;
    if (v <= 600) return FontWeight.w600;
    if (v <= 700) return FontWeight.w700;
    if (v <= 800) return FontWeight.w800;
    return FontWeight.w900;
  }
}

/// 自适应 TabBar（不变）
class _AdaptiveTabBar extends StatelessWidget {
  final TabController controller;
  final List<String> tabsText;
  final Widget Function(int i) tabChildBuilder;

  final double baseFontSize;
  final FontWeight baseFontWeight;

  const _AdaptiveTabBar({
    required this.controller,
    required this.tabsText,
    required this.tabChildBuilder,
    this.baseFontSize = 14,
    this.baseFontWeight = FontWeight.w500,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, cons) {
      final maxW = cons.maxWidth;
      final n = tabsText.length;
      final perW = maxW / n;

      final fits =
          _allFitWithin(tabsText, perW, baseFontSize, baseFontWeight, ctx);

      if (fits) {
        return TabBar(
          controller: controller,
          isScrollable: false,
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: const UnderlineTabIndicator(
            borderSide: BorderSide(width: 3, color: Color(0xFF00BBD4)),
            insets: EdgeInsets.zero,
          ),
          labelPadding: EdgeInsets.zero,
          tabs: List.generate(n, (i) => Tab(child: tabChildBuilder(i))),
          onTap: (_) {},
        );
      }

      return TabBar(
        controller: controller,
        isScrollable: true,
        indicatorSize: TabBarIndicatorSize.label,
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(width: 3, color: Color(0xFF00BBD4)),
          insets: EdgeInsets.zero,
        ),
        labelPadding: const EdgeInsets.symmetric(horizontal: 14),
        tabs: List.generate(n, (i) => Tab(child: tabChildBuilder(i))),
        onTap: (_) {},
      );
    });
  }

  bool _allFitWithin(
    List<String> labels,
    double perW,
    double fontSize,
    FontWeight weight,
    BuildContext ctx,
  ) {
    final scaler =
        MediaQuery.maybeOf(ctx)?.textScaler ?? const TextScaler.linear(1.0);
    final textScale = scaler.scale(14) / 14; // ✅ 等效倍数
    for (final s in labels) {
      final tp = TextPainter(
        text: TextSpan(
          text: s,
          style: TextStyle(fontSize: fontSize * textScale, fontWeight: weight),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 1,
        ellipsis: '…',
      )..layout();
      if (tp.width > perW) return false;
    }
    return true;
  }
}

class ActivityBaseBean {
  ActivityBaseBean({
    required this.child,
    required this.title,
    required this.show,
  });

    final String title;
    final Widget child;
    final bool show;
}
