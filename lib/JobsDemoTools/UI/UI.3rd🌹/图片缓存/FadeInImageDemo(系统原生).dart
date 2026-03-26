import 'package:flutter/material.dart';
import 'package:jobs_runners/jobs_runners.dart';

/// FadeInImage是系统原生的SDK
void main() =>
    runApp(JobsGetRunner(const FadeInImageDemo(), title: 'FadeInImage 示例'));

class FadeInImageDemo extends StatelessWidget {
  const FadeInImageDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FadeInImage.assetNetwork(
        placeholder: 'assets/loading.png', // ✅ 本地占位图路径（需先在 pubspec.yaml 注册）
        image: 'https://via.placeholder.com/300x200', // ✅ 网络图片 URL

        width: 300, // ✅ 宽度
        height: 200, // ✅ 高度
        fit: BoxFit.cover, // ✅ 图片填充方式

        fadeInDuration: const Duration(milliseconds: 500), // ✅ 图片淡入时间
        fadeOutDuration: const Duration(milliseconds: 300), // ✅ 占位图淡出时间

        imageErrorBuilder: (context, error, stackTrace) => // ✅ 加载失败时显示的 Widget
            const Icon(Icons.error, size: 48, color: Colors.red),

        alignment: Alignment.center, // ✅ 图片对齐方式
        repeat: ImageRepeat.noRepeat, // ✅ 是否重复图像
        matchTextDirection: false, // ✅ 是否遵循文字方向（用于 RTL 语言）
      ),
    );
  }
}
