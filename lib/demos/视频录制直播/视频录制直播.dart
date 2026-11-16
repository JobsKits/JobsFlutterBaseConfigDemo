// 独立运行：flutter run -t "lib/demos/视频录制直播/视频录制直播.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';
import 'package:jobs_platform_lab/jobs_platform_lab.dart';

import '../../demo_hub/platform_support.dart';
import '../../demo_hub/platform_strings.dart';
import '长按视频录制.dart';

void main() => runApp(const JobsDemoApp(home: VideoCaptureLabDemo()));

class VideoCaptureLabDemo extends StatefulWidget {
  const VideoCaptureLabDemo({super.key});
  @override
  State<VideoCaptureLabDemo> createState() => _VideoCaptureLabDemoState();
}

class _VideoCaptureLabDemoState extends State<VideoCaptureLabDemo> {
  final state = NativeLabState('video');
  final url = TextEditingController(text: 'rtmp://');
  List<Map<String, dynamic>> files = [];
  @override
  void initState() {
    super.initState();
    reload();
  }

  Future<void> reload() async {
    final value = await state.run('video.list');
    if (value is List && mounted) {
      setState(
        () => files = value
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList(),
      );
    }
  }

  Future<void> record() async {
    await state.run('video.record', {'maxSeconds': 60});
    await reload();
  }

  @override
  void dispose() {
    if (JobsPlatformLab.hasNativeBridge) {
      unawaited(JobsPlatformLab.invoke<void>('rtmp.stop').catchError((_) {}));
    }
    state.dispose();
    url.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => NativeLabPanel(
    title: '视频录制与直播',
    state: state,
    children: [
      FilledButton.tonal(
        onPressed: () async {
          await Navigator.of(context).push<void>(
            MaterialPageRoute(builder: (_) => const HoldVideoRecorderDemo()),
          );
          if (mounted) await reload();
        },
        child: Text(platformText(context, '长按录制视频')),
      ),
      FilledButton(
        onPressed: record,
        child: Text(platformText(context, '录制视频')),
      ),
      TextButton(onPressed: reload, child: Text(platformText(context, '重新加载'))),
      if (files.isEmpty)
        JobsEmptyState(
          title: platformText(context, '无数据'),
          message: platformText(context, '录制视频'),
          onReload: reload,
        ),
      for (final file in files)
        ListTile(
          title: Text(file['name'].toString()),
          trailing: IconButton(
            tooltip: platformText(context, '保存到相册'),
            icon: const Icon(Icons.photo_library_outlined),
            onPressed: () =>
                state.run('video.saveToPhotos', {'name': file['name']}),
          ),
        ),
      TextField(
        controller: url,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(labelText: platformText(context, '推流地址')),
      ),
      const Text('RTMP / RTMPS • H.264 + AAC'),
      Wrap(
        spacing: 8,
        children: [
          nativeButton(context, state, '开始', 'rtmp.start', {'url': url.text}),
          nativeButton(context, state, '停止', 'rtmp.stop'),
        ],
      ),
    ],
  );
}
