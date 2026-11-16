import 'package:flutter/foundation.dart';

class PlayerCheckpoint {
  const PlayerCheckpoint(this.position, this.playing);
  final double position;
  final bool playing;
  double seekPosition(double duration) => duration.isFinite && duration > 0
      ? position.clamp(0, (duration - .1).clamp(0, duration)).toDouble()
      : position;
}

/// Observable player events only. Readiness and progress are not decoded frames.
class PlayerQualityState extends ChangeNotifier {
  PlayerQualityState({Duration Function()? clock}) {
    _clock = clock ?? () => _watch.elapsed;
    _watch.start();
  }
  final _watch = Stopwatch();
  late final Duration Function() _clock;
  final _checkpoints = <String, PlayerCheckpoint>{};
  Duration? _started;
  Duration? _bufferStarted;
  Duration _buffered = Duration.zero;
  double _baseline = 0;
  String? source;
  Duration? readyLatency;
  Duration? firstProgressLatency;
  int bufferingCount = 0;
  int errorCount = 0;
  int recoveryCount = 0;
  int fallbackCount = 0;
  bool bufferingReported = false;
  bool buffering = false;
  bool intendedPlaying = true;
  bool _disposed = false;
  Duration get bufferedDuration =>
      _buffered +
      (_bufferStarted == null ? Duration.zero : _clock() - _bufferStarted!);
  PlayerCheckpoint? checkpoint(String source) => _checkpoints[source];
  void remember(String source, double position, bool playing) {
    if (!position.isFinite || position < 0) return;
    _checkpoints.remove(source);
    _checkpoints[source] = PlayerCheckpoint(position, playing);
    if (_checkpoints.length > 12) _checkpoints.remove(_checkpoints.keys.first);
  }

  void begin(
    String key, {
    bool reportsBuffering = false,
    PlayerCheckpoint? restoring,
  }) {
    source = key;
    _started = _clock();
    readyLatency = null;
    firstProgressLatency = null;
    _bufferStarted = null;
    _buffered = Duration.zero;
    bufferingCount = 0;
    buffering = false;
    bufferingReported = reportsBuffering;
    intendedPlaying = restoring?.playing ?? true;
    _baseline = restoring?.position ?? 0;
    _notify();
  }

  void observe({
    required double position,
    required bool playing,
    bool ready = false,
    bool? isBuffering,
  }) {
    final start = _started;
    if (start == null || _disposed) return;
    if (ready && readyLatency == null) readyLatency = _clock() - start;
    if (readyLatency != null &&
        playing &&
        position.isFinite &&
        position > _baseline + .05 &&
        firstProgressLatency == null) {
      firstProgressLatency = _clock() - start;
    }
    if (isBuffering != null && bufferingReported) {
      final next = isBuffering && readyLatency != null && intendedPlaying;
      if (next && !buffering) {
        bufferingCount++;
        _bufferStarted = _clock();
      }
      if (!next && buffering && _bufferStarted != null) {
        _buffered += _clock() - _bufferStarted!;
        _bufferStarted = null;
      }
      buffering = next;
    }
    _notify();
  }

  void intent(bool playing) {
    intendedPlaying = playing;
    if (!playing && buffering && _bufferStarted != null) {
      _buffered += _clock() - _bufferStarted!;
      _bufferStarted = null;
      buffering = false;
    }
    _notify();
  }

  void failed() {
    errorCount++;
    _notify();
  }

  void recovering() {
    recoveryCount++;
    _notify();
  }

  void fellBack() {
    fallbackCount++;
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _watch.stop();
    super.dispose();
  }
}
