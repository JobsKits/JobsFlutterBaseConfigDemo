import 'package:flutter/material.dart';
import 'package:jobs_runners/jobs_runners.dart'; // 公共测试器路径
import 'package:video_player/video_player.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'package:path_provider/path_provider.dart';

// VideoPlayerController_file_demo.dart
// 视频资源位于项目跟目录下的：
// assets/Video/AppLaunchAssets/appLaunch_welcome.mp4

// dependencies:
//   flutter:
//     sdk: flutter
//   video_player:
void main() => runApp(
    const JobsMaterialRunner(VideoPlayerScreen(), title: 'Video Player Demo'));

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({super.key});
  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController? _controller;
  late Future<void> _initializeVideoPlayerFuture;
  @override
  void initState() {
    super.initState();
    _initializeVideoPlayerFuture = _loadVideo();
  }

  Future<void> _loadVideo() async {
    // VideoPlayerController 目前不支持直接播放 assets 中的视频文件
    // 将 assets 中的视频文件复制到应用文档目录的过程实际上是为了将视频文件转换成 VideoPlayerController 可以识别的格式
    // assets 文件在 Flutter 中并不具有标准的文件路径。
    // assets 文件通常被打包到应用程序内部，并且它们的路径是相对于应用程序的，这使得某些插件（如 video_player）无法直接访问它们
    // 从 assets 中加载视频文件的字节数据
    final ByteData data = await rootBundle
        .load('assets/Video/AppLaunchAssets/appLaunch_welcome.mp4');
    // 获取临时目录
    final Directory tempDir = await getTemporaryDirectory();
    // 创建临时文件并写入字节数据
    final File tempFile = File(path.join(tempDir.path, 'welcome_video.mp4'));
    await tempFile.writeAsBytes(data.buffer.asUint8List(), flush: true);
    // 沙盒文件路径
    // const String tempFile = '/private/var/mobile/Containers/Data/Application/F7564880-6969-4F34-8562-BD818D2E2A06/tmp/image_picker_35D24461-B866-4D93-A00B-618901C487A1-10834-000003230A5787C573840049933__F1737025-DD89-4E41-890E-993495A0E8E5.MOV';
    // 使用临时文件路径初始化 VideoPlayerController
    _controller = VideoPlayerController.file(tempFile);
    await _controller!.initialize();
    setState(() {});
    _controller!.play();
    _controller!.setLooping(true);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Player Demo'),
      ),
      body: FutureBuilder(
        future: _initializeVideoPlayerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Center(
              child: _controller != null && _controller!.value.isInitialized
                  ? AspectRatio(
                      aspectRatio: _controller!.value.aspectRatio,
                      child: VideoPlayer(_controller!),
                    )
                  : const Text('Error loading video'),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            if (_controller != null) {
              if (_controller!.value.isPlaying) {
                _controller!.pause();
              } else {
                _controller!.play();
              }
            }
          });
        },
        child: Icon(
          _controller != null && _controller!.value.isPlaying
              ? Icons.pause
              : Icons.play_arrow,
        ),
      ),
    );
  }
}
