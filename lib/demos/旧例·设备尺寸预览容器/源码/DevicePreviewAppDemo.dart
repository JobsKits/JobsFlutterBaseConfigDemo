import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';

void legacyOriginalMain() {
  legacyCaptureApp(
    DevicePreview(
      enabled: true,
      builder: (context) => const DevicePreviewAppDemo(),
    ),
  );
}

class DevicePreviewAppDemo extends StatelessWidget {
  const DevicePreviewAppDemo({super.key});
  @override
  Widget build(BuildContext context) {
    return LegacyAppBoundary(
      app: MaterialApp(
        locale: DevicePreview.locale(context),
        builder: DevicePreview.appBuilder,
        home: Scaffold(
          appBar: AppBar(title: const LegacyText('DevicePreview 示例')),
          body: const Center(
            child: LegacyText(
              '📱 DevicePreview 可模拟设备\n'
              '• 模拟不同机型、方向、语言\n'
              '• 用于开发期适配与测试',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() => launchLegacyStandalone(legacyOriginalMain, title: '旧例·设备尺寸预览容器');
