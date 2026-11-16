import 'dart:math' as math;
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

enum JobsRefreshFeedbackEvent { started, succeeded, failed }

/// 自有短提示音由PCM合成，不借用业务音频，不占用用户的音乐会话。
class JobsRefreshFeedback {
  AudioPlayer? _player;
  bool _disposed = false;
  int _generation = 0;

  Future<void> play(
    JobsRefreshFeedbackEvent event, {
    required bool haptics,
    required bool sound,
  }) async {
    if (_disposed) return;
    final generation = ++_generation;
    if (haptics) {
      try {
        switch (event) {
          case JobsRefreshFeedbackEvent.started:
            await HapticFeedback.lightImpact();
          case JobsRefreshFeedbackEvent.succeeded:
            await HapticFeedback.selectionClick();
          case JobsRefreshFeedbackEvent.failed:
            await HapticFeedback.mediumImpact();
        }
      } on Exception {
        // 设备无触觉能力不影响数据操作或可见状态。
      }
    }
    if (!sound || _disposed || generation != _generation) return;
    try {
      final player = _player ??= (AudioPlayer()
        ..audioCache = AudioCache(
          prefix: 'packages/jobs_demo_foundation/assets/audio/',
        ));
      await player.setAudioContext(
        AudioContext(
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.ambient,
            options: [AVAudioSessionOptions.mixWithOthers],
          ),
          android: const AudioContextAndroid(
            audioFocus: AndroidAudioFocus.none,
          ),
        ),
      );
      if (_disposed || generation != _generation) return;
      // 当前Darwin插件不支持setSourceBytes，打包WAV走受支持的本地URL准备路径。
      await player.play(AssetSource('refresh_${event.name}.wav'), volume: .3);
    } on Exception {
      // 静音、音频设备缺失或浏览器手势策略仍保留视觉与触觉反馈。
    }
  }

  Future<void> stop() async {
    _generation++;
    try {
      await _player?.stop();
    } on Exception {
      // 页面生命周期不依赖平台音频通道的可用性。
    }
  }

  Future<void> dispose() async {
    _disposed = true;
    _generation++;
    try {
      await _player?.dispose();
    } on Exception {
      // 不支持音频的平台同样必须能正常离开页面。
    }
    _player = null;
  }
}

/// Jobs原创合成波形：开始单短音，完成上行双音，失败低音；单声道16-bit WAV。
Uint8List jobsRefreshCue(JobsRefreshFeedbackEvent event) {
  const sampleRate = 22050;
  final frequencies = switch (event) {
    JobsRefreshFeedbackEvent.started => [660.0],
    JobsRefreshFeedbackEvent.succeeded => [660.0, 880.0],
    JobsRefreshFeedbackEvent.failed => [330.0, 220.0],
  };
  const noteSeconds = .065;
  final samplesPerNote = (sampleRate * noteSeconds).round();
  final sampleCount = samplesPerNote * frequencies.length;
  final bytes = ByteData(44 + sampleCount * 2);
  void ascii(int offset, String value) {
    for (var i = 0; i < value.length; i++) {
      bytes.setUint8(offset + i, value.codeUnitAt(i));
    }
  }

  ascii(0, 'RIFF');
  bytes.setUint32(4, 36 + sampleCount * 2, Endian.little);
  ascii(8, 'WAVEfmt ');
  bytes.setUint32(16, 16, Endian.little);
  bytes.setUint16(20, 1, Endian.little);
  bytes.setUint16(22, 1, Endian.little);
  bytes.setUint32(24, sampleRate, Endian.little);
  bytes.setUint32(28, sampleRate * 2, Endian.little);
  bytes.setUint16(32, 2, Endian.little);
  bytes.setUint16(34, 16, Endian.little);
  ascii(36, 'data');
  bytes.setUint32(40, sampleCount * 2, Endian.little);
  for (var i = 0; i < sampleCount; i++) {
    final note = i ~/ samplesPerNote;
    final local = (i % samplesPerNote) / samplesPerNote;
    final envelope = math.pow(math.sin(math.pi * local), 2).toDouble();
    final wave = math.sin(2 * math.pi * frequencies[note] * i / sampleRate);
    bytes.setInt16(
      44 + i * 2,
      (wave * envelope * 15000).round(),
      Endian.little,
    );
  }
  return bytes.buffer.asUint8List();
}
