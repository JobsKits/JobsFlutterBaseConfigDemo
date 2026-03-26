import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'package:jobs_runners/jobs_runners.dart'; // 公共测试器路径

void main() => runApp(const JobsMaterialRunner(
    JobsSafeImage(
      assetPath: 'assets/Images/flower.png',
      width: 32,
      height: 32,
      fallback: Icon(Icons.warning),
    ),
    title: '安全加载图片'));

class JobsSafeImage extends StatelessWidget {
  final String assetPath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? fallback;

  const JobsSafeImage({
    super.key,
    required this.assetPath,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        developer.log('⚠️ 加载图片失败: $assetPath', error: error);
        return fallback ??
            Container(
              width: width,
              height: height,
              color: Colors.grey[300],
              child: const Icon(Icons.broken_image, color: Colors.red),
            );
      },
    );
  }
}
