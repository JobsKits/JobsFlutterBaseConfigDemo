// 独立运行：flutter run -t "lib/demos/倒计时与暂停恢复/CountdownBtn.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jobs_runners/jobs_runners.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() => launchLegacyStandalone(legacyOriginalMain, title: '倒计时与暂停恢复');

// 公共测试器路径

void legacyOriginalMain() => legacyCaptureApp(
  JobsMaterialRunner(
    Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 水平布局、点击触发、步长2(计时器模式)
          CountdownBtn(
            textFront: '现在已经进行：',
            textBack: '请做好准备。',
            isVertical: false,
            duration: 3600, // 1小时
            textStyle: const TextStyle(fontSize: 16),
            autoStart: false, // 点击触发
            timeStep: 0.5,
            initialTime: DateTime.now(),
          ),
          const SizedBox(height: 20),
          // 垂直布局、自动触发、步长1(计时器模式)
          CountdownBtn(
            textFront: '现在已经进行：',
            textBack: '请做好准备。',
            isVertical: true,
            duration: 3600, // 1小时
            textStyle: const TextStyle(fontSize: 16),
            autoStart: true, // 自动触发
            timeStep: 1,
            initialTime: DateTime.now(),
          ),
          const SizedBox(height: 20),
          // 水平布局、点击触发、步长-2(倒计时模式)
          CountdownBtn(
            textFront: '现在距离倒计时结束还有：',
            textBack: '请做好准备。',
            isVertical: false,
            duration: 3600, // 1小时
            textStyle: const TextStyle(fontSize: 16),
            autoStart: false, // 点击触发
            timeStep: -2,
            initialTime: DateTime.now(),
          ),
          const SizedBox(height: 20),
          // 垂直布局、自动触发、步长-1(倒计时模式)
          CountdownBtn(
            textFront: '现在距离倒计时结束还有：',
            textBack: '请做好准备。',
            isVertical: true,
            duration: 3600, // 1小时
            textStyle: const TextStyle(fontSize: 16),
            autoStart: true, // 自动触发
            timeStep: -1,
            initialTime: DateTime.now(),
          ),
        ],
      ),
    ),
    title: '倒计时按钮示例✅',
  ),
);

class CountdownBtn extends StatefulWidget {
  final Color backgroundColor;
  final String textFront;
  final String textBack;
  final bool isVertical;
  final double duration; // 修改为 double 类型
  final TextStyle textStyle;
  final bool autoStart;
  final double timeStep; // double 类型
  final DateTime? initialTime;

  const CountdownBtn({
    super.key,
    this.backgroundColor = Colors.grey,
    required this.textFront,
    required this.textBack,
    required this.isVertical,
    required this.duration,
    required this.textStyle,
    this.autoStart = false,
    this.timeStep = 0.5,
    this.initialTime,
  });

  @override
  State<CountdownBtn> createState() => _CountdownBtnState();
}

class _CountdownBtnState extends State<CountdownBtn> {
  late Duration _remainingDuration;
  late Timer? _timer;
  bool isCountingDown = false;
  bool isPaused = false;

  @override
  void initState() {
    super.initState();
    _remainingDuration = Duration(
      milliseconds: (widget.duration * 1000).toInt(),
    );
    if (widget.autoStart) {
      _startCountdown();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleCountdown,
      child: Container(
        color: widget.backgroundColor,
        padding: const EdgeInsets.all(10.0),
        child: widget.isVertical
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LegacyText(widget.textFront, style: widget.textStyle),
                  RichText(
                    text: _coloredTimeSpan(formatDuration(_remainingDuration)),
                  ),
                  LegacyText(widget.textBack, style: widget.textStyle),
                ],
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LegacyText(widget.textFront, style: widget.textStyle),
                  RichText(
                    text: _coloredTimeSpan(formatDuration(_remainingDuration)),
                  ),
                  LegacyText(widget.textBack, style: widget.textStyle),
                ],
              ),
      ),
    );
  }

  @override
  void dispose() {
    if (_timer?.isActive ?? false) {
      _timer!.cancel();
    }
    super.dispose();
  }

  // 手势切换
  void _toggleCountdown() {
    legacyDebugPrint("手势切换");
    if (isCountingDown) {
      if (isPaused) {
        _resumeCountdown();
      } else {
        _pauseCountdown();
      }
    } else {
      _startCountdown();
    }
  }

  // 开始倒计时(核心方法)
  void _startCountdown() {
    setState(() {
      isCountingDown = true;
      isPaused = false;
    });
    _timer = Timer.periodic(
      // Duration(seconds: 1), // 每秒触发一次
      Duration(milliseconds: (widget.timeStep.abs() * 1000).toInt()), // 毫秒为单位
      (timer) {
        setState(() {
          _remainingDuration -= Duration(
            milliseconds: (widget.timeStep * 1000).toInt(),
          ); // 更新剩余时间
          if (_remainingDuration <= Duration.zero) {
            if (timer.isActive) {
              timer.cancel();
            }
            isCountingDown = false;
            _remainingDuration = Duration.zero;
          }
        });
        // 打印当前时间
        // legacyDebugPrint('打印当前时间: ${DateTime.now()}');
      },
    );
    _playSound();
  }

  // 暂停定时器
  void _pauseCountdown() {
    setState(() {
      isPaused = true;
    });
    if (_timer?.isActive ?? false) {
      _timer!.cancel();
    }
    _playSound();
  }

  // 重启定时器
  void _resumeCountdown() {
    setState(() {
      isPaused = false;
    });
    _startCountdown();
  }

  // 播放声音
  void _playSound() {
    SystemSound.play(SystemSoundType.click);
  }

  String formatDuration(Duration duration) {
    legacyDebugPrint(
      '打印duration: ${duration.inHours}时${duration.inMinutes.remainder(60)}分${duration.inSeconds.remainder(60)}秒',
    );
    return '${duration.inHours}时${duration.inMinutes.remainder(60)}分${duration.inSeconds.remainder(60)}秒';
  }

  TextSpan _coloredTimeSpan(String time) {
    List<InlineSpan> spans = [];
    // 使用正则表达式匹配数字和单位的组合
    final regex = RegExp(r'(\d+)([^\d]+)');
    regex.allMatches(time).forEach((match) {
      final number = match.group(1);
      final unit = match.group(2);
      if (number != null && unit != null) {
        // 根据单位为文本设置不同颜色
        Color color;
        switch (unit) {
          case '时':
            color = Colors.red;
            break;
          case '分':
            color = Colors.yellow;
            break;
          case '秒':
            color = Colors.white;
            break;
          default:
            color = Colors.black;
        }
        spans.add(
          TextSpan(
            text: '$number$unit',
            style: widget.textStyle.copyWith(color: color),
          ),
        );
      }
    });
    return TextSpan(children: spans);
  }
}

Widget buildLegacyDemo(BuildContext context) => JobsDemoActionHost(
  child: Scaffold(
    appBar: JobsDemoAppBar(
      actionHost: true,
      title: const LegacyText('倒计时与暂停恢复'),
    ),
    body: SafeArea(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CountdownBtn(
              textFront: '倒计时 ',
              textBack: '',
              isVertical: true,
              duration: 60,
              autoStart: true,
              textStyle: Theme.of(context).textTheme.titleLarge!,
              timeStep: 1,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            ),
            const SizedBox(height: 24),
            CountdownBtn(
              textFront: '反向计时 ',
              textBack: '',
              isVertical: true,
              duration: 60,
              autoStart: true,
              textStyle: Theme.of(context).textTheme.titleLarge!,
              timeStep: -1,
              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
            ),
          ],
        ),
      ),
    ),
  ),
);
