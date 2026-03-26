import 'package:flutter/material.dart';
import 'package:jobs_runners/jobs_runners.dart'; // 公共测试器路径
import 'package:video_player/video_player.dart';
// 真机运行如果出现空白页面的解决方案：
// 方案1、在工程根目录下执行 flutter run --release 或者
// 方案2、通过 flutter devices 拿到设备id，然后 flutter run -d 设备ID

// 视频资源位于项目跟目录下的：
// assets/Video/AppLaunchAssets/appLaunch_welcome.mp4

// dependencies:
//   flutter:
//     sdk: flutter
//   video_player:

void main() => runApp(
    const JobsMaterialRunner(VideoPlayerScreen(), title: 'Welcome Video'));

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({super.key});

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    // 创建VideoPlayerController并加载本地视频文件
    _controller = VideoPlayerController.asset(
        'assets/Video/AppLaunchAssets/appLaunch_welcome.mp4');
    // 初始化VideoPlayerController
    _initializeVideoPlayerFuture = _controller.initialize();
    // 循环播放视频
    _controller.setLooping(true);
    // 开始播放视频
    _controller.play();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          // 显示视频播放器一旦初始化完成
          return AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          );
        } else {
          // 显示加载动画，直到视频播放器初始化完成
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  @override
  void dispose() {
    // 释放VideoPlayerController资源
    _controller.dispose();
    super.dispose();
  }
}
