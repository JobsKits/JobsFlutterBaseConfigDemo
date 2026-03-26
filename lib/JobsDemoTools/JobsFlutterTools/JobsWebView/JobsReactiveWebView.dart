import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobs_runners/jobs_runners.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/JobsFlutterTools/JobsWebView/htmlContent.dart';
import 'JobsWebViewWidget.dart'; // 原始 WebView 组件

void main() {
  final html = htmlContent();

  runApp(JobsGetRunner.builder(
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
                debugPrint("📏 WebView 高度: $h");
              },
            ),
            const SizedBox(height: 16),
            const Text("✅ WebView 下方内容"),
          ],
        ),
      ),
    ),
  ));
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
    final RxDouble _height = 1.0.obs;

    return Obx(() => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: _height.value < minHeight ? minHeight : _height.value,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: JobsWebViewWidget(
            html: html,
            showLoading: showLoading,
            enableScrollListen: enableScrollListen,
            interceptLinks: interceptLinks,
            onHeightChanged: (h) {
              _height.value = h;
              onHeightChanged?.call(h); // 通知外部监听者（可选）
            },
          ),
        ));
  }
}
