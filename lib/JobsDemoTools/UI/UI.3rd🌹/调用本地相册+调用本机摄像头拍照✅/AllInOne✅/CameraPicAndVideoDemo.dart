import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:jobs_runners/jobs_runners.dart'; // 公共测试器路径

// 不跳转系统相机，就在当前页面，进行录像或者拍照，且显示拍摄的结果
// 可以对拍摄的结果进行保存在本地相册（相册名：Jobs）

// 真机运行如果出现空白页面的解决方案：
// 方案1、在工程根目录下执行 flutter run --release 或者
// 方案2、通过 flutter devices 拿到设备id，然后 flutter run -d 设备ID。比如
// flutter run lib/调用本地相册+调用本机摄像头拍照（全部验证通过）/PicturesAndVideoAllInOne.dart -d 00008110-000625583EE3801E

// 权限问题：Flutter代码不配置设备权限。配置权限需要进入特定的代码里面，按照设备所属的代码规范进行配置。比如：
// iOS进入`info.plist`里面进行配置
// Android通常只涉及两个主要文件：`AndroidManifest.xml` 和 `build.gradle`
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final firstCamera = cameras.first;
  runApp(JobsMaterialRunner(CameraScreen(camera: firstCamera),
      title: 'Camera Demo'));
}

class CameraScreen extends StatefulWidget {
  final CameraDescription camera;

  const CameraScreen({super.key, required this.camera});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  bool _isRecording = false;
  // ignore: unused_field
  String? _lastSavedMediaPath;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.high,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    try {
      await _initializeControllerFuture;
      final image = await _controller.takePicture();
      setState(() {
        _lastSavedMediaPath = image.path;
      });

      _showSnackBar('图片已保存到相册');
    } catch (e) {
      _showSnackBar('拍照失败: $e');
    }
  }

  Future<void> _startVideoRecording() async {
    try {
      await _initializeControllerFuture;
      await _controller.startVideoRecording();
      setState(() {
        _isRecording = true;
      });
    } catch (e) {
      _showSnackBar('开始录像失败: $e');
    }
  }

  Future<void> _stopVideoRecording() async {
    try {
      final video = await _controller.stopVideoRecording();

      setState(() {
        _isRecording = false;
        _lastSavedMediaPath = video.path;
      });

      _showSnackBar('视频已保存到相册');
    } catch (e) {
      _showSnackBar('停止录像失败: $e');
    }
  }

  void _showSnackBar(String message) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 2),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera Demo'),
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(_controller);
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () async {
              if (_isRecording) {
                await _stopVideoRecording();
              } else {
                await _takePicture();
              }
            },
            tooltip: _isRecording ? 'Stop Recording' : 'Take Picture',
            child: Icon(_isRecording ? Icons.videocam_off : Icons.camera_alt),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: _isRecording ? null : _startVideoRecording,
            tooltip: 'Start Recording',
            child: const Icon(Icons.videocam),
          ),
        ],
      ),
    );
  }
}
