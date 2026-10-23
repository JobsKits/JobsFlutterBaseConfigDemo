import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/UI/UI.Origin%F0%9F%8C%8D/JobsViews.dart';

/// 🛜网络图片
void main() {
  runApp(
    ScreenUtilInit(
      designSize: const Size(1125, 2436), // ← 设计稿尺寸
      minTextAdapt: true,
      splitScreenMode: true,
      rebuildFactor: RebuildFactors.change,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: '广告轮播图',
          home: Scaffold(
            appBar: AppBar(title: const Text('广告轮播图')),
            body: SafeArea(
              child: Center(
                child: JobsBannerCarousel(
                  height: 455.h,
                  imageUrls: const [
                    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTNaXM5FNZC7-9FDVh9mMMglZv5cuoPAw-6MA&s',
                    'https://jzmofficial.com/cdn/shop/files/Logo_1200x1200.jpg?v=1624577059',
                    'https://static.vecteezy.com/system/resources/previews/009/125/398/non_2x/jzm-logo-jzm-letter-jzm-letter-logo-design-initials-jzm-logo-linked-with-circle-and-uppercase-monogram-logo-jzm-typography-for-technology-business-and-real-estate-brand-vector.jpg',
                    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQdsn8QSHQxKyWpG6Qy2ngPM0hQMffP-DYo0FvNbwhx_EYmfl-EeYSZ4g8&s',
                  ],
                  viewportFraction: 1,
                  netImageBuilder: cachedNetImageBuilder,
                  emptyBuilder: (ctx) => Center(
                    child: JobsEmptyHint(onRetry: () {
                      debugPrint("外部触发刷新逻辑");
                    }),
                  ),
                  onTap: (i) => debugPrint('tap $i'),
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}

/// 💾 Assets 本地图片
// void main() {
//   runApp(
//     ScreenUtilInit(
//       designSize: const Size(1125, 2436),
//       builder: (context, child) {
//         return MaterialApp(
//           home: Scaffold(
//             appBar: AppBar(title: const Text('Assets 本地图')),
//             body: JobsBannerCarousel(
//               itemCount: 3,
//               itemBuilder: (ctx, i) {
//                 final images = [
//                   'assets/images/banner1.png',
//                   'assets/images/banner2.png',
//                   'assets/images/banner3.png',
//                 ];
//                 return Image.asset(images[i], fit: BoxFit.cover);
//               },
//               height: 200,
//               viewportFraction: 1,
//               onTap: (i) => debugPrint('点击第 $i 张'),
//             ),
//           ),
//         );
//       },
//     ),
//   );
// }

/// 📁 本地 File 图片
// void main() {
//   // 假设这些是设备本地路径
//   final fileList = [
//     '/storage/emulated/0/Download/local1.jpg',
//     '/storage/emulated/0/Download/local2.jpg',
//     '/storage/emulated/0/Download/local3.jpg',
//   ];

//   runApp(
//     ScreenUtilInit(
//       designSize: const Size(1125, 2436),
//       builder: (context, child) {
//         return MaterialApp(
//           home: Scaffold(
//             appBar: AppBar(title: const Text('File 本地图')),
//             body: JobsBannerCarousel(
//               itemCount: fileList.length,
//               itemBuilder: (ctx, i) {
//                 return Image.file(File(fileList[i]), fit: BoxFit.cover);
//               },
//               height: 200,
//               viewportFraction: 1,
//             ),
//           ),
//         );
//       },
//     ),
//   );
// }

/// 混合模式（第 1 张用 Asset，其余用网络）
// void main() {
//   final netImages = [
//     'https://picsum.photos/800/400?image=11',
//     'https://picsum.photos/800/400?image=22',
//     'https://picsum.photos/800/400?image=33',
//   ];

//   runApp(
//     ScreenUtilInit(
//       designSize: const Size(1125, 2436),
//       builder: (context, child) {
//         return MaterialApp(
//           home: Scaffold(
//             appBar: AppBar(title: const Text('混合模式')),
//             body: JobsBannerCarousel(
//               itemCount: 1 + netImages.length,
//               itemBuilder: (ctx, i) {
//                 if (i == 0) {
//                   return Image.asset('assets/images/banner1.png',
//                       fit: BoxFit.cover);
//                 } else {
//                   return Image.network(netImages[i - 1], fit: BoxFit.cover);
//                 }
//               },
//               height: 200,
//               viewportFraction: 1,
//             ),
//           ),
//         );
//       },
//     ),
//   );
// }

/// 纯色矩形块轮播图
// void main() {
//   runApp(
//     ScreenUtilInit(
//       designSize: const Size(1125, 2436),
//       builder: (context, child) {
//         return MaterialApp(
//           home: Scaffold(
//             appBar: AppBar(title: const Text('自定义模式')),
//             body: JobsBannerCarousel(
//               itemCount: 3,
//               itemBuilder: (ctx, i) {
//                 return ColoredBox(
//                   color: Colors.primaries[i % Colors.primaries.length].shade200,
//                   child: Center(
//                     child: Text(
//                       '自定义第 $i 页',
//                       style: const TextStyle(fontSize: 20),
//                     ),
//                   ),
//                 );
//               },
//               height: 150,
//               viewportFraction: 1,
//               emptyBuilder: (_) => const JobsEmptyHint(),
//               onTap: (i) => debugPrint('tap page $i'),
//             ),
//           ),
//         );
//       },
//     ),
//   );
// }

class JobsBannerCarousel extends StatefulWidget {
  const JobsBannerCarousel({
    super.key,
    // 二选一：imageUrls
    this.imageUrls,
    // 二选一：itemCount+itemBuilder
    this.itemCount,
    this.itemBuilder,

    // 可选：外层尺寸（不传则用屏幕宽、屏幕高的 25%）
    this.width,
    this.height,
    this.imageFit = BoxFit.contain,
    this.vertical = 0,
    this.horizontal = 0,
    this.viewportFraction = 0,
    this.borderRadius = const BorderRadius.all(Radius.circular(0)),
    this.autoPlay = true,
    this.autoPlayInterval = const Duration(seconds: 3), // 定时器的频率（默认：每3秒触发一次翻页）
    this.autoPlayAnimationDuration =
        const Duration(milliseconds: 380), // 控制翻页过程要花多长时间（默认：翻页动画持续 0.38 秒）
    this.autoPlayCurve = Curves.easeOutCubic,
    this.enableUserScroll = true,
    this.onTap,
    this.indicatorActiveColor,
    this.indicatorColor,
    this.indicatorBottom = 8,

    // 空状态插槽
    this.emptyBuilder,

    // 网络图片构建器（可接 cached_network_image）
    this.netImageBuilder,
  }) : assert(
          (imageUrls != null && itemCount == null && itemBuilder == null) ||
              (imageUrls == null && itemCount != null && itemBuilder != null),
          '使用方式错误：要么仅传 imageUrls；要么仅传 itemCount + itemBuilder。',
        );

  final List<String>? imageUrls;
  final int? itemCount;
  final Widget Function(BuildContext context, int index)? itemBuilder;

  final double? width;
  final double? height;
  final BoxFit imageFit;
  final double? vertical; // Padding.EdgeInsets.vertical
  final double? horizontal; // Padding.EdgeInsets.horizontal
  final double viewportFraction; // PageController.viewportFraction
  final BorderRadius borderRadius; // 圆角

  final bool autoPlay;
  final Duration autoPlayInterval;
  final Duration autoPlayAnimationDuration;
  final Curve autoPlayCurve;
  final bool enableUserScroll;
  final void Function(int index)? onTap;

  final Color? indicatorActiveColor;
  final Color? indicatorColor;
  final double indicatorBottom;

  final Widget Function(BuildContext context)? emptyBuilder;

  final Widget Function(
    BuildContext context,
    String url, {
    BoxFit fit,
    Widget? placeholder,
    Widget? error,
  })? netImageBuilder;

  @override
  State<JobsBannerCarousel> createState() => _JobsBannerCarouselState();
}

class _JobsBannerCarouselState extends State<JobsBannerCarousel>
    with WidgetsBindingObserver {
  late final bool _useCustomItems =
      widget.itemBuilder != null && widget.itemCount != null;

  int get _count => _useCustomItems
      ? (widget.itemCount ?? 0)
      : (widget.imageUrls?.length ?? 0);

  // 纯定时器循环：从 0 开始
  late final PageController _controller = PageController(
    initialPage: 0,
    viewportFraction: widget.viewportFraction, // 每一页占据可视区域的比例
  );

  int _currentPage = 0;
  Timer? _timer;
  bool get _canAutoPlay => widget.autoPlay && _count > 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _currentPage = 0;
    _maybeStartAuto();
  }

  @override
  void didUpdateWidget(covariant JobsBannerCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    final bool dataChanged =
        oldWidget.imageUrls?.length != widget.imageUrls?.length ||
            oldWidget.itemCount != widget.itemCount;

    final bool playChanged = oldWidget.autoPlay != widget.autoPlay ||
        oldWidget.autoPlayInterval != widget.autoPlayInterval ||
        oldWidget.autoPlayAnimationDuration !=
            widget.autoPlayAnimationDuration ||
        oldWidget.autoPlayCurve != widget.autoPlayCurve;

    if (dataChanged) {
      // 数据量变更时，防越界，并把控制器跳回安全位置
      if (_currentPage >= _count) {
        _currentPage = (_count == 0) ? 0 : 0;
        if (_controller.hasClients) {
          _controller.jumpToPage(_currentPage);
        }
      }
    }

    if (dataChanged || playChanged) {
      _stopAuto();
      _maybeStartAuto();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopAuto();
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_canAutoPlay) return;
    if (state == AppLifecycleState.resumed) {
      _maybeStartAuto();
    } else {
      _stopAuto();
    }
  }

  /// 定时器
  void _maybeStartAuto() {
    if (!_canAutoPlay || _timer != null) return;
    _timer = Timer.periodic(widget.autoPlayInterval, (_) => _tick());
  }

  void _tick() {
    if (!_controller.hasClients || !_canAutoPlay) return;

    final last = _count - 1;
    if (_currentPage >= last) {
      // 到尾页：瞬移回第一页，再正常播放到第 1 页，避免卡死在末尾
      _controller.jumpToPage(0);
      _currentPage = 0;

      // 用微任务确保 jump 生效后再做动画，避免偶发闪烁
      scheduleMicrotask(() {
        if (!_controller.hasClients) return;
        _controller.animateToPage(
          1,
          duration: widget.autoPlayAnimationDuration,
          curve: widget.autoPlayCurve,
        );
        _currentPage = 1;
        if (mounted) setState(() {});
      });
    } else {
      final next = _currentPage + 1;
      _controller.animateToPage(
        next,
        duration: widget.autoPlayAnimationDuration,
        curve: widget.autoPlayCurve,
      );
      _currentPage = next;
      if (mounted) setState(() {});
    }
  }

  void _stopAuto() {
    _timer?.cancel();
    _timer = null;
  }

  void _resumeAutoWithDelay() {
    if (!_canAutoPlay) return;
    Future.delayed(const Duration(milliseconds: 400), _maybeStartAuto);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final viewport = MediaQuery.sizeOf(context);
      final width = widget.width ??
          (constraints.hasBoundedWidth ? constraints.maxWidth : viewport.width);
      final size = constraints.constrain(Size(
        width,
        widget.height ??
            (width * 9 / 16).clamp(0.0, viewport.height * 0.25).toDouble(),
      ));
      return _buildBanner(context, size);
    });
  }

  Widget _buildBanner(BuildContext context, Size size) {
    final w = size.width;
    final h = size.height;

    // 无数据：渲染空态（不要建 PageView）
    if (_count == 0) {
      return SizedBox(
        width: w,
        height: h,
        child: widget.emptyBuilder?.call(context) ?? const _DefaultEmpty(),
      );
    }

    final theme = Theme.of(context);
    final activeColor =
        widget.indicatorActiveColor ?? theme.colorScheme.primary;
    final color =
        widget.indicatorColor ?? theme.colorScheme.onSurface.withOpacity(.35);
    return SizedBox(
      width: w,
      height: h,
      child: Listener(
        onPointerDown: (_) => _stopAuto(),
        onPointerCancel: (_) => _resumeAutoWithDelay(),
        onPointerUp: (_) => _resumeAutoWithDelay(),
        child: Stack(
          fit: StackFit.expand,
          children: [
            PageView.builder(
              controller: _controller,
              physics: widget.enableUserScroll
                  ? const PageScrollPhysics()
                  : const NeverScrollableScrollPhysics(),
              onPageChanged: (absIndex) {
                _currentPage = absIndex;
                setState(() {});
              },
              itemCount: _count, // 纯定时器循环：真实数量
              itemBuilder: (context, i) {
                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: widget.vertical!,
                    vertical: widget.horizontal!,
                  ),
                  child: ClipRRect(
                    borderRadius: widget.borderRadius,
                    child: GestureDetector(
                      onTap: () => widget.onTap?.call(i),
                      behavior: HitTestBehavior.opaque,
                      child: _useCustomItems
                          ? widget.itemBuilder!(context, i)
                          : _buildNetImage(context, widget.imageUrls![i]),
                    ),
                  ),
                );
              },
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: widget.indicatorBottom,
              child: _DotsIndicator(
                count: _count,
                current: _currentPage.clamp(0, _count - 1),
                activeColor: activeColor,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNetImage(BuildContext context, String url) {
    final builder = widget.netImageBuilder ?? _DefaultNetImage.build;
    return builder(
      context,
      url,
      fit: widget.imageFit,
      placeholder: const _DefaultLoading(),
      error: const _DefaultError(),
    );
  }
}

/// ================== 默认实现：网络图 + 占位 ==================
class _DefaultNetImage {
  static Widget build(
    BuildContext context,
    String url, {
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? error,
  }) {
    return Image.network(
      url,
      fit: fit,
      loadingBuilder: (ctx, child, progress) {
        if (progress == null) return child;
        return Stack(
          fit: StackFit.expand,
          children: [
            if (placeholder != null) placeholder,
            const Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                    strokeWidth: 3), // 默认是一个会无限旋转的圆环（不确定进度的加载动画）。
              ),
            ),
          ],
        );
      },
      errorBuilder: (ctx, err, stack) => error ?? const _DefaultError(),
    );
  }
}

/// ================== 默认占位图 ==================
class _DefaultEmpty extends StatelessWidget {
  const _DefaultEmpty();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withOpacity(.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Opacity(
          opacity: .7,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.image_not_supported_outlined, size: 44),
              SizedBox(height: 8),
              Text('暂无 Banner', style: TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}

class _DefaultLoading extends StatelessWidget {
  const _DefaultLoading();
  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Colors.black12,
      child: Center(child: Icon(Icons.photo_outlined, size: 28)),
    );
  }
}

class _DefaultError extends StatelessWidget {
  const _DefaultError();
  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Colors.black12,
      child: Center(child: Icon(Icons.broken_image_outlined, size: 28)),
    );
  }
}

/// ================== 指示器 ==================
class _DotsIndicator extends StatelessWidget {
  const _DotsIndicator({
    required this.count,
    required this.current,
    required this.activeColor,
    required this.color,
  });

  final int count;
  final int current;
  final Color activeColor;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (count <= 1) return const SizedBox.shrink();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final isActive = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 16 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: isActive ? activeColor : color,
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }
}

/// ============ 可选：缓存管理 ============
class BannerCacheManager {
  static final BaseCacheManager instance = CacheManager(
    Config(
      'bannerCache',
      stalePeriod: const Duration(days: 14),
      maxNrOfCacheObjects: 300,
      repo: JsonCacheInfoRepository(databaseName: 'bannerCache'),
      fileService: HttpFileService(),
    ),
  );
}

/// ============ 推荐的 cachedNetImageBuilder（支持 viewportFraction） ============
Widget cachedNetImageBuilder(
  BuildContext context,
  String url, {
  BoxFit fit = BoxFit.cover,
  Widget? placeholder,
  Widget? error,
}) {
  return LayoutBuilder(
    builder: (context, constraints) {
      final mq = MediaQuery.maybeOf(context);
      final pixelRatio = mq?.devicePixelRatio ?? 2.0;

      final cw = constraints.maxWidth.isFinite
          ? constraints.maxWidth
          : MediaQuery.of(context).size.width;
      final ch = constraints.maxHeight.isFinite
          ? constraints.maxHeight
          : (MediaQuery.of(context).size.height * 0.25);

      final memCacheWidth = (cw * pixelRatio).clamp(200, 2000).toInt();
      final memCacheHeight = (ch * pixelRatio).clamp(120, 1500).toInt();

      return CachedNetworkImage(
        imageUrl: url,
        fit: fit,
        cacheManager: BannerCacheManager.instance,
        placeholder: (_, __) => placeholder ?? const _DefaultLoading(),
        errorWidget: (_, __, ___) => error ?? const _DefaultError(),
        fadeInDuration: const Duration(milliseconds: 180),
        fadeOutDuration: const Duration(milliseconds: 80),
        memCacheWidth: memCacheWidth,
        memCacheHeight: memCacheHeight,
      );
    },
  );
}

/// ================= 图片模式（配合缓存 + 占位）======================
// Scaffold(
//   appBar: AppBar(title: const Text('Banner - images')),
//   body: Center(
//     child: JobsBannerCarousel(
//       width: ScreenUtil().screenWidth,
//       height: 455.h,
//       imageUrls: const [
//         'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTNaXM5FNZC7-9FDVh9mMMglZv5cuoPAw-6MA&s',
//         'https://jzmofficial.com/cdn/shop/files/Logo_1200x1200.jpg?v=1624577059',
//         'https://static.vecteezy.com/system/resources/previews/009/125/398/non_2x/jzm-logo-jzm-letter-jzm-letter-logo-design-initials-jzm-logo-linked-with-circle-and-uppercase-monogram-logo-jzm-typography-for-technology-business-and-real-estate-brand-vector.jpg',
//         'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQdsn8QSHQxKyWpG6Qy2ngPM0hQMffP-DYo0FvNbwhx_EYmfl-EeYSZ4g8&s',
//       ],
//       viewportFraction: 1,
//       // vertical: 5.0,
//       // horizontal: 5.0,
//       // 关键：接入缓存版网络图
//       netImageBuilder: cachedNetImageBuilder,
//       // 空数据占位（数据为空时展示）
//       emptyBuilder: (ctx) => Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(Icons.image_not_supported_outlined, size: 48),
//             const SizedBox(height: 8),
//             Text('暂无内容'.tr),
//             const SizedBox(height: 8),
//             OutlinedButton(
//                 onPressed: () {/* 触发加载 */}, child: Text('重试'.tr)),
//           ],
//         ),
//       ),
//       onTap: (i) => debugPrint('tap $i'),
//     ),
//   ),
// );

/// ================= 自定义模式（完全不用图片 URL）======================
// BannerCarousel(
//   itemCount: 3,
//   itemBuilder: (ctx, i) {
//     return ColoredBox(
//       color: Colors.primaries[i % Colors.primaries.length].shade200,
//       child: Center(child: Text('自定义第 $i 页', style: const TextStyle(fontSize: 20))),
//     );
//   },
//   height: 150,
//   viewportFraction: 1,
//   emptyBuilder: (_) => const JobsEmptyHint(),
//   onTap: (i) => debugPrint('tap page $i'),
// );
