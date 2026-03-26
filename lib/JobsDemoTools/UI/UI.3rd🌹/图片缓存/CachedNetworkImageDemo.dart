import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:jobs_runners/jobs_runners.dart';

void main() => runApp(JobsGetRunner(const CachedNetworkImageDemo(),
    title: 'CachedNetworkImage 全属性示例'));

class CachedNetworkImageDemo extends StatelessWidget {
  const CachedNetworkImageDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CachedNetworkImage(
        imageUrl: 'https://via.placeholder.com/150', // ✅ 图片地址（必填）
        httpHeaders: const {
          'Authorization': 'Bearer YOUR_TOKEN', // ✅ 自定义 HTTP 请求头（可选）
        },
        cacheKey: 'custom_cache_key', // ✅ 自定义缓存 key（可手动管理缓存）

        placeholder: (context, url) =>
            const CircularProgressIndicator(), // ✅ 加载中占位图
        progressIndicatorBuilder: (context, url, progress) {
          return Column(
            // ✅ 显示加载进度（字节）
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 10),
              Text('${progress.downloaded} / ${progress.totalSize} bytes'),
            ],
          );
        },

        errorWidget: (context, url, error) =>
            const Icon(Icons.error), // ✅ 加载失败显示组件
        errorListener: (error) =>
            debugPrint('加载失败: $error'), // ✅ 错误监听器（不会 UI 显示，只打印）

        imageBuilder: (context, imageProvider) => Container(
          // ✅ 成功加载后自定义展示方式
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(
              image: imageProvider,
              fit: BoxFit.cover,
            ),
          ),
        ),

        fadeInDuration: const Duration(milliseconds: 500), // ✅ 图片淡入动画时间
        fadeOutDuration: const Duration(milliseconds: 300), // ✅ 占位图淡出动画时间
        fadeInCurve: Curves.easeIn, // ✅ 图片淡入动画曲线
        fadeOutCurve: Curves.easeOut, // ✅ 占位图淡出动画曲线
        placeholderFadeInDuration:
            const Duration(milliseconds: 200), // ✅ 占位图淡入时间

        width: 200, // ✅ 图片宽度
        height: 200, // ✅ 图片高度
        fit: BoxFit.cover, // ✅ 图片填充方式
        alignment: Alignment.center, // ✅ 对齐方式
        repeat: ImageRepeat.noRepeat, // ✅ 是否重复图像
        matchTextDirection: false, // ✅ 是否遵循文字方向（如 RTL）

        color: Colors.red.withValues(alpha: 0.2), // ✅ 与图片叠加的颜色
        colorBlendMode: BlendMode.overlay, // ✅ 颜色叠加方式
        filterQuality: FilterQuality.high, // ✅ 渲染质量（建议 high）

        memCacheWidth: 400, // ✅ 内存缓存图像最大宽度
        memCacheHeight: 400, // ✅ 内存缓存图像最大高度
        maxWidthDiskCache: 800, // ✅ 磁盘缓存图像最大宽度
        maxHeightDiskCache: 800, // ✅ 磁盘缓存图像最大高度

        cacheManager: DefaultCacheManager(), // ✅ 使用自定义 CacheManager（可选）

        useOldImageOnUrlChange: true, // ✅ 当 URL 改变时是否保留旧图像直到新图加载完
      ),
    );
  }
}

class MyCustomCacheManager extends CacheManager {
  static const String key = 'myCustomCache'; // 自定义缓存 key，用于标识缓存文件夹和数据库
  static final MyCustomCacheManager _instance =
      MyCustomCacheManager._internal(); // 单例实例，避免重复创建
  factory MyCustomCacheManager() => _instance; // 工厂构造，外部调用只用这个
  MyCustomCacheManager._internal() // 私有构造函数 + 自定义配置
      : super(
          Config(
            key,
            stalePeriod: const Duration(days: 3), // 超过 3 天视为“过期”
            maxNrOfCacheObjects: 100, // 最多缓存 100 个文件
            repo: JsonCacheInfoRepository(databaseName: key), // 使用默认 json 数据库存储
            fileService: HttpFileService(), // 使用默认 http 下载器
          ),
        );
}
