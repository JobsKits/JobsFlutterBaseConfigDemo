import 'dart:io';
import 'package:flutter/material.dart';
import 'package:jobs_runners/jobs_runners.dart'; // 公共测试器路径
import 'package:video_player/video_player.dart';

void main() => runApp(
    const JobsMaterialRunner(VideoPlayerScreen(), title: 'Video Player Demo'));

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
    const String videoPath =
        '/private/var/mobile/Containers/Data/Application/F7564880-6969-4F34-8562-BD818D2E2A06/tmp/image_picker_35D24461-B866-4D93-A00B-618901C487A1-10834-000003230A5787C573840049933__F1737025-DD89-4E41-890E-993495A0E8E5.MOV';
    _controller = VideoPlayerController.file(File(videoPath));
    _initializeVideoPlayerFuture = _controller.initialize().then((_) {
      setState(() {});
      _controller.play();
    });

    _controller.setLooping(true);
  }

  @override
  void dispose() {
    _controller.dispose();
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
              child: AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              ),
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
            if (_controller.value.isPlaying) {
              _controller.pause();
            } else {
              _controller.play();
            }
          });
        },
        child: Icon(
          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }
}
