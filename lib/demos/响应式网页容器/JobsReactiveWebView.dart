// 独立运行：flutter run -t "lib/demos/响应式网页容器/JobsReactiveWebView.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'package:flutter/foundation.dart';
import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobs_runners/jobs_runners.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/JobsFlutterTools/JobsWebView/htmlContent.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/JobsFlutterTools/JobsWebView/JobsWebViewWidget.dart';

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() => launchLegacyStandalone(
  legacyOriginalMain,
  supportsWeb: false,
  supportedPlatforms: const [TargetPlatform.iOS, TargetPlatform.android],
  title: '响应式网页容器',
);

// 原始 WebView 组件

void legacyOriginalMain() {
  final html = htmlContent();

  legacyCaptureApp(
    JobsGetRunner.builder(
      title: 'JobsReactiveWebView',
      builder: (ctx) => Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 12),
              JobsReactiveWebView(
                html: html,
                showLoading: true,
                enableScrollListen: true,
                interceptLinks: true,
                onHeightChanged: (h) {
                  legacyDebugPrint("📏 WebView 高度: $h");
                },
              ),
              const SizedBox(height: 16),
              const LegacyText("✅ WebView 下方内容"),
            ],
          ),
        ),
      ),
    ),
  );
}

class JobsReactiveWebView extends StatelessWidget {
  final String html;
  final double minHeight;
  final bool showLoading;
  final bool enableScrollListen;
  final bool interceptLinks;
  final void Function(double height)? onHeightChanged;

  const JobsReactiveWebView({
    super.key,
    required this.html,
    this.minHeight = 1,
    this.showLoading = false,
    this.enableScrollListen = false,
    this.interceptLinks = false,
    this.onHeightChanged,
  });

  @override
  Widget build(BuildContext context) {
    final RxDouble height = 1.0.obs;

    return Obx(
      () => AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        height: height.value < minHeight ? minHeight : height.value,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: JobsWebViewWidget(
          html: html,
          showLoading: showLoading,
          enableScrollListen: enableScrollListen,
          interceptLinks: interceptLinks,
          onHeightChanged: (h) {
            height.value = h;
            onHeightChanged?.call(h); // 通知外部监听者（可选）
          },
        ),
      ),
    );
  }
}

Widget buildLegacyDemo(BuildContext context) => LegacyLaunchPage(
  supportsWeb: false,
  supportedPlatforms: const [TargetPlatform.iOS, TargetPlatform.android],
  action: legacyOriginalMain,
  title: 'JobsReactiveWebView',
);
