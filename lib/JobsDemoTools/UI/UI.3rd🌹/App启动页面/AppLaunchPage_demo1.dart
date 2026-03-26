import 'dart:async';
import 'package:flutter/material.dart';
import 'package:jobs_runners/jobs_runners.dart'; // 公共测试器路径
import 'package:video_player/video_player.dart';
import 'package:url_launcher/url_launcher.dart';

// 当前只读取本地资源作为App开屏页，后续可根据需求增加网络资源
// 视频资源位于项目跟目录下的：
// assets/Video/AppLaunchAssets/appLaunch_welcome.mp4
// 图片资源位于项目跟目录下的：
// assets/Images/AppLaunchAssets/appLaunch_welcome.gif
// assets/Images/AppLaunchAssets/appLaunch_welcome.png
// 视频资源Online地址：
// https://www.apple.com/105/media/us/iphone-x/2017/01df5b43-28e4-4848-bf20-490c34a926a7/films/feature/iphone-x-feature-tpl-cc-us-20170912_1280x720h.mp4
void main() =>
    runApp(const JobsMaterialRunner(LaunchScreen(), title: 'LaunchScreen'));

class LaunchScreen extends StatefulWidget {
  const LaunchScreen({super.key});
  @override
  _LaunchScreenState createState() => _LaunchScreenState();
}

class _LaunchScreenState extends State<LaunchScreen> {
  late VideoPlayerController _videoController;
  late Timer? _timer;
  int _countdown = 60; // 默认倒计时秒数
  final bool _showVideo = false; // 是否显示视频
  final bool _showImage = false; // 是否显示图片
  final bool _showGif = true; // 是否显示GIF
  @override
  void initState() {
    super.initState();
    // 初始化视频播放器
    _videoController = VideoPlayerController.asset(
        'assets/Video/AppLaunchAssets/appLaunch_welcome.mp4')
      ..initialize().then((_) {
        setState(() {});
        _videoController.play();
      });

    // 启动倒计时
    _startCountdown();
  }

  @override
  void dispose() {
    _videoController.dispose();
    if (_timer?.isActive ?? false) {
      _timer!.cancel();
    }
    super.dispose();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_countdown > 1) {
          _countdown--;
        } else {
          _navigateToHome();
        }
      });
    });
  }

  void _navigateToHome() {
    if (_timer?.isActive ?? false) {
      _timer!.cancel();
    }

    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => const HomePage(),
    ));
  }

  void _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          if (_showVideo)
            Positioned.fill(
              child: _videoController.value.isInitialized
                  ? VideoPlayer(_videoController)
                  : const Center(child: CircularProgressIndicator()),
            ),
          if (_showImage)
            Positioned.fill(
              child: Image.asset(
                  'assets/Images/AppLaunchAssets/appLaunch_welcome.png',
                  fit: BoxFit.cover),
            ),
          if (_showGif)
            Positioned.fill(
              child: Image.asset(
                  'assets/Images/AppLaunchAssets/appLaunch_welcome.gif',
                  fit: BoxFit.cover),
            ),
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                _launchURL('https://www.sina.com');
              },
            ),
          ),
          Positioned(
            top: 40,
            right: 20,
            child: GestureDetector(
              onTap: _navigateToHome,
              child: RichText(
                text: TextSpan(
                  children: [
                    const TextSpan(
                      text: '跳过| ',
                      style: TextStyle(color: Colors.grey),
                    ),
                    TextSpan(
                      text: '$_countdown',
                      style: const TextStyle(color: Colors.red),
                    ),
                    const TextSpan(
                      text: ' 秒',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Page')),
      body: const Center(child: Text('Welcome to the Home Page!')),
    );
  }
}
