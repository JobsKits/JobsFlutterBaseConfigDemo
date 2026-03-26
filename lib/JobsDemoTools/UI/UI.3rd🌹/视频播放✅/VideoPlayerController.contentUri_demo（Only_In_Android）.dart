import 'package:flutter/material.dart';
import 'package:jobs_runners/jobs_runners.dart'; // 公共测试器路径
import 'package:video_player/video_player.dart';

// VideoPlayerController.contentUri 目前只支持Android平台。
// 也就意味着，在iOS平台上，使用VideoPlayerController.contentUri会崩溃
// _AssertionError ('package:video_player/video_player.dart': Failed assertion: line 340 pos 16: 'defaultTargetPlatform == TargetPlatform.android': VideoPlayerController.contentUri is only supported on Android.)
void main() => runApp(
    const JobsMaterialRunner(VideoPlayerScreen(), title: 'Video Player Demo'));

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({super.key});
  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  final String _videoUri =
      'https://www.apple.com/105/media/us/iphone-x/2017/01df5b43-28e4-4848-bf20-490c34a926a7/films/feature/iphone-x-feature-tpl-cc-us-20170912_1280x720h.mp4'; // 替换为你的网络视频URI
  @override
  void initState() {
    super.initState();
    // Initialize the VideoPlayerController with the video URI
    _controller = VideoPlayerController.contentUri(Uri.parse(_videoUri))
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized
        setState(() {});
      });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Player Demo'),
      ),
      body: Center(
        child: _controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : const CircularProgressIndicator(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _controller.value.isPlaying
                ? _controller.pause()
                : _controller.play();
          });
        },
        child: Icon(
          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }
}
