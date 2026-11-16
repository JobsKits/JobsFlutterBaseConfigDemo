// 独立运行：flutter run -t "lib/demos/GetX页面状态示例一/GetX_PageStateDemo1.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobs_runners/jobs_runners.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() => launchLegacyStandalone(legacyOriginalMain, title: 'GetX页面状态示例一');

// 公共测试器路径

// 使用 GetX 状态管理器来管理页面状态。
void legacyOriginalMain() {
  // 使用 GetX 状态管理器
  final pageState = PageState.DEFAULT.obs;
  legacyCaptureApp(
    JobsMaterialRunner.builder(
      title: 'Page State Demo',
      builder: (ctx) {
        return Scaffold(
          appBar: JobsDemoAppBar(title: const LegacyText('Page State Demo')),
          body: Obx(() {
            // 根据页面状态返回不同的 UI
            switch (pageState.value) {
              case PageState.DEFAULT:
                return _buildDefaultUI();
              case PageState.LOADING:
                return _buildLoadingUI();
              case PageState.SUCCESS:
                return _buildSuccessUI();
              case PageState.ERROR:
                return _buildErrorUI();
            }
          }),
          // 模拟页面状态转换
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              // 模拟状态切换
              switch (pageState.value) {
                case PageState.DEFAULT:
                  pageState(PageState.LOADING);
                  break;
                case PageState.LOADING:
                  pageState(PageState.SUCCESS);
                  break;
                case PageState.SUCCESS:
                  pageState(PageState.ERROR);
                  break;
                case PageState.ERROR:
                  pageState(PageState.DEFAULT);
                  break;
              }
            },
            child: const Icon(Icons.refresh),
          ),
        );
      },
    ),
  );
}

// 定义页面状态枚举
enum PageState {
  DEFAULT, // ignore: constant_identifier_names
  LOADING, // ignore: constant_identifier_names
  SUCCESS, // ignore: constant_identifier_names
  ERROR, // ignore: constant_identifier_names
}

// 默认状态 UI
Widget _buildDefaultUI() {
  return const Center(child: LegacyText('Default State'));
}

// 加载中状态 UI
Widget _buildLoadingUI() {
  return const Center(child: CircularProgressIndicator());
}

// 成功状态 UI
Widget _buildSuccessUI() {
  return const Center(child: LegacyText('Success State'));
}

// 错误状态 UI
Widget _buildErrorUI() {
  return const Center(child: LegacyText('Error State'));
}

Widget buildLegacyDemo(BuildContext context) =>
    LegacyLaunchPage(action: legacyOriginalMain, title: 'GetX_PageStateDemo1');
