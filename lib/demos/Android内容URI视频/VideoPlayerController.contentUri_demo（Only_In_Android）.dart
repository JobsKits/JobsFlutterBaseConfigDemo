// 独立运行：flutter run -t "lib/demos/Android内容URI视频/VideoPlayerController.contentUri_demo（Only_In_Android）.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:video_player/video_player.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

void main() => launchLegacyStandalone(
  legacyOriginalMain,
  supportsWeb: false,
  supportedPlatforms: const [TargetPlatform.android],
  title: 'Android内容URI视频',
);

void legacyOriginalMain() => legacyCaptureApp(const VideoPlayerScreen());

/// Android 内容提供器 URI 播放；通过输入保留真实设备的授权 URI。
class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({super.key});
  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  final uriInput = TextEditingController();
  VideoPlayerController? controller;
  String? status;
  bool loading = false;
  int generation = 0;

  Future<void> loadVideo() async {
    final uri = Uri.tryParse(uriInput.text.trim());
    if (uri == null || uri.scheme != 'content' || uri.authority.isEmpty) {
      setState(() => status = '需要有效的 content:// URI');
      return;
    }
    final run = ++generation;
    setState(() {
      loading = true;
      status = null;
    });
    final previous = controller;
    controller = null;
    await previous?.dispose();
    if (!mounted || run != generation) return;
    final next = VideoPlayerController.contentUri(uri);
    controller = next;
    try {
      await next.initialize();
      if (!mounted || run != generation) return;
      await next.setLooping(true);
      await next.play();
    } catch (error) {
      if (mounted && run == generation) status = 'Error loading video';
      legacyDebugPrint('$error');
    } finally {
      if (mounted && run == generation) setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    generation++;
    uriInput.dispose();
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: JobsDemoAppBar(title: const LegacyText('Video Player Demo')),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          controller: uriInput,
          decoration: legacyInputDecoration(
            context,
            const InputDecoration(labelText: '输入 Android content:// URI'),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: loading ? null : loadVideo,
          child: const LegacyText('播放视频'),
        ),
        if (loading) const LinearProgressIndicator(),
        if (status != null) LegacyText(status!),
        if (controller?.value.isInitialized == true)
          AspectRatio(
            aspectRatio: controller!.value.aspectRatio,
            child: VideoPlayer(controller!),
          ),
        if (controller?.value.isInitialized == true)
          IconButton(
            onPressed: () {
              setState(() {
                controller!.value.isPlaying
                    ? controller!.pause()
                    : controller!.play();
              });
            },
            icon: Icon(
              controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
            ),
          ),
      ],
    ),
  );
}

Widget buildLegacyDemo(BuildContext context) => LegacyLaunchPage(
  supportsWeb: false,
  supportedPlatforms: const [TargetPlatform.android],
  action: legacyOriginalMain,
  title: 'VideoPlayerController.contentUri_demo（Only_In_Android）',
);
