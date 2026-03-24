// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:jobs_flutter_base_config/JobsDemoTools/JobsFlutterTools/JobsRunners/JobsMaterialRunner.dart'; // 公共测试器路径
// import 'package:video_player/video_player.dart';
// import 'package:video_compress/video_compress.dart';

// void main() => runApp(
//     const JobsMaterialRunner(VideoPlayerScreen(), title: 'Video Player Demo'));

// class VideoPlayerScreen extends StatefulWidget {
//   const VideoPlayerScreen({super.key});

//   @override
//   _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
// }

// class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
//   final picker = ImagePicker();
//   VideoPlayerController? _controller;

//   @override
//   void initState() {
//     super.initState();
//     VideoCompress.setLogLevel(0); // 关闭日志
//   }

//   Future<void> getVideo() async {
//     final pickedFile = await picker.pickVideo(source: ImageSource.camera);
//     if (pickedFile != null) {
//       final File movFile = File(pickedFile.path);
//       final mp4File = await _convertMovToMp4(movFile);
//       if (mp4File != null) {
//         _initializeVideoPlayer(mp4File);
//       }
//     } else {
//       _showSnackBar('还没有选择视频资源...');
//     }
//   }

//   Future<File?> _convertMovToMp4(File movFile) async {
//     try {
//       final info = await VideoCompress.compressVideo(
//         movFile.path,
//         quality: VideoQuality.MediumQuality,
//         deleteOrigin: false,
//       );

//       if (info != null && info.file != null) {
//         return info.file;
//       } else {
//         _showSnackBar('视频压缩失败...');
//         return null;
//       }
//     } catch (e) {
//       _showSnackBar('压缩出错: $e');
//       return null;
//     }
//   }

//   void _initializeVideoPlayer(File file) {
//     _controller?.dispose();
//     _controller = VideoPlayerController.file(file)
//       ..addListener(() {
//         if (_controller!.value.hasError) {
//           _showSnackBar('播放视频错误: ${_controller!.value.errorDescription}');
//         }
//       })
//       ..setLooping(true)
//       ..initialize().then((_) {
//         if (!mounted) return;
//         setState(() {});
//         _controller?.play();
//       }).catchError((error) {
//         _showSnackBar('初始化视频错误: $error');
//       });
//   }

//   void _showSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         duration: const Duration(seconds: 2),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _controller?.dispose();
//     VideoCompress.dispose(); // 释放资源
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     Widget content;
//     if (_controller == null) {
//       content = const Text('还没有选择视频');
//     } else if (_controller!.value.isInitialized) {
//       content = AspectRatio(
//         aspectRatio: _controller!.value.aspectRatio,
//         child: VideoPlayer(_controller!),
//       );
//     } else {
//       content = const CircularProgressIndicator();
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Video Player Demo'),
//       ),
//       body: Center(child: content),
//       floatingActionButton: FloatingActionButton(
//         onPressed: getVideo,
//         tooltip: '录像',
//         child: const Icon(Icons.videocam),
//       ),
//     );
//   }
// }
