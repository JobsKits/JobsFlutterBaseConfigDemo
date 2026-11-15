import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

import '../../demo_hub/platform_support.dart';
import '../../demo_hub/platform_strings.dart';

void main() => runApp(const JobsDemoApp(home: SystemServicesLabDemo()));

class SystemServicesLabDemo extends StatefulWidget {
  const SystemServicesLabDemo({super.key});
  @override
  State<SystemServicesLabDemo> createState() => _SystemServicesLabDemoState();
}

class _SystemServicesLabDemoState extends State<SystemServicesLabDemo> {
  final state = NativeLabState('system');
  final text = TextEditingController(text: 'Jobs Flutter');
  final url = TextEditingController(text: 'https://flutter.dev');
  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([]);
    state.dispose();
    text.dispose();
    url.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => NativeLabPanel(
    title: '系统能力实验室',
    state: state,
    children: [
      nativeButton(context, state, '平台能力', 'capabilities'),
      TextField(controller: text, onChanged: (_) => setState(() {})),
      Wrap(
        spacing: 8,
        children: [
          nativeButton(context, state, '复制文本', 'clipboard.write', {
            'text': text.text,
          }),
          nativeButton(context, state, '读取剪贴板', 'clipboard.read'),
        ],
      ),
      const SizedBox(height: 16),
      TextField(
        controller: url,
        onChanged: (_) => setState(() {}),
        decoration: const InputDecoration(labelText: 'URL'),
      ),
      nativeButton(context, state, '打开URL', 'url.open', {'url': url.text}),
      nativeButton(context, state, '系统分享', 'system.share', {
        'text': text.text,
        'url': url.text,
        'title': platformText(context, '系统分享'),
      }),
      Wrap(
        spacing: 8,
        children: [
          FilledButton.tonal(
            onPressed: () => SystemChrome.setPreferredOrientations([
              DeviceOrientation.portraitUp,
            ]),
            child: Text(platformText(context, '竖屏')),
          ),
          FilledButton.tonal(
            onPressed: () => SystemChrome.setPreferredOrientations([
              DeviceOrientation.landscapeLeft,
              DeviceOrientation.landscapeRight,
            ]),
            child: Text(platformText(context, '横屏')),
          ),
          FilledButton.tonal(
            onPressed: () => SystemChrome.setPreferredOrientations([]),
            child: Text(platformText(context, '跟随系统')),
          ),
        ],
      ),
      nativeButton(context, state, '设备安全检测', 'device.risk'),
    ],
  );
}
