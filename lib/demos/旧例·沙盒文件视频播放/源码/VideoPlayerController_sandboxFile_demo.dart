import 'package:flutter/foundation.dart';
import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';

import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:jobs_runners/jobs_runners.dart'; // 公共测试器路径
import 'package:video_player/video_player.dart';

void legacyOriginalMain() => legacyCaptureApp(
  const JobsMaterialRunner(VideoPlayerScreen(), title: 'Video Player Demo'),
);

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({super.key});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController? _controller;
  late Future<void> _initializeVideoPlayerFuture;
  @override
  void initState() {
    super.initState();
    _initializeVideoPlayerFuture = _loadSandboxVideo();
  }

  Future<void> _loadSandboxVideo() async {
    final data = await rootBundle.load(
      'assets/Video/AppLaunchAssets/appLaunch_welcome.mp4',
    );
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/jobs_legacy_sandbox_video.mp4');
    await file.writeAsBytes(
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      flush: true,
    );
    if (!mounted) return;
    final controller = VideoPlayerController.file(file);
    _controller = controller;
    await controller.initialize();
    if (!mounted) return;
    await controller.setLooping(true);
    await controller.play();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const LegacyText('Video Player Demo')),
      body: FutureBuilder(
        future: _initializeVideoPlayerFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const LegacyText('Error loading video'),
                  TextButton(
                    onPressed: () => setState(
                      () => _initializeVideoPlayerFuture = _loadSandboxVideo(),
                    ),
                    child: const LegacyText('重试'),
                  ),
                ],
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.done &&
              _controller?.value.isInitialized == true) {
            return Center(
              child: AspectRatio(
                aspectRatio: _controller!.value.aspectRatio,
                child: VideoPlayer(_controller!),
              ),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _controller?.value.isInitialized != true
            ? null
            : () {
                setState(() {
                  if (_controller!.value.isPlaying) {
                    _controller!.pause();
                  } else {
                    _controller!.play();
                  }
                });
              },
        child: Icon(
          _controller?.value.isPlaying == true ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }
}

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() => launchLegacyStandalone(
  legacyOriginalMain,
  supportsWeb: false,
  supportedPlatforms: const [TargetPlatform.iOS, TargetPlatform.android],
  title: '旧例·沙盒文件视频播放',
);
